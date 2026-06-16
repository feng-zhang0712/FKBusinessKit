import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKFeedVideoCell`` — social feed posts with inline video playback.
public struct FKFeedVideoItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Author display name shown beside the avatar.
  public var authorName: String
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Video payload consumed by ``FKVideoPlayer``.
  public var video: FKVideoItem
  /// Optional caption shown below the player surface.
  public var caption: String?
  /// Optional relative or absolute time string beside the author name.
  public var timestampText: String?
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a feed video row item.
  public init(
    id: String,
    authorName: String,
    avatarURL: URL? = nil,
    video: FKVideoItem,
    caption: String? = nil,
    timestampText: String? = nil,
    isVerified: Bool = false
  ) {
    self.id = id
    self.authorName = authorName
    self.avatarURL = avatarURL
    self.video = video
    self.caption = caption
    self.timestampText = timestampText
    self.isVerified = isVerified
  }
}

extension FKFeedVideoItem: FKListImagePrefetchProviding {
  /// Avatar and poster warm-up targets for ``FKListImagePrefetchHelper``.
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
    if let posterURL = video.posterURL ?? video.artworkURL {
      requests.append(
        FKListImagePrefetchRequest(
          url: posterURL,
          targetSize: CGSize(width: 640, height: 360)
        )
      )
    }
    return requests
  }
}
