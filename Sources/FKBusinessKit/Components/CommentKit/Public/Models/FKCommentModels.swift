import CoreGraphics
import Foundation
import FKUIKit

/// Target comment referenced by a reply (“Replying to …” / “Reply to @Name”).
public struct FKCommentReplyTarget: Equatable, Sendable, Hashable {
  /// Stable identifier of the parent or replied-to comment.
  public var id: String
  /// Author display name used in reply chrome.
  public var displayName: String

  /// Creates a reply target.
  public init(id: String, displayName: String) {
    self.id = id
    self.displayName = displayName
  }
}

/// View model for ``FKCommentRowCell`` and comment list rows.
public struct FKCommentItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Author display name.
  public var authorName: String
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Comment body text.
  public var body: String
  /// Optional relative or absolute time string.
  public var timestampText: String?
  /// Total like count (may be zero).
  public var likeCount: Int
  /// Optional display override for the like count (e.g. “14k”); when `nil`, the cell formats ``likeCount``.
  public var likeCountText: String?
  /// Whether the current user has liked this comment.
  public var isLiked: Bool
  /// Total reply count for expand affordances.
  public var replyCount: Int
  /// Parent comment id when this row is a reply; `nil` for top-level.
  public var parentId: String?
  /// Optional reply-to chip target (often the parent author).
  public var replyTo: FKCommentReplyTarget?
  /// Visual nesting depth for indent (`0` = top-level, `1` = reply preview).
  public var depth: Int
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool
  /// When `true`, the current user authored this comment (enables delete in more menu by default).
  public var isOwnedByCurrentUser: Bool
  /// When `true`, the row may offer a delete action.
  public var isDeletable: Bool
  /// When `true`, replies under this parent are already expanded in the list.
  public var areRepliesExpanded: Bool

  /// Creates a comment row item.
  public init(
    id: String,
    authorName: String,
    avatarURL: URL? = nil,
    body: String,
    timestampText: String? = nil,
    likeCount: Int = 0,
    likeCountText: String? = nil,
    isLiked: Bool = false,
    replyCount: Int = 0,
    parentId: String? = nil,
    replyTo: FKCommentReplyTarget? = nil,
    depth: Int = 0,
    isVerified: Bool = false,
    isOwnedByCurrentUser: Bool = false,
    isDeletable: Bool = false,
    areRepliesExpanded: Bool = false
  ) {
    self.id = id
    self.authorName = authorName
    self.avatarURL = avatarURL
    self.body = body
    self.timestampText = timestampText
    self.likeCount = max(0, likeCount)
    self.likeCountText = likeCountText
    self.isLiked = isLiked
    self.replyCount = max(0, replyCount)
    self.parentId = parentId
    self.replyTo = replyTo
    self.depth = max(0, depth)
    self.isVerified = isVerified
    self.isOwnedByCurrentUser = isOwnedByCurrentUser
    self.isDeletable = isDeletable || isOwnedByCurrentUser
    self.areRepliesExpanded = areRepliesExpanded
  }
}

extension FKCommentItem: FKListImagePrefetchProviding {
  /// Avatar warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let avatarURL else { return [] }
    let side = FKAvatarSize.s.diameter * 2
    return [
      FKListImagePrefetchRequest(
        url: avatarURL,
        targetSize: CGSize(width: side, height: side)
      ),
    ]
  }
}

/// One page of comments for pagination.
public struct FKCommentListPage: Equatable, Sendable {
  /// Comments in display order for this page.
  public var items: [FKCommentItem]
  /// When `true`, another page may be loaded.
  public var hasMore: Bool

  /// Creates a list page.
  public init(items: [FKCommentItem], hasMore: Bool) {
    self.items = items
    self.hasMore = hasMore
  }
}

/// Payload for submitting a new comment or reply.
public struct FKCommentSubmitRequest: Equatable, Sendable {
  /// Trimmed body text to publish.
  public var text: String
  /// When set, the new comment replies to this comment id.
  public var replyToCommentId: String?

  /// Creates a submit request.
  public init(text: String, replyToCommentId: String? = nil) {
    self.text = text
    self.replyToCommentId = replyToCommentId
  }
}

/// Built-in “more” menu actions exposed by the action bar.
public enum FKCommentMoreAction: String, Equatable, Sendable, CaseIterable {
  /// Copy comment body to the pasteboard.
  case copy
  /// Delete the comment (typically when owned by the current user).
  case delete
  /// Report the comment for moderation (App handles the flow).
  case report
}

/// App-defined extra item for the built-in more action sheet.
public struct FKCommentCustomMoreAction: Equatable, Sendable, Hashable {
  /// Stable identifier returned to ``FKCommentListDelegate/commentList(_:didSelectCustomMoreAction:for:)``.
  public var id: String
  /// Localized title shown in the action sheet.
  public var title: String
  /// When `true`, uses the destructive action style.
  public var isDestructive: Bool

  /// Creates a custom more-menu item.
  public init(id: String, title: String, isDestructive: Bool = false) {
    self.id = id
    self.title = title
    self.isDestructive = isDestructive
  }
}
