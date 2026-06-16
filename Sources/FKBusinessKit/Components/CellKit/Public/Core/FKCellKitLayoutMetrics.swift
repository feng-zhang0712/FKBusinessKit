import CoreGraphics
import UIKit

/// Shared spacing constants for CellKit row layouts.
public enum FKCellKitLayoutMetrics {
  /// Default horizontal inset for flat table rows.
  public static let horizontalInset: CGFloat = 16
  /// Default vertical inset for flat table rows.
  public static let verticalInset: CGFloat = 10
  /// Spacing between leading avatar and text stack.
  public static let interPartSpacing: CGFloat = 12
  /// Spacing between title and subtitle labels.
  public static let titleSubtitleSpacing: CGFloat = 4
  /// Spacing inside trailing stacks.
  public static let trailingStackSpacing: CGFloat = 6
  /// Minimum row height aligned with HIG.
  public static let minimumRowHeight: CGFloat = 44
  /// Default leading symbol container side for icon-based list rows.
  public static let defaultLeadingSymbolSide: CGFloat = 40
  /// SF Symbol point size as a fraction of ``defaultLeadingSymbolSide`` (matches ``FKIconViewSize/l``).
  public static let leadingSymbolPointScale: CGFloat = 17 / 32

  /// Priority for minimum content-height constraints so UITableView's 44pt estimate pass does not log conflicts.
  public static let minimumContentHeightConstraintPriority = UILayoutPriority(999)

  /// Minimum ``UITableView`` row height that fits ``minimumRowHeight`` inside default flat-row vertical insets.
  public static func minimumTableRowHeight(verticalInsets: CGFloat = verticalInset * 2) -> CGFloat {
    minimumRowHeight + verticalInsets
  }

  /// Minimum content height constraint (44pt HIG) with a sub-required priority for table estimation layouts.
  @MainActor
  public static func minimumContentHeightConstraint(for dimension: NSLayoutDimension) -> NSLayoutConstraint {
    let constraint = dimension.constraint(greaterThanOrEqualToConstant: minimumRowHeight)
    constraint.priority = minimumContentHeightConstraintPriority
    return constraint
  }
}
