import FKUIKit
import UIKit

/// Placeholder context for ``FKCellKitUserListSkeletonTableCell`` (ListKit payload-free).
public struct FKCellKitUserListSkeletonContext: Equatable, Sendable {
  /// Creates a skeleton placeholder context.
  public init() {}
}

/// Skeleton table row matching ``FKUserListCell`` at a slightly shorter loading height.
@MainActor
public final class FKCellKitUserListSkeletonTableCell: FKSkeletonTableViewCell, FKListTableCellConfigurable {
  public typealias Item = FKCellKitUserListSkeletonContext

  /// Manual ``UITableView`` reuse identifier. Prefer ListKit registration via ``FKCellKitListRegistration/registerUserListSkeletonCell(on:)``.
  public static let reuseIdentifier = "FKBusinessKit.CellKit.UserListSkeleton"

  /// Registry key for ListKit custom skeleton rows.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended row height while skeleton placeholders are visible.
  public static let preferredRowHeight: CGFloat = 52

  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    skeletonContainer.usesUnifiedShimmer = false
    skeletonContainer.configuration = FKCellKitSkeletonLayout.breathingConfiguration
    applyCompactLayoutMargins()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    skeletonContainer.usesUnifiedShimmer = false
    skeletonContainer.configuration = FKCellKitSkeletonLayout.breathingConfiguration
    applyCompactLayoutMargins()
  }

  /// Applies the user-list skeleton layout and starts shimmer.
  public func configure(with item: FKCellKitUserListSkeletonContext) {
    _ = item
    FKCellKitSkeletonLayout.applyUserListRow(to: self)
    FKCellKitSkeletonLayout.showBreathingSkeleton(on: skeletonContainer)
  }

  public override func prepareForReuse() {
    super.prepareForReuse()
    skeletonContainer.hideSkeleton(animated: false)
    resetSkeletonContent()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    FKCellKitSkeletonLayout.showBreathingSkeleton(on: skeletonContainer)
  }

  private func applyCompactLayoutMargins() {
    preservesSuperviewLayoutMargins = false
    contentView.preservesSuperviewLayoutMargins = false
    layoutMargins = .zero
    contentView.layoutMargins = UIEdgeInsets(
      top: FKCellKitLayoutMetrics.verticalInset,
      left: FKCellKitLayoutMetrics.horizontalInset,
      bottom: FKCellKitLayoutMetrics.verticalInset,
      right: FKCellKitLayoutMetrics.horizontalInset
    )
  }
}
