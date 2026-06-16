import CoreGraphics
import Foundation
import FKUIKit

/// Shared product row payload for ``FKProductGridCell`` (and future table variants).
public struct FKProductListItem: Equatable, Sendable {
  /// Stable item identity.
  public var id: String
  /// Product title.
  public var title: String
  /// Price or offer string.
  public var priceText: String
  /// Remote cover image URL.
  public var imageURL: URL?
  /// Optional promotional tags below the title.
  public var tags: [FKTagDisplayModel]

  /// Creates a product list item.
  public init(
    id: String,
    title: String,
    priceText: String,
    imageURL: URL? = nil,
    tags: [FKTagDisplayModel] = []
  ) {
    self.id = id
    self.title = title
    self.priceText = priceText
    self.imageURL = imageURL
    self.tags = tags
  }
}

extension FKProductListItem: FKListImagePrefetchProviding {
  /// Product image warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let imageURL else { return [] }
    let side: CGFloat = 320
    return [
      FKListImagePrefetchRequest(
        url: imageURL,
        targetSize: CGSize(width: side, height: side)
      ),
    ]
  }
}
