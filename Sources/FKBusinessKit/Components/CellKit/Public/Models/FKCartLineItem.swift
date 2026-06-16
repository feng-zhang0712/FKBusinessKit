import Foundation
import FKUIKit

/// Read-only cart line item for ``FKCartLineItemCell``.
public struct FKCartLineItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Product title.
  public var title: String
  /// Optional variant or SKU summary.
  public var variantText: String?
  /// Optional product thumbnail URL.
  public var imageURL: URL?
  /// Current price string.
  public var priceText: String
  /// Optional struck-through original price.
  public var originalPriceText: String?
  /// Display-only quantity label, e.g. `×2`.
  public var quantityText: String?

  /// Creates a cart line item row payload.
  public init(
    id: String,
    title: String,
    variantText: String? = nil,
    imageURL: URL? = nil,
    priceText: String,
    originalPriceText: String? = nil,
    quantityText: String? = nil
  ) {
    self.id = id
    self.title = title
    self.variantText = variantText
    self.imageURL = imageURL
    self.priceText = priceText
    self.originalPriceText = originalPriceText
    self.quantityText = quantityText
  }
}

extension FKCartLineItem: FKListImagePrefetchProviding {
  /// Product thumbnail warm-up target.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let imageURL else { return [] }
    return [FKListImagePrefetchRequest(url: imageURL, targetSize: CGSize(width: 120, height: 120))]
  }
}

/// Interactive cart row payload for ``FKCartQuantityCell``.
public struct FKCartQuantityItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Product title.
  public var title: String
  /// Optional variant or SKU summary.
  public var variantText: String?
  /// Optional product thumbnail URL.
  public var imageURL: URL?
  /// Current price string.
  public var priceText: String
  /// Current quantity.
  public var quantity: Int
  /// Minimum allowed quantity.
  public var minQuantity: Int
  /// Maximum allowed quantity.
  public var maxQuantity: Int
  /// Handler id registered in ``FKCellKitValueHandlerRegistry`` on the list controller.
  public var quantityHandlerID: String

  /// Creates a cart quantity row payload.
  public init(
    id: String,
    title: String,
    variantText: String? = nil,
    imageURL: URL? = nil,
    priceText: String,
    quantity: Int,
    minQuantity: Int = 1,
    maxQuantity: Int = 99,
    quantityHandlerID: String
  ) {
    self.id = id
    self.title = title
    self.variantText = variantText
    self.imageURL = imageURL
    self.priceText = priceText
    self.quantity = quantity
    self.minQuantity = minQuantity
    self.maxQuantity = maxQuantity
    self.quantityHandlerID = quantityHandlerID
  }
}

extension FKCartQuantityItem: FKListImagePrefetchProviding {
  /// Product thumbnail warm-up target.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let imageURL else { return [] }
    return [FKListImagePrefetchRequest(url: imageURL, targetSize: CGSize(width: 120, height: 120))]
  }
}
