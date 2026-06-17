import FKUIKit
import UIKit

/// Placeholder context for ``FKCellKitMediaTileSkeletonCollectionCell``.
public struct FKCellKitMediaTileSkeletonContext: Equatable, Sendable {
  /// Creates a skeleton placeholder context.
  public init() {}
}

/// Skeleton collection cell whose layout matches ``FKMediaTileCell``.
@MainActor
public final class FKCellKitMediaTileSkeletonCollectionCell: FKSkeletonCollectionViewCell, FKListCollectionCellConfigurable {
  public typealias Item = FKCellKitMediaTileSkeletonContext

  /// Manual ``UICollectionView`` reuse identifier. Prefer ListKit registration via ``FKCellKitListRegistration/registerMediaTileSkeletonCell(on:)``.
  public static let reuseIdentifier = "FKBusinessKit.CellKit.MediaTileSkeleton"

  /// Registry key for ListKit custom skeleton items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended tile size while skeleton placeholders are visible.
  public static var preferredItemSize: CGSize { FKMediaTileCellConfiguration.defaultItemSize }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    skeletonContainer.usesUnifiedShimmer = false
    skeletonContainer.configuration = FKCellKitSkeletonLayout.breathingConfiguration
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    skeletonContainer.usesUnifiedShimmer = false
    skeletonContainer.configuration = FKCellKitSkeletonLayout.breathingConfiguration
  }

  /// Applies the media tile skeleton layout and starts shimmer.
  public func configure(with item: FKCellKitMediaTileSkeletonContext) {
    _ = item
    FKCellKitSkeletonLayout.applyMediaTile(to: self)
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
}
