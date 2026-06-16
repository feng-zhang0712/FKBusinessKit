import FKUIKit

/// Lightweight status pill payload mapped to ``FKStatusPill`` inside CellKit cells.
public struct FKStatusPillDisplayModel: Equatable, Sendable {
  /// Status word shown inside the pill.
  public var title: String
  /// Workflow semantic styling.
  public var style: FKStatusPillStyle
  /// When `true`, renders the leading dot indicator.
  public var showsDot: Bool

  /// Creates a status pill display model.
  public init(title: String, style: FKStatusPillStyle = .neutral, showsDot: Bool = false) {
    self.title = title
    self.style = style
    self.showsDot = showsDot
  }
}
