import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKCommentThreadCell`` — indented comment thread rows.
public struct FKCommentThreadItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Zero-based nesting depth; each level adds ``FKCommentThreadCellConfiguration/indentWidth`` leading inset.
  public var depth: Int
  /// Author display name.
  public var authorName: String
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Comment body text.
  public var body: String
  /// Optional relative or absolute time string.
  public var timestampText: String?
  /// Optional reply summary, e.g. `"3 replies"`.
  public var replySummaryText: String?
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a comment thread row item.
  public init(
    id: String,
    depth: Int = 0,
    authorName: String,
    avatarURL: URL? = nil,
    body: String,
    timestampText: String? = nil,
    replySummaryText: String? = nil,
    isVerified: Bool = false
  ) {
    self.id = id
    self.depth = max(0, depth)
    self.authorName = authorName
    self.avatarURL = avatarURL
    self.body = body
    self.timestampText = timestampText
    self.replySummaryText = replySummaryText
    self.isVerified = isVerified
  }
}

extension FKCommentThreadItem: FKListImagePrefetchProviding {
  /// Avatar warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let avatarURL else { return [] }
    let side = FKAvatarSize.xs.diameter * 2
    return [
      FKListImagePrefetchRequest(
        url: avatarURL,
        targetSize: CGSize(width: side, height: side)
      ),
    ]
  }
}
