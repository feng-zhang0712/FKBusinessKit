import UIKit
import FKUIKit

/// Panel content presented when a filter tab is expanded.
public enum FKTabBarFilterTabPanelContent {
  /// Built-in or factory-backed panel via ``FKTabBarFilterPanelKind``.
  case panelKind(FKTabBarFilterPanelKind)
  /// Custom panel without ``FKTabBarFilterPanelFactory``.
  case viewController(@MainActor () -> UIViewController)
  /// Lightweight ``UIView`` hosted in ``FKTabBarFilterViewWrappingController``.
  case view(@MainActor () -> UIView)
}

/// One filter strip tab and the panel content it presents.
public struct FKTabBarFilterTab<TabID: Hashable> {
  public let id: TabID
  public let panelContent: FKTabBarFilterTabPanelContent
  public let title: () -> String
  public let subtitle: (() -> String?)?
  public let allowsMultipleSelection: Bool
  /// When `nil`, ``FKTabBarFilterController`` uses ``FKTabBarFilterConfiguration/tabAppearance``.
  public let appearance: FKTabBarFilterTabAppearance?

  /// Creates a tab backed by ``FKTabBarFilterPanelFactory`` for `panelKind`.
  public init(
    id: TabID,
    panelKind: FKTabBarFilterPanelKind,
    title: @escaping () -> String,
    subtitle: (() -> String?)? = nil,
    allowsMultipleSelection: Bool = false,
    appearance: FKTabBarFilterTabAppearance? = nil
  ) {
    self.id = id
    self.panelContent = .panelKind(panelKind)
    self.title = title
    self.subtitle = subtitle
    self.allowsMultipleSelection = allowsMultipleSelection
    self.appearance = appearance
  }

  /// Convenience for static title and optional subtitle strings.
  public init(
    id: TabID,
    panelKind: FKTabBarFilterPanelKind,
    title: String,
    subtitle: String? = nil,
    allowsMultipleSelection: Bool = false,
    appearance: FKTabBarFilterTabAppearance? = nil
  ) {
    let titleClosure: () -> String = { title }
    let subtitleClosure: (() -> String?)? = subtitle.map { value in { value } }
    self.init(
      id: id,
      panelKind: panelKind,
      title: titleClosure,
      subtitle: subtitleClosure,
      allowsMultipleSelection: allowsMultipleSelection,
      appearance: appearance
    )
  }

  /// Creates a tab with custom panel content (no ``FKTabBarFilterPanelKind``).
  public init(
    id: TabID,
    title: @escaping () -> String,
    subtitle: (() -> String?)? = nil,
    allowsMultipleSelection: Bool = false,
    appearance: FKTabBarFilterTabAppearance? = nil,
    panelContent: FKTabBarFilterTabPanelContent
  ) {
    self.id = id
    self.panelContent = panelContent
    self.title = title
    self.subtitle = subtitle
    self.allowsMultipleSelection = allowsMultipleSelection
    self.appearance = appearance
  }

  /// Panel kind when ``panelContent`` is ``FKTabBarFilterTabPanelContent/panelKind``; otherwise `nil`.
  public var panelKind: FKTabBarFilterPanelKind? {
    if case let .panelKind(kind) = panelContent { return kind }
    return nil
  }
}
