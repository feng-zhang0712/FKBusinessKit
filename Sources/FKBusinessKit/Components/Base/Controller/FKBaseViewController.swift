import FKCoreKit
import FKUIKit
import UIKit

/// A lightweight `UIViewController` base that centralizes common UIKit patterns:
/// lifecycle entry points, optional state overlays, keyboard forwarding, navigation chrome
/// snapshot/restore, and analytics-friendly hooks without hard-wiring a specific architecture.
///
/// Cross-cutting behaviors (keyboard, navigation chrome, interactive pop, tap-to-dismiss) are
/// implemented via an internal ``FKViewControllerComposite`` so plain `UIViewController` adopters
/// can opt into the same logic without subclassing.
@MainActor
open class FKBaseViewController: UIViewController, FKViewControllerCompositeHosting {

  // MARK: - Public types

  /// Visibility of the navigation bar while this view controller is visible.
  public enum NavigationBarVisibility {
    case visible
    case hidden
  }

  /// Navigation bar chrome applied while this view controller is visible.
  ///
  /// Custom styles (``opaqueDefault``, ``transparent``, ``gradient``) apply to this controller’s
  /// ``UINavigationItem`` so `UINavigationController` can interpolate during interactive transitions.
  ///
  /// ``system`` clears those per-item overrides and restores the navigation **bar** from the snapshot
  /// captured on this controller’s first ``viewWillAppear`` (deep-copied appearances, translucency,
  /// and compact scroll-edge when available). When no snapshot exists, ``system`` only clears the item
  /// overrides.
  public enum NavigationBarStyle {
    case system
    case opaqueDefault
    case transparent
    case gradient(
      colors: [UIColor],
      locations: [NSNumber]? = nil,
      startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
      endPoint: CGPoint = CGPoint(x: 1.0, y: 0.0)
    )
  }

  // MARK: - Composite hosting

  /// Shared composition bucket backing keyboard, navigation chrome, and related cross-cutting behavior.
  public let composite = FKViewControllerComposite()

  // MARK: - Public configuration

  /// When `true`, taps outside of the first responder dismiss the keyboard.
  public var dismissKeyboardOnTapEnabled: Bool = true {
    didSet {
      composite.tapToDismissKeyboard.isEnabled = dismissKeyboardOnTapEnabled
    }
  }

  /// When `true`, recursively disables vertical/horizontal bounce on scroll views in `view`'s subtree.
  public var disableScrollViewBounceByDefault: Bool = true {
    didSet {
      composite.disablesScrollBounceRecursivelyByDefault = disableScrollViewBounceByDefault
    }
  }

  /// When `true`, disables the navigation controller's interactive pop gesture while this controller is visible.
  ///
  /// On recent iOS releases, toggling `interactivePopGestureRecognizer.isEnabled` alone is not always honored.
  /// From iOS 26, ``UINavigationController/interactiveContentPopGestureRecognizer`` also drives interactive pops and
  /// must be toggled together with ``UINavigationController/interactivePopGestureRecognizer``.
  /// ``FKBaseViewController`` installs a one-time gesture delegate on the parent ``UINavigationController`` that
  /// consults the top ``FKBaseViewController`` and returns `false` from `gestureRecognizerShouldBegin` while
  /// this flag is `true`, forwarding other cases to UIKit’s original delegate. On iOS 26+, the same policy is
  /// applied to ``UINavigationController/interactiveContentPopGestureRecognizer`` in addition to
  /// ``UINavigationController/interactivePopGestureRecognizer``.
  public var disablesInteractivePopGesture: Bool = false {
    didSet {
      composite.interactivePopGesture.disablesInteractivePopGesture = disablesInteractivePopGesture
    }
  }

  /// Navigation bar visibility while this controller is on-screen (restored when leaving).
  public var navigationBarVisibility: NavigationBarVisibility = .visible {
    didSet {
      composite.navigationChrome.visibility = navigationBarVisibility
    }
  }

  /// Navigation bar appearance while this controller is on-screen (restored when leaving).
  public var navigationBarStyle: NavigationBarStyle = .system {
    didSet {
      composite.navigationChrome.style = navigationBarStyle
    }
  }

  /// Preferred status bar style for this controller.
  public var preferredStatusBarAppearance: UIStatusBarStyle = .default {
    didSet {
      setNeedsStatusBarAppearanceUpdate()
      navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
  }

  /// When `false`, keyboard notifications are not observed.
  public var keyboardObservationEnabled: Bool = true {
    didSet {
      composite.keyboard.isEnabled = keyboardObservationEnabled
    }
  }

  /// When `true` and ``keyboardFocusScrollView`` is non-nil, scrolls the focused input into view after keyboard frame changes.
  public var scrollsFirstResponderVisibleOnKeyboardChange: Bool = true

  /// When non-nil, this scroll view's first responder is scrolled above the keyboard on ``keyboardWillChange(to:duration:curve:)``.
  ///
  /// ``FKBaseScrollViewController`` and ``FKBaseCollectionViewController`` override this to return their primary scroll view.
  /// ``FKBaseTableViewController`` leaves the default `nil` and relies on ``UITableView``'s built-in editing scroll.
  open var keyboardFocusScrollView: UIScrollView? { nil }

  /// When non-nil, assigns `UINavigationBar.prefersLargeTitles` while visible (restored when leaving).
  public var prefersLargeTitlesWhileVisible: Bool? {
    didSet {
      composite.navigationChrome.prefersLargeTitlesWhileVisible = prefersLargeTitlesWhileVisible
    }
  }

  /// Optional hook for analytics or diagnostics without coupling to a concrete SDK.
  public var logHandler: (@MainActor (String, [String: String]) -> Void)?

  /// When `true`, forwards lifecycle markers to ``FKLogger`` at the `.debug` level (in addition to ``logHandler``).
  public var debugLifecycleLoggingEnabled: Bool = false

  // MARK: - Public state

  /// `true` after the first `viewDidAppear(_:)`.
  public var hasCompletedInitialAppearance: Bool {
    composite.appearanceState.hasCompletedInitialAppearance
  }

  /// `true` between `viewDidAppear` and `viewWillDisappear`.
  public var isViewAppeared: Bool {
    composite.appearanceState.isViewAppeared
  }

  // MARK: - Internal overlay storage

  let loadingView = UIActivityIndicatorView(style: .large)
  let emptyStateView = FKEmptyStateView()
  var hasPerformedBaseSetup = false

  // MARK: - Init

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - Lifecycle

  open override func viewDidLoad() {
    super.viewDidLoad()
    performBaseSetupIfNeeded()
    syncCompositeConfiguration()
    wireCompositeCallbacksIfNeeded()
    composite.forward(.viewDidLoad, for: self)
    setupUI()
    setupConstraints()
    setupBindings()
    logLifecycleEvent("viewDidLoad")
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    composite.forward(.viewWillAppear(animated: animated), for: self)
    logLifecycleEvent("viewWillAppear")
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    composite.forward(.viewDidAppear(animated: animated), for: self)
    logLifecycleEvent("viewDidAppear")
  }

  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    composite.forward(.viewWillDisappear(animated: animated), for: self)
    logLifecycleEvent("viewWillDisappear")
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    composite.forward(.viewDidDisappear, for: self)
    logLifecycleEvent("viewDidDisappear")
  }

  open override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    view.setNeedsLayout()
  }

  open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    traitCollectionDidChangeHandling(previousTraitCollection)
  }

  // MARK: - Overridable entry points

  /// Builds the view hierarchy. Prefer lightweight work here; defer heavy I/O to async layers.
  open func setupUI() {}

  /// Activates layout constraints for views created in ``setupUI()``.
  open func setupConstraints() {}

  /// Binds view models, user actions, and subscriptions.
  open func setupBindings() {}

  /// Called exactly once on the first `viewDidAppear(_:)`, **before** ``viewDidAppearForTheFirstTime(_:)``.
  ///
  /// Override to kick off first-page loads or subscriptions. Prefer async work; do not block the main thread.
  open func loadInitialContent() {}

  /// Called once after the first `viewDidAppear(_:)`, immediately after ``loadInitialContent()``.
  ///
  /// Use for UI that must run only after the view is on-screen (e.g. intro animations).
  open func viewDidAppearForTheFirstTime(_ animated: Bool) {}

  /// Keyboard frame updates (parsed on the main queue).
  ///
  /// When ``keyboardFocusScrollView`` is non-nil and ``scrollsFirstResponderVisibleOnKeyboardChange`` is `true`,
  /// scrolls the current first responder into view after layout catches up with ``keyboardLayoutGuide``.
  /// Override for custom behavior; call `super` to keep that scrolling, or leave ``keyboardFocusScrollView`` as `nil`
  /// for hook-only forwarding (the default on plain ``FKBaseViewController`` subclasses).
  open func keyboardWillChange(to frame: CGRect, duration: TimeInterval, curve: UIView.AnimationCurve) {
    guard scrollsFirstResponderVisibleOnKeyboardChange, let scrollView = keyboardFocusScrollView else { return }
    FKBaseScrollKeyboardFocus.scrollFirstResponderAfterKeyboardChange(
      in: scrollView,
      hostView: view,
      keyboardFrame: frame,
      duration: duration,
      curve: curve
    )
  }

  /// Keyboard will hide (parsed on the main queue).
  open func keyboardWillHide(duration: TimeInterval, curve: UIView.AnimationCurve) {}

  /// Supported orientations for this controller.
  open var allowedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }

  /// Preferred orientation when this controller is first presented.
  open var preferredInitialOrientation: UIInterfaceOrientation {
    .portrait
  }

  /// Respond to dynamic type, dark mode, and other trait changes.
  open func traitCollectionDidChangeHandling(_ previousTraitCollection: UITraitCollection?) {}

  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    allowedInterfaceOrientations
  }

  open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    preferredInitialOrientation
  }

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    preferredStatusBarAppearance
  }

  // MARK: - Public UI helpers

  /// Shows the loading indicator and hides empty/error overlays.
  public func showLoading() {
    hideEmptyView()
    hideErrorView()
    loadingView.startAnimating()
    loadingView.isHidden = false
  }

  /// Hides the loading indicator.
  public func hideLoading() {
    loadingView.stopAnimating()
    loadingView.isHidden = true
  }

  /// Shows a full-screen empty state overlay.
  public func showEmptyView(message: String = "No content available.") {
    hideLoading()
    hideErrorView()
    let configuration = FKEmptyStateConfiguration(
      phase: .empty,
      type: .empty,
      context: .fullPage,
      title: message,
      isImageHidden: true,
      isDescriptionHidden: true,
      isButtonHidden: true
    )
    emptyStateView.apply(configuration)
    emptyStateView.isHidden = false
  }

  /// Hides the empty state overlay.
  public func hideEmptyView() {
    emptyStateView.isHidden = true
  }

  /// Shows a full-screen error overlay with an optional retry action.
  public func showErrorView(
    message: String = "Something went wrong.",
    retryTitle: String? = nil,
    retryHandler: (@MainActor () -> Void)? = nil
  ) {
    hideLoading()
    hideEmptyView()
    let showsRetry = retryTitle != nil && retryHandler != nil
    let configuration = FKEmptyStateConfiguration(
      phase: showsRetry ? .error : .empty,
      type: .error,
      context: .fullPage,
      title: message,
      buttonStyle: FKEmptyStateButtonStyle(title: retryTitle),
      isImageHidden: true,
      isDescriptionHidden: true,
      isButtonHidden: !showsRetry
    )
    emptyStateView.actionHandler = showsRetry ? { _ in retryHandler?() } : nil
    emptyStateView.apply(configuration)
    emptyStateView.isHidden = false
  }

  /// Hides the error overlay.
  public func hideErrorView() {
    emptyStateView.isHidden = true
    emptyStateView.actionHandler = nil
  }

  /// Presents a short banner using ``FKToast`` defaults.
  public func showToast(_ message: String) {
    FKToast.show(message)
  }

  /// Installs a custom back button on the left navigation item.
  public func configureBackButton(image: UIImage? = nil, title: String? = nil, tintColor: UIColor? = nil) {
    let button = UIButton(type: .system)
    let symbolImage = image ?? UIImage(systemName: "chevron.backward")
    button.setImage(symbolImage, for: .normal)
    button.setTitle(title, for: .normal)
    button.tintColor = tintColor ?? view.tintColor
    button.setTitleColor(tintColor ?? view.tintColor, for: .normal)
    button.contentEdgeInsets = FKBaseUIConstants.backButtonContentInsets
    button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
  }

  /// Ends editing for the entire `view` subtree.
  public func dismissKeyboard() {
    view.endEditing(true)
  }

  // MARK: - Actions

  @objc private func handleBackButtonTapped() {
    if let navigationController, navigationController.viewControllers.first != self {
      navigationController.popViewController(animated: true)
    } else {
      dismiss(animated: true)
    }
  }
}
