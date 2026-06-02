import UIKit
import FKUIKit
import FKBusinessKit

/// End-to-end ``FKTabBarFilterController`` recipes (tabs, state, configuration).
enum FKTabBarFilterStripRecipe: Int, CaseIterable {
  case scrollableSixPanels
  case customPanelKind

  var menuTitle: String {
    switch self {
    case .scrollableSixPanels: return "All panel kinds · scrollable strip"
    case .customPanelKind: return "Custom panel kind · factory"
    }
  }

  var menuSubtitle: String {
    switch self {
    case .scrollableSixPanels:
      return "Hierarchy, grid, chips, tags, and single list — intrinsic-width tabs."
    case .customPanelKind:
      return "Middle tab uses PanelSource.custom instead of a built-in panel recipe."
    }
  }

  var screenTitle: String { menuTitle }

  var configuration: FKTabBarFilterConfiguration<String> {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleAppearance.makeHubFilterConfiguration()
    case .customPanelKind:
      return FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration()
    }
  }

  var initialState: FKTabBarFilterExampleState {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleState.presetFullHub()
    case .customPanelKind:
      return FKTabBarFilterExampleState.presetEqualKnowledge()
    }
  }

  func makeTabs(tagsTitle: @escaping () -> String) -> [FKTabBarFilterTab<String>] {
    switch self {
    case .scrollableSixPanels:
      return [
        .init(id: "browse", panelKind: .hierarchy, title: "Browse"),
        .init(id: "catalog", panelKind: .dualHierarchy, title: "Courses"),
        .init(id: "formats", panelKind: .gridPrimary, title: "Formats"),
        .init(id: "scope", panelKind: .gridSecondary, title: "Scope"),
        FKTabBarFilterTab(
          id: "tags",
          panelKind: .tags,
          title: tagsTitle,
          subtitle: { "Optional multi-select" },
          allowsMultipleSelection: true
        ),
        .init(id: "sort", panelKind: .singleList, title: "Newest"),
      ]
    case .customPanelKind:
      return [
        .init(id: "browse", panelKind: .hierarchy, title: "Browse"),
        .init(id: "promo", panelKind: .custom("promo"), title: "Promo"),
        .init(id: "sort", panelKind: .singleList, title: "Sort"),
      ]
    }
  }

  var usesTagsTitleCallback: Bool { self == .scrollableSixPanels }
  var includesCustomPromoPanel: Bool { self == .customPanelKind }

  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterStripRecipeViewController(recipe: self)
    }
  }
}
