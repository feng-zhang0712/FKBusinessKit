import UIKit
import FKUIKit
import FKBusinessKit

/// TabBarFilter example entry — grouped by integration depth: low-level dropdown, end-to-end filter strip, isolated panels.
final class FKTabBarFilterExamplesHubViewController: FKTabBarFilterGroupedListHubViewController {

  private enum IntegrationRow {
    case tabBarAnchor
    case customViewAnchor
    case viewContent

    var listRow: FKTabBarFilterExampleListRow {
      switch self {
      case .tabBarAnchor:
        return FKTabBarFilterExampleListRow(
          title: "Tab bar anchor",
          subtitle: "FKTabBarFilterDropdownController — Events, switch animation, expand/collapse APIs."
        ) { FKTabBarFilterTabBarAnchorExampleViewController() }
      case .customViewAnchor:
        return FKTabBarFilterExampleListRow(
          title: "Custom anchor & geometry",
          subtitle: "setAnchor, updateAnchorPlacement, toggle — custom UIView as anchor source."
        ) { FKTabBarFilterCustomAnchorExampleViewController() }
      case .viewContent:
        return FKTabBarFilterExampleListRow(
          title: "UIView content hosting",
          subtitle: "FKTabBarFilterDropdownTab.Content.view vs .viewController on the same strip."
        ) { FKTabBarFilterViewContentExampleViewController() }
      }
    }
  }

  private enum PanelCatalogRow {
    case twoColumnList
    case twoColumnGrid
    case chipsPanel
    case singleListPanel

    var listRow: FKTabBarFilterExampleListRow {
      switch self {
      case .twoColumnList:
        return FKTabBarFilterExampleListRow(
          title: "Two-column list",
          subtitle: "FKTabBarFilterTwoColumnListViewController — selection, headers, height, collapse."
        ) { FKTabBarFilterTwoColumnListExampleHubViewController() }
      case .twoColumnGrid:
        return FKTabBarFilterExampleListRow(
          title: "Two-column grid",
          subtitle: "FKTabBarFilterTwoColumnGridViewController — dual hierarchy / course grid layouts."
        ) { FKTabBarFilterTwoColumnGridExampleHubViewController() }
      case .chipsPanel:
        return FKTabBarFilterExampleListRow(
          title: "Chips panel",
          subtitle: "FKTabBarFilterChipsViewController — pill grids and multi-select sections."
        ) { FKTabBarFilterChipsPanelExampleHubViewController() }
      case .singleListPanel:
        return FKTabBarFilterExampleListRow(
          title: "Single-list panel",
          subtitle: "FKTabBarFilterSingleListViewController — centered sort-style lists."
        ) { FKTabBarFilterSingleListPanelExampleHubViewController() }
      }
    }
  }

  init() {
    super.init(
      title: "TabBarFilter",
      sections: [
        FKTabBarFilterExampleListSection(
          title: "Dropdown integration",
          rows: [IntegrationRow.tabBarAnchor, .customViewAnchor, .viewContent].map(\.listRow)
        ),
      ]
        + FKTabBarFilterDropdownAnchoredExample.hubSections
        + FKTabBarFilterAnchorZone.hubSections
        + [
          FKTabBarFilterExampleListSection(
            title: "Panel components (isolated)",
            rows: [
              PanelCatalogRow.twoColumnList,
              .twoColumnGrid,
              .chipsPanel,
              .singleListPanel,
            ].map(\.listRow)
          ),
        ]
    )
  }
}
