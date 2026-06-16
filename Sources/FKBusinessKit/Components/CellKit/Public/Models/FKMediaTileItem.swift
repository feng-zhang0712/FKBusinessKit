import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKMediaTileCell`` (photo grid / attachment tile).
public struct FKMediaTileItem: Equatable, Sendable {
  /// Stable tile identity.
  public var id: String
  /// Remote thumbnail URL.
  public var imageURL: URL?
  /// Optional duration overlay (for video tiles), e.g. `01:24`.
  public var durationText: String?
  /// When `true`, shows a selection checkmark overlay.
  public var isSelected: Bool

  /// Creates a media tile item.
  public init(
    id: String,
    imageURL: URL? = nil,
    durationText: String? = nil,
    isSelected: Bool = false
  ) {
    self.id = id
    self.imageURL = imageURL
    self.durationText = durationText
    self.isSelected = isSelected
  }
}

extension FKMediaTileItem: FKListImagePrefetchProviding {
  /// Thumbnail warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let imageURL else { return [] }
    return [
      FKListImagePrefetchRequest(
        url: imageURL,
        targetSize: CGSize(width: 240, height: 240)
      ),
    ]
  }
}
