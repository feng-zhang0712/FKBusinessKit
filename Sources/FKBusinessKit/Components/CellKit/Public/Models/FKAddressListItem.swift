import Foundation

/// View model for ``FKAddressListCell`` — shipping address rows with optional default tag.
public struct FKAddressListItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Recipient name shown as the primary line.
  public var recipientName: String
  /// Phone number shown as the secondary line.
  public var phone: String
  /// Full formatted address rendered below the name and phone.
  public var address: String
  /// When `true`, shows the default address tag in the trailing column.
  public var isDefault: Bool
  /// When `true`, shows a selection checkmark in the trailing column.
  public var isSelected: Bool
  /// Optional SF Symbol name for the leading icon; uses a location symbol when `nil`.
  public var leadingSymbolName: String?

  /// Creates an address list row item.
  public init(
    id: String,
    recipientName: String,
    phone: String,
    address: String,
    isDefault: Bool = false,
    isSelected: Bool = false,
    leadingSymbolName: String? = "location.fill"
  ) {
    self.id = id
    self.recipientName = recipientName
    self.phone = phone
    self.address = address
    self.isDefault = isDefault
    self.isSelected = isSelected
    self.leadingSymbolName = leadingSymbolName
  }
}
