import UIKit

/// Helpers for enforcing the base controller’s scroll-bounce defaults.
enum FKBaseScrollBounce {
  /// Recursively applies the same bounce setting to every scroll view in the view subtree.
  ///
  /// This is used as a conservative default so nested collection/table/scroll views inherit the
  /// controller’s bounce policy without each screen needing custom plumbing.
  static func applyRecursively(to root: UIView, enabled: Bool) {
    if let scrollView = root as? UIScrollView {
      scrollView.bounces = enabled
      scrollView.alwaysBounceVertical = enabled
      scrollView.alwaysBounceHorizontal = enabled
    }
    root.subviews.forEach { applyRecursively(to: $0, enabled: enabled) }
  }
}
