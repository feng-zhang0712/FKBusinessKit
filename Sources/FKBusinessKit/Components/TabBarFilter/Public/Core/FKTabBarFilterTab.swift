import UIKit
import FKUIKit

/// One filter strip tab and the panel kind it presents.
public struct FKTabBarFilterTab<TabID: Hashable> {
  public let id: TabID
  public let panelKind: FKTabBarFilterPanelKind
  public let title: () -> String
  public let subtitle: (() -> String?)?
  public let allowsMultipleSelection: Bool
  /// When `nil`, ``FKTabBarFilterController`` uses ``FKTabBarFilterConfiguration/defaultTabStrip``.
  public let tabStrip: FKTabBarFilterTabStripConfiguration?

  public init(
    id: TabID,
    panelKind: FKTabBarFilterPanelKind,
    title: @escaping () -> String,
    subtitle: (() -> String?)? = nil,
    allowsMultipleSelection: Bool = false,
    tabStrip: FKTabBarFilterTabStripConfiguration? = nil
  ) {
    self.id = id
    self.panelKind = panelKind
    self.title = title
    self.subtitle = subtitle
    self.allowsMultipleSelection = allowsMultipleSelection
    self.tabStrip = tabStrip
  }

  /// Convenience for static title and optional subtitle strings.
  public init(
    id: TabID,
    panelKind: FKTabBarFilterPanelKind,
    title: String,
    subtitle: String? = nil,
    allowsMultipleSelection: Bool = false,
    tabStrip: FKTabBarFilterTabStripConfiguration? = nil
  ) {
    let titleClosure: () -> String = { title }
    let subtitleClosure: (() -> String?)? = subtitle.map { value in { value } }
    self.init(
      id: id,
      panelKind: panelKind,
      title: titleClosure,
      subtitle: subtitleClosure,
      allowsMultipleSelection: allowsMultipleSelection,
      tabStrip: tabStrip
    )
  }
}
