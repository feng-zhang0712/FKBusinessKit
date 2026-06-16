import FKUIKit
import UIKit

/// Forwards ListKit visibility callbacks to CellKit cells conforming to ``FKListCellVisibilityHandling``.
public enum FKCellKitVisibilityForwarder {
  /// Notifies a visible table cell that it will display.
  @MainActor
  public static func forwardWillDisplay(
    at indexPath: IndexPath,
    in tableView: UITableView
  ) {
    (tableView.cellForRow(at: indexPath) as? FKListCellVisibilityHandling)?.cellWillDisplay()
  }

  /// Notifies a table cell that it ended displaying.
  @MainActor
  public static func forwardDidEndDisplaying(
    at indexPath: IndexPath,
    in tableView: UITableView
  ) {
    (tableView.cellForRow(at: indexPath) as? FKListCellVisibilityHandling)?.cellDidEndDisplaying()
  }

  /// Notifies a visible collection cell that it will display.
  @MainActor
  public static func forwardWillDisplay(
    at indexPath: IndexPath,
    in collectionView: UICollectionView
  ) {
    (collectionView.cellForItem(at: indexPath) as? FKListCellVisibilityHandling)?.cellWillDisplay()
  }

  /// Notifies a collection cell that it ended displaying.
  @MainActor
  public static func forwardDidEndDisplaying(
    at indexPath: IndexPath,
    in collectionView: UICollectionView
  ) {
    (collectionView.cellForItem(at: indexPath) as? FKListCellVisibilityHandling)?.cellDidEndDisplaying()
  }
}

/// Default ``FKListDelegate`` visibility forwarding for CellKit table lists.
public extension FKListDelegate where Self: FKDiffableTableViewController {
  /// Forwards `willDisplay` to CellKit cells at `indexPath`.
  @MainActor
  func forwardCellKitVisibilityWillDisplay(at indexPath: IndexPath) {
    FKCellKitVisibilityForwarder.forwardWillDisplay(at: indexPath, in: tableView)
  }

  /// Forwards `didEndDisplaying` to CellKit cells at `indexPath`.
  @MainActor
  func forwardCellKitVisibilityDidEndDisplaying(at indexPath: IndexPath) {
    FKCellKitVisibilityForwarder.forwardDidEndDisplaying(at: indexPath, in: tableView)
  }
}

/// Default ``FKListCollectionDelegate`` visibility forwarding for CellKit collection lists.
public extension FKListCollectionDelegate where Self: FKDiffableCollectionViewController {
  /// Forwards `willDisplay` to CellKit cells at `indexPath`.
  @MainActor
  func forwardCellKitVisibilityWillDisplay(at indexPath: IndexPath) {
    FKCellKitVisibilityForwarder.forwardWillDisplay(at: indexPath, in: collectionView)
  }

  /// Forwards `didEndDisplaying` to CellKit cells at `indexPath`.
  @MainActor
  func forwardCellKitVisibilityDidEndDisplaying(at indexPath: IndexPath) {
    FKCellKitVisibilityForwarder.forwardDidEndDisplaying(at: indexPath, in: collectionView)
  }
}
