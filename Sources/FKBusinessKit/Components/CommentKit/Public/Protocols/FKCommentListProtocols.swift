import Foundation
import UIKit

/// Supplies comment pages, reply expansions, and submit operations to ``FKCommentListViewController``.
///
/// Implement in the App layer — CommentKit never performs networking.
@MainActor
public protocol FKCommentListDataSource: AnyObject {
  /// Loads the first page (or refreshes) of top-level comments.
  func commentListLoadInitial(
    completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void
  )

  /// Loads the next page of top-level comments.
  func commentListLoadMore(
    completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void
  )

  /// Loads reply rows for a parent comment (flat list; typically `depth >= 1`).
  ///
  /// Visual indent is clamped by ``FKCommentRowCellConfiguration/maxDepth``; deeper logical floors are allowed.
  func commentListLoadReplies(
    parentId: String,
    completion: @escaping @MainActor (Result<[FKCommentItem], Error>) -> Void
  )

  /// Submits a new comment or reply; returns the created item on success.
  func commentListSubmit(
    _ request: FKCommentSubmitRequest,
    completion: @escaping @MainActor (Result<FKCommentItem, Error>) -> Void
  )
}

/// Optional hooks and row interaction callbacks for ``FKCommentListViewController``.
@MainActor
public protocol FKCommentListDelegate: AnyObject {
  /// Called after the user toggles like; App should persist and call rollback on failure.
  func commentList(
    _ controller: FKCommentListViewController,
    didToggleLike item: FKCommentItem,
    previousIsLiked: Bool,
    previousLikeCount: Int
  )

  /// Called when the user taps Reply (composer reply target is already set by the kit when composer is shown).
  func commentList(
    _ controller: FKCommentListViewController,
    didTapReply item: FKCommentItem
  )

  /// Called when the user taps the avatar.
  func commentList(
    _ controller: FKCommentListViewController,
    didTapAvatar item: FKCommentItem
  )

  /// Called when the user taps the author display name.
  func commentList(
    _ controller: FKCommentListViewController,
    didTapAuthor item: FKCommentItem
  )

  /// Called when the user taps the comment body / content area (not avatar, name, like, reply, expand).
  func commentList(
    _ controller: FKCommentListViewController,
    didTapComment item: FKCommentItem
  )

  /// Called when the user long-presses a comment row.
  func commentList(
    _ controller: FKCommentListViewController,
    didLongPressComment item: FKCommentItem
  )

  /// Called when the user picks a more-menu action.
  func commentList(
    _ controller: FKCommentListViewController,
    didSelectMore action: FKCommentMoreAction,
    for item: FKCommentItem
  )

  /// Called when the user picks an ``FKCommentCustomMoreAction`` from the built-in more sheet.
  func commentList(
    _ controller: FKCommentListViewController,
    didSelectCustomMoreAction id: String,
    for item: FKCommentItem
  )

  /// Called when More is tapped and ``FKCommentKitConfiguration/presentsDefaultMoreMenu`` is `false`.
  ///
  /// Present your own menu using `sourceView` as the popover anchor.
  func commentList(
    _ controller: FKCommentListViewController,
    didTapMore item: FKCommentItem,
    sourceView: UIView
  )

  /// Called after replies for `parentId` were inserted (or failed — see `error`).
  func commentList(
    _ controller: FKCommentListViewController,
    didExpandRepliesFor parentId: String,
    inserted: [FKCommentItem],
    error: Error?
  )

  /// Called after the contiguous reply subtree under `parentId` was collapsed.
  func commentList(
    _ controller: FKCommentListViewController,
    didCollapseRepliesFor parentId: String
  )

  /// Called after a successful submit; the new item is already in the list when possible.
  func commentList(
    _ controller: FKCommentListViewController,
    didSubmit item: FKCommentItem
  )

  /// Called when submit fails after the composer entered sending state.
  func commentList(
    _ controller: FKCommentListViewController,
    didFailSubmit request: FKCommentSubmitRequest,
    error: Error
  )
}

public extension FKCommentListDelegate {
  func commentList(
    _ controller: FKCommentListViewController,
    didToggleLike item: FKCommentItem,
    previousIsLiked: Bool,
    previousLikeCount: Int
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didTapReply item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didTapAvatar item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didTapAuthor item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didTapComment item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didLongPressComment item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didSelectMore action: FKCommentMoreAction,
    for item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didSelectCustomMoreAction id: String,
    for item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didTapMore item: FKCommentItem,
    sourceView: UIView
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didExpandRepliesFor parentId: String,
    inserted: [FKCommentItem],
    error: Error?
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didCollapseRepliesFor parentId: String
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didSubmit item: FKCommentItem
  ) {}

  func commentList(
    _ controller: FKCommentListViewController,
    didFailSubmit request: FKCommentSubmitRequest,
    error: Error
  ) {}
}
