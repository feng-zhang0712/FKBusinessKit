import Foundation
import FKUIKit

/// Identifies which panel recipe in ``FKTabBarFilterPanelFactory`` serves a tab.
///
/// Built-in cases map to ``FKTabBarFilterPanelFactory/PanelSource`` recipes:
///
/// | Kind | Panel source |
/// |------|----------------|
/// | ``hierarchy`` | ``PanelSource/twoColumnList`` |
/// | ``dualHierarchy`` | ``PanelSource/twoColumnGrid`` |
/// | ``gridPrimary`` / ``gridSecondary`` / ``tags`` | ``PanelSource/chips`` |
/// | ``singleList`` | ``PanelSource/singleList`` |
/// | ``custom(_:)`` | ``PanelSource/custom(make:)`` |
///
/// Use ``custom(_:)`` for app-specific kinds and register a matching ``FKTabBarFilterPanelFactory/PanelSource``.
public enum FKTabBarFilterPanelKind: Hashable, Sendable {
  case hierarchy
  case dualHierarchy
  case gridPrimary
  case gridSecondary
  case tags
  case singleList
  case custom(String)
}

extension FKTabBarFilterPanelKind: RawRepresentable {
  public typealias RawValue = String

  public init(rawValue: String) {
    switch rawValue {
    case "hierarchy": self = .hierarchy
    case "dualHierarchy": self = .dualHierarchy
    case "gridPrimary": self = .gridPrimary
    case "gridSecondary": self = .gridSecondary
    case "tags": self = .tags
    case "singleList": self = .singleList
    default:
      self = .custom(rawValue)
    }
  }

  public var rawValue: String {
    switch self {
    case .hierarchy: return "hierarchy"
    case .dualHierarchy: return "dualHierarchy"
    case .gridPrimary: return "gridPrimary"
    case .gridSecondary: return "gridSecondary"
    case .tags: return "tags"
    case .singleList: return "singleList"
    case .custom(let value): return value
    }
  }
}
