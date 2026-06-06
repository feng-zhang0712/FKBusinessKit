import UIKit

/// Small hierarchy predicates used by the base controller/composition layer.
enum FKBaseViewControllerHierarchy {
  /// Returns `true` when the controller is being dismissed, popped, or removed from its parent.
  ///
  /// This deliberately excludes the common "another controller was pushed on top" case, so callers
  /// can restore state only when the controller is actually leaving the stack or being torn down.
  static func isLeavingPermanently(_ viewController: UIViewController) -> Bool {
    viewController.isBeingDismissed || viewController.isMovingFromParent
  }
}
