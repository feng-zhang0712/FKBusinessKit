import FKUIKit

/// Optional video visibility hooks for CellKit cells with embedded ``FKVideoPlayerView``.
///
/// Forward from ``FKListDelegate`` using ``FKCellKitVideoVisibilityForwarder``.
@MainActor
public protocol FKListCellVideoVisibilityHandling: AnyObject {
  /// Binds a pooled player, loads content, and registers with the ListKit video coordinator.
  func cellWillDisplayVideo(coordinator: FKListVideoVisibilityCoordinator, pool: FKVideoPlayerPool)
  /// Unregisters the player view and returns the pooled player during reuse.
  func cellDidEndDisplayingVideo(coordinator: FKListVideoVisibilityCoordinator, pool: FKVideoPlayerPool)
}
