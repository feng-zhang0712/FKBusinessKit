import UIKit
import FKUIKit

/// Width-keyed row height estimation for ``FKFeedContentCell`` with ``FKListHeightCache``.
public enum FKFeedContentCellHeightEstimator {
  /// Returns a cached or computed estimated row height for a feed content item.
  @MainActor
  public static func estimatedRowHeight(
    for item: FKFeedContentItem,
    width: CGFloat,
    configuration: FKFeedContentCellConfiguration = FKCellKitDefaults.feedContentCell,
    cache: FKListHeightCache
  ) -> CGFloat {
    let itemID = FKListItemID(item.id)
    if let cached = cache.height(for: itemID, width: width) {
      return cached
    }

    let insets = configuration.table.contentInsets
    let contentWidth = max(1, width - insets.left - insets.right)
    var height = insets.top + insets.bottom

    let avatarSide = configuration.avatarSize.diameter
    let authorFont = UIFont.preferredFont(forTextStyle: configuration.authorTextStyle)
    height += max(avatarSide, authorFont.lineHeight)

    let hasBody = !item.body.isEmpty
    let imageCount = min(item.imageURLs.count, configuration.grid.maxImageCount)
    let hasImages = imageCount > 0

    if hasBody {
      height += configuration.sectionSpacing
      height += FKListHeightCache.measuredTextHeight(
        item.body,
        font: UIFont.preferredFont(forTextStyle: configuration.bodyTextStyle),
        width: contentWidth,
        insets: .zero,
        maxLines: configuration.bodyMaxLines
      )
    }

    if hasImages {
      height += configuration.sectionSpacing
      height += FKFeedImageGridView.preferredHeight(
        imageCount: imageCount,
        width: contentWidth,
        configuration: configuration.grid
      )
    }

    cache.setHeight(height, for: itemID, width: width)
    return height
  }

  /// Drops cached heights for one feed item (e.g. after text expansion).
  @MainActor
  public static func invalidateHeight(for itemID: FKListItemID, cache: FKListHeightCache) {
    cache.invalidate(itemID: itemID)
  }
}
