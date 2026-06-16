import FKUIKit

/// Lightweight tag payload mapped to ``FKTag`` inside CellKit cells and row parts.
public struct FKTagDisplayModel: Equatable, Sendable {
  /// Visible tag title.
  public var title: String
  /// Semantic styling forwarded to ``FKTag/variant``.
  public var variant: FKTagVariant

  /// Creates a tag display model.
  public init(title: String, variant: FKTagVariant = .neutral) {
    self.title = title
    self.variant = variant
  }
}
