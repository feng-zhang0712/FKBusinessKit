import UIKit
import FKBusinessKit

/// Root navigation catalog for CellKit examples.
enum FKCellKitExampleCatalog {
  static var rootSections: [FKCellKitExampleListSection] {
    [
      tableRowsSection,
      extendedSection,
      feedSection,
      collectionSection,
      integrationSection,
    ]
  }

  // MARK: - Table rows

  static var tableRowsSection: FKCellKitExampleListSection {
    FKCellKitExampleListSection(
      title: "Table rows (ListKit)",
      rows: [
        FKCellKitExampleListRow(
          title: "FKUserListCell",
          subtitle: "Presence, unread badge, role tag, verified avatar, refresh, and load-more."
        ) { FKCellKitUserListExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKOrderListCell",
          subtitle: "Copy chip, status pill, optional leading icon, and reconfigureItems status updates."
        ) { FKCellKitOrderListExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKNotificationListCell",
          subtitle: "Symbol, title, multi-line summary, timestamp, and unread dot."
        ) { FKCellKitNotificationListExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKSettingsProfileCell",
          subtitle: "Large avatar, account lines, and disclosure chevron."
        ) { FKCellKitSettingsProfileExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKAddressListCell",
          subtitle: "Recipient, phone, address block, default tag, and selection checkmark."
        ) { FKCellKitAddressListExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKPaymentMethodCell",
          subtitle: "Payment icon, title/subtitle, and trailing selection state."
        ) { FKCellKitPaymentMethodExampleViewController() },
      ]
    )
  }

  // MARK: - Extended rows

  static var extendedSection: FKCellKitExampleListSection {
    FKCellKitExampleListSection(
      title: "Extended rows (v2)",
      rows: [
        FKCellKitExampleListRow(
          title: "FKTimelineEventCell",
          subtitle: "Logistics timeline with connector column and FKFlowStepItem states."
        ) { FKCellKitTimelineExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKSearchResultCell + FKReviewListCell",
          subtitle: "Query highlight search hits and star-rated product reviews."
        ) { FKCellKitSearchReviewExampleViewController() },
        FKCellKitExampleListRow(
          title: "Cart & file attachment rows",
          subtitle: "FKCartLineItemCell, FKCartQuantityCell stepper, and FKFileAttachmentCell."
        ) { FKCellKitCartFilesExampleViewController() },
        FKCellKitExampleListRow(
          title: "Interactive custom rows",
          subtitle: "User select, inline toggle, tag picker, rating input, and invite code cells."
        ) { FKCellKitInteractiveRowsExampleViewController() },
      ]
    )
  }

  // MARK: - Feed & social

  static var feedSection: FKCellKitExampleListSection {
    FKCellKitExampleListSection(
      title: "Feed & social",
      rows: [
        FKCellKitExampleListRow(
          title: "FKFeedContentCell",
          subtitle: "Multi-line body, single-image and nine-grid layouts, FKListHeightCache row heights."
        ) { FKCellKitFeedContentExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKFeedVideoCell",
          subtitle: "Inline FKVideoPlayerView, FKVideoPlayerPool, and FKListVideoVisibilityCoordinator autoplay."
        ) { FKCellKitFeedVideoExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKCommentThreadCell",
          subtitle: "Indented comment tree, thread connector, reply summary, and dynamic heights."
        ) { FKCellKitCommentThreadExampleViewController() },
      ]
    )
  }

  // MARK: - Collection

  static var collectionSection: FKCellKitExampleListSection {
    FKCellKitExampleListSection(
      title: "Collection grid",
      rows: [
        FKCellKitExampleListRow(
          title: "FKProductGridCell",
          subtitle: "Two-column product grid, tag row, image prefetch, refresh, and load-more."
        ) { FKCellKitProductGridExampleViewController() },
        FKCellKitExampleListRow(
          title: "FKMediaTileCell",
          subtitle: "Square tiles with duration badge, selection overlay, and prefetch."
        ) { FKCellKitMediaTileExampleViewController() },
      ]
    )
  }

  // MARK: - Integration

  static var integrationSection: FKCellKitExampleListSection {
    FKCellKitExampleListSection(
      title: "Integration & infrastructure",
      rows: [
        FKCellKitExampleListRow(
          title: "Base table dequeue path",
          subtitle: "FKBaseTableViewController manually dequeues FKUserListCell without ListKit."
        ) { FKCellKitBaseTableUserListExampleViewController() },
        FKCellKitExampleListRow(
          title: "Mixed preset + custom rows",
          subtitle: "Single ListKit snapshot combining FKListPresetItem rows and FKUserListCell."
        ) { FKCellKitMixedPresetExampleViewController() },
        FKCellKitExampleListRow(
          title: "Visibility & image prefetch",
          subtitle: "FKCellKitVisibilityForwarder hooks and FKListImagePrefetchHelper warm-up."
        ) { FKCellKitVisibilityPrefetchExampleViewController() },
        FKCellKitExampleListRow(
          title: "Skeleton placeholders",
          subtitle: "CellKit skeleton table/collection cells before real payloads load."
        ) { FKCellKitSkeletonExampleViewController() },
        FKCellKitExampleListRow(
          title: "SwiftUI bridge",
          subtitle: "FKCellKitDiffableTableViewRepresentable embedding a CellKit-enabled list."
        ) { FKCellKitSwiftUIHostExampleViewController() },
        FKCellKitExampleListRow(
          title: "TabBarFilter + user list",
          subtitle: "Filter strip chrome above a CellKit user list on one screen."
        ) { FKCellKitTabBarFilterUserListExampleViewController() },
      ]
    )
  }
}
