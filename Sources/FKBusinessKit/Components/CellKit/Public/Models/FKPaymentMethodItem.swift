import Foundation

/// View model for ``FKPaymentMethodCell`` — selectable payment method rows.
public struct FKPaymentMethodItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Primary title, e.g. card brand or wallet name.
  public var title: String
  /// Optional secondary line, e.g. masked card number.
  public var subtitle: String?
  /// Optional SF Symbol name for the leading icon.
  public var symbolName: String?
  /// When `true`, shows a selection checkmark in the trailing column.
  public var isSelected: Bool

  /// Creates a payment method list row item.
  public init(
    id: String,
    title: String,
    subtitle: String? = nil,
    symbolName: String? = "creditcard.fill",
    isSelected: Bool = false
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.symbolName = symbolName
    self.isSelected = isSelected
  }
}
