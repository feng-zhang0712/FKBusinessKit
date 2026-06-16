import FKUIKit

/// View model for ``FKNotificationListCell``.
public struct FKNotificationListItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Notification title.
  public var title: String
  /// Body or summary text.
  public var summary: String?
  /// Relative or absolute time string.
  public var timestampText: String?
  /// SF Symbol name for the leading ``FKIconView``.
  public var symbolName: String
  /// When `true`, shows an unread indicator dot in the trailing column.
  public var isUnread: Bool

  /// Creates a notification list row item.
  public init(
    id: String,
    title: String,
    summary: String? = nil,
    timestampText: String? = nil,
    symbolName: String = "bell.fill",
    isUnread: Bool = false
  ) {
    self.id = id
    self.title = title
    self.summary = summary
    self.timestampText = timestampText
    self.symbolName = symbolName
    self.isUnread = isUnread
  }
}
