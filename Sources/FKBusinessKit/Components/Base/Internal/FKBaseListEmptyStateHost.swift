import FKUIKit
import UIKit

/// Applies ``FKEmptyState`` on a fixed host while clearing stale scroll-view overlays.
@MainActor
enum FKBaseListEmptyStateHost {

  static func apply(
    _ configuration: FKEmptyStateConfiguration,
    on hostView: UIView,
    clearingScrollView: UIScrollView?,
    animated: Bool,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    clearingScrollView?.fk_hideEmptyState(animated: false)
    hostView.fk_applyEmptyState(configuration, animated: animated, actionHandler: actionHandler)
    bringOverlayToFront(in: hostView)
  }

  static func sync(
    itemCount: Int,
    configuration: FKEmptyStateConfiguration,
    on hostView: UIView,
    clearingScrollView: UIScrollView?,
    animated: Bool,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    clearingScrollView?.fk_hideEmptyState(animated: false)
    var resolved = configuration
    if itemCount > 0 {
      resolved.phase = .content
    } else if resolved.phase == .content {
      resolved.phase = .empty
    }
    hostView.fk_applyEmptyState(resolved, animated: animated, actionHandler: actionHandler)
    bringOverlayToFront(in: hostView)
  }

  static func hide(
    on hostView: UIView,
    clearingScrollView: UIScrollView?,
    animated: Bool
  ) {
    clearingScrollView?.fk_hideEmptyState(animated: false)
    hostView.fk_hideEmptyState(animated: animated)
  }

  private static func bringOverlayToFront(in hostView: UIView) {
    guard let overlay = hostView.fk_emptyStateView, hostView.fk_isEmptyStateOverlayVisible else { return }
    hostView.bringSubviewToFront(overlay)
  }
}
