import UIKit

/// Optional visibility hooks for CellKit cells; forward from ``FKListDelegate`` `willDisplay` / `didEndDisplaying`.
@MainActor
public protocol FKListCellVisibilityHandling: AnyObject {
  /// Called when the cell is about to become visible.
  func cellWillDisplay()
  /// Called when the cell scrolled off screen.
  func cellDidEndDisplaying()
}
