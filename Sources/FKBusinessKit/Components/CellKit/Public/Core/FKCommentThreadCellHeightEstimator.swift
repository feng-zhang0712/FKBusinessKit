import UIKit
import FKUIKit

/// Width-keyed row height estimation for ``FKCommentThreadCell`` with ``FKListHeightCache``.
public enum FKCommentThreadCellHeightEstimator {
  /// Returns a cached or computed estimated row height for a comment thread item.
  @MainActor
  public static func estimatedRowHeight(
    for item: FKCommentThreadItem,
    width: CGFloat,
    configuration: FKCommentThreadCellConfiguration = FKCellKitDefaults.commentThreadCell,
    cache: FKListHeightCache
  ) -> CGFloat {
    let itemID = FKListItemID(item.id)
    if let cached = cache.height(for: itemID, width: width) {
      return cached
    }

    let insets = configuration.table.contentInsets
    let contentWidth = max(1, width - insets.left - insets.right)
    let cappedDepth = min(max(0, item.depth), configuration.maxDepth)
    let indent = CGFloat(cappedDepth) * configuration.indentWidth
    let avatarSide = configuration.avatarSize.diameter
    let textWidth = max(
      1,
      contentWidth - indent - avatarSide - FKCellKitLayoutMetrics.interPartSpacing
    )

    var height = insets.top + insets.bottom
    let authorFont = UIFont.preferredFont(forTextStyle: configuration.authorTextStyle)
    height += max(avatarSide, authorFont.lineHeight)

    if !item.body.isEmpty {
      height += configuration.sectionSpacing
      height += FKListHeightCache.measuredTextHeight(
        item.body,
        font: UIFont.preferredFont(forTextStyle: configuration.bodyTextStyle),
        width: textWidth,
        insets: .zero,
        maxLines: configuration.bodyMaxLines
      )
    }

    if let replySummary = item.replySummaryText, !replySummary.isEmpty {
      height += configuration.sectionSpacing
      height += UIFont.preferredFont(forTextStyle: configuration.replySummaryTextStyle).lineHeight
    }

    cache.setHeight(height, for: itemID, width: width)
    return height
  }

  /// Drops cached heights for one comment item (e.g. after text expansion).
  @MainActor
  public static func invalidateHeight(for itemID: FKListItemID, cache: FKListHeightCache) {
    cache.invalidate(itemID: itemID)
  }
}
