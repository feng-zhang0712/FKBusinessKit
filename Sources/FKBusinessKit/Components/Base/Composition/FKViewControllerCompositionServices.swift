import UIKit

// MARK: - Composite façade

/// Bundles optional UIKit cross-cutting behaviors so plain `UIViewController` subclasses can use
/// **composition** instead of inheriting ``FKBaseViewController``.
///
/// Forward UIKit lifecycle callbacks with ``forward(_:for:)`` from your controller.
@MainActor
public final class FKViewControllerComposite {

  /// Keyboard frame notifications (started in `viewDidAppear`, stopped in `viewWillDisappear`).
  public let keyboard = FKCompositeKeyboardObservation()

  /// Navigation bar visibility, style, and large-title preference with snapshot restore.
  public let navigationChrome = FKCompositeNavigationChrome()

  /// Toggles interactive pop gesture policy while visible, restoring when detached.
  public let interactivePopGesture = FKCompositeInteractivePopGesture()

  /// Tap outside controls to end editing.
  public let tapToDismissKeyboard = FKCompositeTapToDismissKeyboard()

  /// `isViewAppeared` / `hasCompletedInitialAppearance` tracking.
  public let appearanceState = FKViewControllerAppearanceState()

  /// When `true`, recursively disables scroll view bounce under the host `view` during `viewDidLoad`.
  public var disablesScrollBounceRecursivelyByDefault: Bool = false

  public init() {}

  /// Forwards a UIKit lifecycle event to the composed services.
  public func forward(_ lifecycle: FKViewControllerCompositeLifecycle, for viewController: UIViewController) {
    switch lifecycle {
    case .viewDidLoad:
      if disablesScrollBounceRecursivelyByDefault {
        FKBaseScrollBounce.applyRecursively(to: viewController.view, enabled: false)
      }
      tapToDismissKeyboard.bindIfNeeded(to: viewController)

    case let .viewWillAppear(animated):
      if let navigationController = viewController.navigationController {
        FKBaseNavigationInteractivePopGestureInstaller.installIfNeeded(on: navigationController)
      }
      navigationChrome.viewWillAppear(on: viewController, animated: animated)
      interactivePopGesture.viewWillAppear(on: viewController)

    case let .viewDidAppear(animated):
      appearanceState.onViewDidAppear(animated: animated)
      keyboard.startIfNeeded()
      navigationChrome.viewDidAppear(on: viewController)
      interactivePopGesture.synchronizeAfterNavigationChromeChange(on: viewController)

    case let .viewWillDisappear(animated):
      keyboard.stop()
      navigationChrome.viewWillDisappear(on: viewController, animated: animated)
      interactivePopGesture.viewWillDisappear(on: viewController)

    case .viewDidDisappear:
      appearanceState.onViewDidDisappear()
    }
  }
}

// MARK: - Appearance state

/// Tracks simple visibility flags for controllers using the composition bucket.
@MainActor
public final class FKViewControllerAppearanceState {
  /// `true` after the first `viewDidAppear`.
  public private(set) var hasCompletedInitialAppearance = false

  /// `true` between `viewDidAppear` and `viewWillDisappear`.
  public private(set) var isViewAppeared = false

  /// Optional callback invoked once after the first `viewDidAppear`.
  public var onFirstAppearance: (@MainActor (Bool) -> Void)?

  fileprivate func onViewDidAppear(animated: Bool) {
    isViewAppeared = true
    if !hasCompletedInitialAppearance {
      hasCompletedInitialAppearance = true
      onFirstAppearance?(animated)
    }
  }

  fileprivate func onViewDidDisappear() {
    isViewAppeared = false
  }
}

// MARK: - Keyboard

/// Observes keyboard notifications and forwards parsed animation metadata.
@MainActor
public final class FKCompositeKeyboardObservation {
  /// When `false`, ``startIfNeeded()`` becomes a no-op.
  public var isEnabled: Bool = true

  public var onWillChangeFrame: (@MainActor (CGRect, TimeInterval, UIView.AnimationCurve) -> Void)?
  public var onWillHide: (@MainActor (TimeInterval, UIView.AnimationCurve) -> Void)?

  private var observers: [NSObjectProtocol] = []

  public init() {}

  public func startIfNeeded() {
    guard isEnabled, observers.isEmpty else { return }
    let center = NotificationCenter.default

    let willChange = center.addObserver(
      forName: UIResponder.keyboardWillChangeFrameNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard
        let self,
        let userInfo = notification.userInfo,
        let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      else { return }
      let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
      let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
        ?? UIView.AnimationCurve.easeInOut.rawValue
      let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeInOut
      self.onWillChangeFrame?(frame, duration, curve)
    }

    let willHide = center.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard let self else { return }
      let userInfo = notification.userInfo
      let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
      let curveRaw = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
        ?? UIView.AnimationCurve.easeInOut.rawValue
      let curve = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeInOut
      self.onWillHide?(duration, curve)
    }

    observers = [willChange, willHide]
  }

  public func stop() {
    guard !observers.isEmpty else { return }
    let center = NotificationCenter.default
    observers.forEach(center.removeObserver)
    observers.removeAll()
  }
}

// MARK: - Navigation chrome

/// Mirrors ``FKBaseViewController`` navigation bar snapshot rules: capture on first `viewWillAppear`,
/// restore only when the host is permanently removed (pop / dismiss / detach).
@MainActor
public final class FKCompositeNavigationChrome {
  public var visibility: FKBaseViewController.NavigationBarVisibility = .visible {
    didSet { reapplyIfOnScreen() }
  }

  public var style: FKBaseViewController.NavigationBarStyle = .system {
    didSet { reapplyIfOnScreen() }
  }

  public var prefersLargeTitlesWhileVisible: Bool? {
    didSet { reapplyIfOnScreen() }
  }

  private var snapshot: FKBaseNavigationChromeSnapshot?
  private weak var hostViewController: UIViewController?

  public init() {}

  public func viewWillAppear(on viewController: UIViewController, animated: Bool) {
    guard let navigationController = viewController.navigationController else {
      hostViewController = nil
      return
    }
    hostViewController = viewController
    if snapshot == nil {
      snapshot = FKBaseNavigationChromeAppearanceCopying.capture(from: navigationController)
    }
    applyConfiguration(on: viewController, navigationController: navigationController, animated: animated)
  }

  public func viewDidAppear(on viewController: UIViewController) {
    _ = viewController
  }

  public func viewWillDisappear(on viewController: UIViewController, animated: Bool) {
    guard FKBaseViewControllerHierarchy.isLeavingPermanently(viewController) else { return }
    hostViewController = nil
    restoreIfNeeded(on: viewController, animated: animated)
  }

  private func applyConfiguration(on viewController: UIViewController, navigationController: UINavigationController, animated: Bool) {
    FKBaseNavigationChromeApplicator.applyConfiguration(
      visibility: visibility,
      style: style,
      prefersLargeTitlesWhileVisible: prefersLargeTitlesWhileVisible,
      snapshot: snapshot,
      navigationController: navigationController,
      navigationItem: viewController.navigationItem,
      animated: animated
    )
    viewController.setNeedsStatusBarAppearanceUpdate()
    navigationController.setNeedsStatusBarAppearanceUpdate()
  }

  private func restoreIfNeeded(on viewController: UIViewController, animated: Bool) {
    guard let snapshot, let navigationController = viewController.navigationController else { return }
    FKBaseNavigationChromeAppearanceCopying.restore(snapshot, on: navigationController, animated: animated)
    self.snapshot = nil
  }

  private func reapplyIfOnScreen() {
    guard
      let hostViewController,
      hostViewController.isViewLoaded,
      hostViewController.view.window != nil,
      let navigationController = hostViewController.navigationController
    else { return }
    applyConfiguration(on: hostViewController, navigationController: navigationController, animated: true)
  }
}

// MARK: - Interactive pop

@MainActor
public final class FKCompositeInteractivePopGesture {
  public var disablesInteractivePopGesture: Bool = false {
    didSet { applyOnlyIfOnScreen() }
  }

  private var capturedBeforeAppearance: Bool?
  private var capturedContentPopBeforeAppearance: Bool?
  private weak var hostViewController: UIViewController?

  public init() {}

  public func viewWillAppear(on viewController: UIViewController) {
    hostViewController = viewController
    guard let navigationController = viewController.navigationController else { return }
    let captured = FKBaseNavigationInteractivePopGestureControl.captureEnabledStates(from: navigationController)
    capturedBeforeAppearance = captured.pop
    capturedContentPopBeforeAppearance = captured.contentPop
    FKBaseNavigationInteractivePopGestureControl.apply(
      allowPop: !disablesInteractivePopGesture,
      on: navigationController
    )
  }

  public func viewWillDisappear(on viewController: UIViewController) {
    guard FKBaseViewControllerHierarchy.isLeavingPermanently(viewController) else { return }
    hostViewController = nil
    if let navigationController = viewController.navigationController {
      FKBaseNavigationInteractivePopGestureControl.restore(
        popEnabled: capturedBeforeAppearance,
        contentPopEnabled: capturedContentPopBeforeAppearance,
        on: navigationController
      )
    }
    capturedBeforeAppearance = nil
    capturedContentPopBeforeAppearance = nil
  }

  func synchronizeAfterNavigationChromeChange(on viewController: UIViewController) {
    guard let navigationController = viewController.navigationController, viewController.viewIfLoaded?.window != nil else {
      return
    }
    FKBaseNavigationInteractivePopGestureControl.apply(
      allowPop: !disablesInteractivePopGesture,
      on: navigationController
    )
  }

  private func applyOnlyIfOnScreen() {
    guard
      let hostViewController,
      hostViewController.isViewLoaded,
      hostViewController.view.window != nil,
      let navigationController = hostViewController.navigationController
    else { return }
    FKBaseNavigationInteractivePopGestureControl.apply(
      allowPop: !disablesInteractivePopGesture,
      on: navigationController
    )
  }
}

// MARK: - Tap to dismiss keyboard

@MainActor
public final class FKCompositeTapToDismissKeyboard: NSObject {
  public var isEnabled: Bool = true {
    didSet { updateGestureAttachment() }
  }

  private weak var host: UIViewController?
  private var didBind = false
  private lazy var gesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    gesture.cancelsTouchesInView = false
    return gesture
  }()

  public override init() {
    super.init()
  }

  /// Installs the gesture on `viewController.view` once per composite instance.
  public func bindIfNeeded(to viewController: UIViewController) {
    guard !didBind else { return }
    didBind = true
    host = viewController
    updateGestureAttachment()
  }

  @objc private func handleTap() {
    host?.view.endEditing(true)
  }

  private func updateGestureAttachment() {
    guard let view = host?.view, didBind else { return }
    if isEnabled {
      if gesture.view == nil {
        view.addGestureRecognizer(gesture)
      }
    } else if gesture.view != nil {
      view.removeGestureRecognizer(gesture)
    }
  }
}

// MARK: - Scroll bounce

public enum FKCompositeScrollBounce {
  public static func applyRecursively(to root: UIView, enabled: Bool) {
    FKBaseScrollBounce.applyRecursively(to: root, enabled: enabled)
  }
}
