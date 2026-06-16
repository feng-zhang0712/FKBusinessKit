import FKUIKit
import UIKit

/// Forwards ListKit visibility callbacks to CellKit video cells and ``FKListVideoVisibilityCoordinator``.
public enum FKCellKitVideoVisibilityForwarder {
  /// Notifies a visible table cell that it will display and binds video playback when applicable.
  @MainActor
  public static func forwardWillDisplay(
    at indexPath: IndexPath,
    in tableView: UITableView,
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    if let videoCell = tableView.cellForRow(at: indexPath) as? FKListCellVideoVisibilityHandling {
      videoCell.cellWillDisplayVideo(coordinator: coordinator, pool: pool)
    }
    FKCellKitVisibilityForwarder.forwardWillDisplay(at: indexPath, in: tableView)
  }

  /// Notifies a table cell that it ended displaying and tears down video playback when applicable.
  @MainActor
  public static func forwardDidEndDisplaying(
    at indexPath: IndexPath,
    in tableView: UITableView,
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    if let videoCell = tableView.cellForRow(at: indexPath) as? FKListCellVideoVisibilityHandling {
      videoCell.cellDidEndDisplayingVideo(coordinator: coordinator, pool: pool)
    }
    FKCellKitVisibilityForwarder.forwardDidEndDisplaying(at: indexPath, in: tableView)
  }

  /// Notifies a visible collection cell that it will display and binds video playback when applicable.
  @MainActor
  public static func forwardWillDisplay(
    at indexPath: IndexPath,
    in collectionView: UICollectionView,
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    if let videoCell = collectionView.cellForItem(at: indexPath) as? FKListCellVideoVisibilityHandling {
      videoCell.cellWillDisplayVideo(coordinator: coordinator, pool: pool)
    }
    FKCellKitVisibilityForwarder.forwardWillDisplay(at: indexPath, in: collectionView)
  }

  /// Notifies a collection cell that it ended displaying and tears down video playback when applicable.
  @MainActor
  public static func forwardDidEndDisplaying(
    at indexPath: IndexPath,
    in collectionView: UICollectionView,
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    if let videoCell = collectionView.cellForItem(at: indexPath) as? FKListCellVideoVisibilityHandling {
      videoCell.cellDidEndDisplayingVideo(coordinator: coordinator, pool: pool)
    }
    FKCellKitVisibilityForwarder.forwardDidEndDisplaying(at: indexPath, in: collectionView)
  }
}

/// Attaches ListKit video visibility coordination to a diffable table controller.
public enum FKCellKitVideoSetup {
  /// Creates a coordinator, binds it to the controller scroll view, and stores it on the controller.
  @MainActor
  public static func attachVideoVisibility(
    to controller: FKDiffableTableViewController,
    pool: FKVideoPlayerPool = FKVideoPlayerPool()
  ) -> FKListVideoVisibilityCoordinator {
    let coordinator = FKListVideoVisibilityCoordinator(pool: pool)
    controller.videoVisibilityCoordinator = coordinator
    coordinator.bind(scrollView: controller.tableView)
    return coordinator
  }

  /// Creates a coordinator, binds it to the controller scroll view, and stores it on the controller.
  @MainActor
  public static func attachVideoVisibility(
    to controller: FKDiffableCollectionViewController,
    pool: FKVideoPlayerPool = FKVideoPlayerPool()
  ) -> FKListVideoVisibilityCoordinator {
    let coordinator = FKListVideoVisibilityCoordinator(pool: pool)
    controller.videoVisibilityCoordinator = coordinator
    coordinator.bind(scrollView: controller.collectionView)
    return coordinator
  }
}

/// Default ``FKListDelegate`` video visibility forwarding for CellKit table lists.
public extension FKListDelegate where Self: FKDiffableTableViewController {
  /// Forwards `willDisplay` to CellKit video cells at `indexPath`.
  @MainActor
  func forwardCellKitVideoVisibilityWillDisplay(
    at indexPath: IndexPath,
    pool: FKVideoPlayerPool
  ) {
    guard let coordinator = videoVisibilityCoordinator else { return }
    FKCellKitVideoVisibilityForwarder.forwardWillDisplay(
      at: indexPath,
      in: tableView,
      coordinator: coordinator,
      pool: pool
    )
  }

  /// Forwards `didEndDisplaying` to CellKit video cells at `indexPath`.
  @MainActor
  func forwardCellKitVideoVisibilityDidEndDisplaying(
    at indexPath: IndexPath,
    pool: FKVideoPlayerPool
  ) {
    guard let coordinator = videoVisibilityCoordinator else { return }
    FKCellKitVideoVisibilityForwarder.forwardDidEndDisplaying(
      at: indexPath,
      in: tableView,
      coordinator: coordinator,
      pool: pool
    )
  }
}

/// Default ``FKListCollectionDelegate`` video visibility forwarding for CellKit collection lists.
public extension FKListCollectionDelegate where Self: FKDiffableCollectionViewController {
  /// Forwards `willDisplay` to CellKit video cells at `indexPath`.
  @MainActor
  func forwardCellKitVideoVisibilityWillDisplay(
    at indexPath: IndexPath,
    pool: FKVideoPlayerPool
  ) {
    guard let coordinator = videoVisibilityCoordinator else { return }
    FKCellKitVideoVisibilityForwarder.forwardWillDisplay(
      at: indexPath,
      in: collectionView,
      coordinator: coordinator,
      pool: pool
    )
  }

  /// Forwards `didEndDisplaying` to CellKit video cells at `indexPath`.
  @MainActor
  func forwardCellKitVideoVisibilityDidEndDisplaying(
    at indexPath: IndexPath,
    pool: FKVideoPlayerPool
  ) {
    guard let coordinator = videoVisibilityCoordinator else { return }
    FKCellKitVideoVisibilityForwarder.forwardDidEndDisplaying(
      at: indexPath,
      in: collectionView,
      coordinator: coordinator,
      pool: pool
    )
  }
}
