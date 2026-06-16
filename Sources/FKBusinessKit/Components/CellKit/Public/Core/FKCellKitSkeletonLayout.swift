import FKUIKit
import UIKit

/// Skeleton placeholder layouts aligned with CellKit row templates.
public enum FKCellKitSkeletonLayout {
  /// Shared breathing animation configuration for CellKit skeleton hosts.
  @MainActor
  public static var breathingConfiguration: FKSkeletonConfiguration {
    var configuration = FKSkeleton.defaultConfiguration
    configuration.animationMode = .breathing
    configuration.animationDuration = 1.2
    configuration.breathingMinOpacity = 0.35
    return configuration
  }

  /// Applies ``breathingConfiguration`` and starts skeleton motion when bounds are valid.
  @MainActor
  public static func showBreathingSkeleton(on container: FKSkeletonContainerView) {
    let configuration = breathingConfiguration
    container.usesUnifiedShimmer = false
    container.configuration = configuration
    guard container.bounds.width > 1,
          container.bounds.height > 1,
          container.skeletonSubviews.isEmpty == false else { return }
    container.skeletonSubviews.forEach {
      $0.configuration = configuration
      $0.isShimmerSuppressed = false
    }
    container.showSkeleton(animated: false)
  }

  /// Avatar + two text lines matching ``FKUserListCell`` / ``FKUserListLeadingView``.
  @MainActor
  public static func applyUserListRow(to cell: FKSkeletonTableViewCell) {
    cell.resetSkeletonContent()
    let container = cell.skeletonContainer
    let avatar = FKSkeletonView()
    avatar.layer.cornerRadius = FKAvatarSize.s.diameter / 2
    let titleLine = FKSkeletonView()
    titleLine.layer.cornerRadius = 4
    let subtitleLine = FKSkeletonView()
    subtitleLine.layer.cornerRadius = 4
    let trailingLine = FKSkeletonView()
    trailingLine.layer.cornerRadius = 4
    [avatar, titleLine, subtitleLine, trailingLine].forEach { container.addSkeletonSubview($0) }

    let avatarSize = FKAvatarSize.s.diameter
    let spacing = FKCellKitLayoutMetrics.interPartSpacing
    let titleHeight: CGFloat = 12
    let subtitleHeight: CGFloat = 10
    let trailingHeight: CGFloat = 10

    NSLayoutConstraint.activate([
      avatar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      avatar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      avatar.widthAnchor.constraint(equalToConstant: avatarSize),
      avatar.heightAnchor.constraint(equalToConstant: avatarSize),

      titleLine.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: spacing),
      titleLine.trailingAnchor.constraint(lessThanOrEqualTo: trailingLine.leadingAnchor, constant: -8),
      titleLine.heightAnchor.constraint(equalToConstant: titleHeight),
      titleLine.bottomAnchor.constraint(equalTo: container.centerYAnchor, constant: -2),

      subtitleLine.leadingAnchor.constraint(equalTo: titleLine.leadingAnchor),
      subtitleLine.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.35),
      subtitleLine.heightAnchor.constraint(equalToConstant: subtitleHeight),
      subtitleLine.topAnchor.constraint(equalTo: container.centerYAnchor, constant: 2),

      trailingLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      trailingLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      trailingLine.widthAnchor.constraint(equalToConstant: 36),
      trailingLine.heightAnchor.constraint(equalToConstant: trailingHeight),
    ])
  }

  /// Rounded square tile matching ``FKMediaTileCell``.
  @MainActor
  public static func applyMediaTile(to cell: FKSkeletonCollectionViewCell) {
    cell.resetSkeletonContent()
    let tile = FKSkeletonView()
    tile.layer.cornerRadius = 8
    cell.skeletonContainer.addSkeletonSubview(tile)
    NSLayoutConstraint.activate([
      tile.topAnchor.constraint(equalTo: cell.skeletonContainer.topAnchor),
      tile.leadingAnchor.constraint(equalTo: cell.skeletonContainer.leadingAnchor),
      tile.trailingAnchor.constraint(equalTo: cell.skeletonContainer.trailingAnchor),
      tile.bottomAnchor.constraint(equalTo: cell.skeletonContainer.bottomAnchor),
    ])
  }
}
