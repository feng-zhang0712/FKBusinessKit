import FKUIKit

/// View model for ``FKOrderListCell``.
public struct FKOrderListItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Primary title (for example product summary).
  public var title: String
  /// Secondary line (for example created-at or amount).
  public var subtitle: String?
  /// Short order number shown in the copy chip.
  public var displayOrderNumber: String
  /// Full order number copied to the pasteboard; `nil` uses ``displayOrderNumber``.
  public var fullOrderNumber: String?
  /// Workflow status pill content.
  public var statusPill: FKStatusPillDisplayModel
  /// Optional SF Symbol name for the leading ``FKIconView``.
  public var leadingSymbolName: String?
  /// When `false`, hides the copy chip even when an order number is present.
  public var showsCopyChip: Bool

  /// Creates an order list row item.
  public init(
    id: String,
    title: String,
    subtitle: String? = nil,
    displayOrderNumber: String,
    fullOrderNumber: String? = nil,
    statusPill: FKStatusPillDisplayModel,
    leadingSymbolName: String? = "shippingbox.fill",
    showsCopyChip: Bool = true
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.displayOrderNumber = displayOrderNumber
    self.fullOrderNumber = fullOrderNumber
    self.statusPill = statusPill
    self.leadingSymbolName = leadingSymbolName
    self.showsCopyChip = showsCopyChip
  }
}
