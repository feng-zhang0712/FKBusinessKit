import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKFeedContentCell`` — social feed posts with multi-line body and image grid.
public struct FKFeedContentItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Author display name shown beside the avatar.
  public var authorName: String
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Multi-line post body text.
  public var body: String
  /// Remote image URLs rendered in a nine-grid layout (up to nine items).
  public var imageURLs: [URL]
  /// Optional relative or absolute time string beside the author name.
  public var timestampText: String?
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a feed content row item.
  public init(
    id: String,
    authorName: String,
    avatarURL: URL? = nil,
    body: String,
    imageURLs: [URL] = [],
    timestampText: String? = nil,
    isVerified: Bool = false
  ) {
    self.id = id
    self.authorName = authorName
    self.avatarURL = avatarURL
    self.body = body
    self.imageURLs = imageURLs
    self.timestampText = timestampText
    self.isVerified = isVerified
  }
}

extension FKFeedContentItem: FKListImagePrefetchProviding {
  /// Avatar and grid thumbnail warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    var requests: [FKListImagePrefetchRequest] = []
    if let avatarURL {
      let side = FKAvatarSize.s.diameter * 2
      requests.append(
        FKListImagePrefetchRequest(
          url: avatarURL,
          targetSize: CGSize(width: side, height: side)
        )
      )
    }
    let tileSide = FKFeedImageGridConfiguration.defaultTileSide
    requests.append(
      contentsOf: imageURLs.prefix(FKFeedImageGridConfiguration.default.maxImageCount).map { url in
        FKListImagePrefetchRequest(
          url: url,
          targetSize: CGSize(width: tileSide * 2, height: tileSide * 2)
        )
      }
    )
    return requests
  }
}
