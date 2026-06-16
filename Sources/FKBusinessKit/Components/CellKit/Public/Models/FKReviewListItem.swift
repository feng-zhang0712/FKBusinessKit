import Foundation
import FKUIKit

/// View model for ``FKReviewListCell``.
public struct FKReviewListItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Review author display name.
  public var authorName: String
  /// Optional reviewer avatar URL.
  public var avatarURL: URL?
  /// Star rating from zero through five.
  public var rating: Double
  /// Review body text.
  public var reviewText: String
  /// Optional relative timestamp string.
  public var timestampText: String?
  /// Optional review photo thumbnail URLs (first three are shown).
  public var imageURLs: [URL]

  /// Creates a review list row item.
  public init(
    id: String,
    authorName: String,
    avatarURL: URL? = nil,
    rating: Double,
    reviewText: String,
    timestampText: String? = nil,
    imageURLs: [URL] = []
  ) {
    self.id = id
    self.authorName = authorName
    self.avatarURL = avatarURL
    self.rating = rating
    self.reviewText = reviewText
    self.timestampText = timestampText
    self.imageURLs = imageURLs
  }
}

extension FKReviewListItem: FKListImagePrefetchProviding {
  /// Avatar and review thumbnail warm-up targets.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    var requests: [FKListImagePrefetchRequest] = []
    if let avatarURL {
      let side = FKAvatarSize.s.diameter * 2
      requests.append(FKListImagePrefetchRequest(url: avatarURL, targetSize: CGSize(width: side, height: side)))
    }
    for url in imageURLs.prefix(3) {
      requests.append(FKListImagePrefetchRequest(url: url, targetSize: CGSize(width: 72, height: 72)))
    }
    return requests
  }
}
