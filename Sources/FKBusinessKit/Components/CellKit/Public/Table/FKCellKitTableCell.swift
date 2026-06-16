import UIKit

/// Shared flat-row chrome for CellKit table cells built on ``FKBaseTableViewCell``.
@MainActor
open class FKCellKitTableCell: FKBaseTableViewCell {
  /// Layout and selection styling applied to the reusable row container.
  public var cellConfiguration: FKCellKitTableCellConfiguration = .flatRow {
    didSet { applyCellConfiguration() }
  }

  open override func setupStyle() {
    super.setupStyle()
    applyCellConfiguration()
  }

  open override func selectionDidChange(isSelected: Bool, animated: Bool) {
    super.selectionDidChange(isSelected: isSelected, animated: animated)
    containerView.backgroundColor = isSelected
      ? cellConfiguration.selectedBackgroundColor
      : containerBackgroundColor
  }

  /// Applies ``cellConfiguration`` to container insets and selection chrome.
  public func applyCellConfiguration() {
    containerInsets = cellConfiguration.contentInsets
    if !isSelected {
      containerView.backgroundColor = containerBackgroundColor
    }
  }
}

/// Shared chrome for CellKit collection cells built on ``FKBaseCollectionViewCell``.
@MainActor
open class FKCellKitCollectionCell: FKBaseCollectionViewCell {
  /// Layout and selection styling applied to the reusable item container.
  public var cellConfiguration: FKCellKitTableCellConfiguration = .flatRow {
    didSet { applyCellConfiguration() }
  }

  open override func setupStyle() {
    super.setupStyle()
    applyCellConfiguration()
  }

  /// Applies ``cellConfiguration`` to container insets.
  public func applyCellConfiguration() {
    containerInsets = cellConfiguration.contentInsets
  }
}
