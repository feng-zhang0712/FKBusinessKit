import UIKit

// MARK: - Control

/// Direct helpers for enabling, capturing, and restoring interactive-pop gesture state.
enum FKBaseNavigationInteractivePopGestureControl {
  static func apply(allowPop: Bool, on navigationController: UINavigationController) {
    navigationController.interactivePopGestureRecognizer?.isEnabled = allowPop
    if #available(iOS 26.0, *) {
      navigationController.interactiveContentPopGestureRecognizer?.isEnabled = allowPop
    }
  }

  static func captureEnabledStates(
    from navigationController: UINavigationController
  ) -> (pop: Bool?, contentPop: Bool?) {
    let pop = navigationController.interactivePopGestureRecognizer?.isEnabled
    var contentPop: Bool?
    if #available(iOS 26.0, *) {
      contentPop = navigationController.interactiveContentPopGestureRecognizer?.isEnabled
    }
    return (pop, contentPop)
  }

  static func restore(
    popEnabled: Bool?,
    contentPopEnabled: Bool?,
    on navigationController: UINavigationController
  ) {
    if let popEnabled {
      navigationController.interactivePopGestureRecognizer?.isEnabled = popEnabled
    }
    if #available(iOS 26.0, *) {
      if let contentPopEnabled {
        navigationController.interactiveContentPopGestureRecognizer?.isEnabled = contentPopEnabled
      }
    }
  }
}

// MARK: - Policy

@MainActor
enum FKBaseNavigationInteractivePopGesturePolicy {
  static func topViewControllerDisablesPop(on navigationController: UINavigationController) -> Bool {
    guard let top = navigationController.topViewController else { return false }
    if let base = top as? FKBaseViewController {
      return base.disablesInteractivePopGesture
    }
    if let hosting = top as? FKViewControllerCompositeHosting {
      return hosting.composite.interactivePopGesture.disablesInteractivePopGesture
    }
    return false
  }
}

// MARK: - Delegate installer

/// Installs a forwarding `UIGestureRecognizerDelegate` once per `UINavigationController` so interactive pop
/// policy is enforced even when `isEnabled` is reset by UIKit. On iOS 26+, the same delegate is attached to
/// ``UINavigationController/interactiveContentPopGestureRecognizer``.
@MainActor
enum FKBaseNavigationInteractivePopGestureInstaller {
  private static let installs = NSMapTable<AnyObject, AnyObject>(
    keyOptions: .weakMemory,
    valueOptions: .strongMemory
  )

  static func installIfNeeded(on navigationController: UINavigationController) {
    guard let pop = navigationController.interactivePopGestureRecognizer else { return }
    if installs.object(forKey: navigationController) != nil { return }
    if pop.delegate is FKBaseNavigationInteractivePopGestureDelegate { return }

    var originalContentPopDelegate: UIGestureRecognizerDelegate?
    if #available(iOS 26.0, *) {
      originalContentPopDelegate =
        navigationController.interactiveContentPopGestureRecognizer?.delegate as? UIGestureRecognizerDelegate
    }

    let interceptor = FKBaseNavigationInteractivePopGestureDelegate(
      navigationController: navigationController,
      originalPopGestureDelegate: pop.delegate as? UIGestureRecognizerDelegate,
      originalContentPopGestureDelegate: originalContentPopDelegate
    )
    pop.delegate = interceptor
    if #available(iOS 26.0, *) {
      navigationController.interactiveContentPopGestureRecognizer?.delegate = interceptor
    }
    installs.setObject(interceptor, forKey: navigationController)
  }
}

@MainActor
final class FKBaseNavigationInteractivePopGestureDelegate: NSObject, UIGestureRecognizerDelegate {
  weak var navigationController: UINavigationController?
  weak var originalPopGestureDelegate: UIGestureRecognizerDelegate?
  weak var originalContentPopGestureDelegate: UIGestureRecognizerDelegate?

  init(
    navigationController: UINavigationController,
    originalPopGestureDelegate: UIGestureRecognizerDelegate?,
    originalContentPopGestureDelegate: UIGestureRecognizerDelegate?
  ) {
    self.navigationController = navigationController
    self.originalPopGestureDelegate = originalPopGestureDelegate
    self.originalContentPopGestureDelegate = originalContentPopGestureDelegate
    super.init()
  }

  @MainActor
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let navigationController else { return false }
    if FKBaseNavigationInteractivePopGesturePolicy.topViewControllerDisablesPop(on: navigationController) {
      return false
    }

    if gestureRecognizer === navigationController.interactivePopGestureRecognizer {
      if let originalPopGestureDelegate {
        return originalPopGestureDelegate.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
      }
      return navigationController.viewControllers.count > 1
    }

    if #available(iOS 26.0, *) {
      if gestureRecognizer === navigationController.interactiveContentPopGestureRecognizer {
        if let originalContentPopGestureDelegate {
          return originalContentPopGestureDelegate.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
        }
        return navigationController.viewControllers.count > 1
      }
    }

    return true
  }
}
