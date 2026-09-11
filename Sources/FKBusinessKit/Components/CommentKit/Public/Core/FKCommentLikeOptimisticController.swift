import Foundation

/// Applies optimistic like toggles and supports rollback after a failed network call.
public struct FKCommentLikeOptimisticController: Sendable {
  /// Returns a copy of `item` with like state toggled and count adjusted.
  public static func toggled(_ item: FKCommentItem) -> FKCommentItem {
    var next = item
    if next.isLiked {
      next.isLiked = false
      next.likeCount = max(0, next.likeCount - 1)
    } else {
      next.isLiked = true
      next.likeCount += 1
    }
    return next
  }

  /// Restores like fields after a failed persistence attempt.
  public static func rolledBack(
    _ item: FKCommentItem,
    previousIsLiked: Bool,
    previousLikeCount: Int
  ) -> FKCommentItem {
    var next = item
    next.isLiked = previousIsLiked
    next.likeCount = max(0, previousLikeCount)
    return next
  }

  /// Replaces the matching id in `items` with `updated`, returning the new array.
  public static func replacing(
    _ updated: FKCommentItem,
    in items: [FKCommentItem]
  ) -> [FKCommentItem] {
    items.map { $0.id == updated.id ? updated : $0 }
  }
}
