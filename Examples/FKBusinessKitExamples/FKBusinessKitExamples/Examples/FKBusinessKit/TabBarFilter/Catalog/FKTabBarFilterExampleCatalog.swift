import UIKit
import FKUIKit
import FKBusinessKit

/// Root navigation catalog for TabBarFilter examples.
enum FKTabBarFilterExampleCatalog {
  static var rootSections: [FKTabBarFilterExampleListSection] {
    [
      controllerSection,
      anchoringSection,
      panelsSection,
    ]
  }

  // MARK: - FKTabBarFilterController

  static var controllerSection: FKTabBarFilterExampleListSection {
    FKTabBarFilterExampleListSection(
      title: "FKTabBarFilterController",
      rows: [
        FKTabBarFilterExampleListRow(
          title: "Tab bar anchor (default)",
          subtitle: "Events, switch animation, expand/collapse — anchor source is the embedded FKTabBar."
        ) { FKTabBarFilterTabBarAnchorExampleViewController() },
        FKTabBarFilterExampleListRow(
          title: "Custom anchor & geometry",
          subtitle: "setAnchor, updateAnchorPlacement, toggle — custom UIView as anchor source."
        ) { FKTabBarFilterCustomAnchorExampleViewController() },
        FKTabBarFilterExampleListRow(
          title: "UIView vs view controller panels",
          subtitle: "panelContent.view and panelContent.viewController on the same strip."
        ) { FKTabBarFilterViewContentExampleViewController() },
        FKTabBarFilterStripRecipe.scrollableSixPanels.listRow,
        FKTabBarFilterExampleListRow(
          title: "Equal-width tabs",
          subtitle: "Commerce vs library datasets — switch panel recipes on one screen."
        ) { FKTabBarFilterEqualWidthTabsPlaygroundViewController() },
        FKTabBarFilterExampleListRow(
          title: "Configuration playground",
          subtitle: "Tab switching, caching, backdrop, hairline, and slow relayout toggles."
        ) { FKTabBarFilterConfigurationPlaygroundViewController() },
        FKTabBarFilterStripRecipe.customPanelKind.listRow,
      ]
    )
  }

  // MARK: - Anchoring

  static var anchoringSection: FKTabBarFilterExampleListSection {
    FKTabBarFilterExampleListSection(
      title: "Anchoring",
      rows: [
        FKTabBarFilterExampleListRow(
          title: "Anchor zones playground",
          subtitle: "Navigation bar, screen top, and screen bottom — filter strip or custom anchor."
        ) { FKTabBarFilterAnchorZonesPlaygroundViewController() },
        FKTabBarFilterExampleListRow(
          title: "Horizontal edge trays",
          subtitle: "TabBarFilter uses top/bottom FKAnchor edges only. Left/right trays use FKSheetPresentationController directly."
        ) { FKTabBarFilterHorizontalEdgeNoteViewController() },
      ]
    )
  }

  // MARK: - Panels

  static var panelsSection: FKTabBarFilterExampleListSection {
    FKTabBarFilterExampleListSection(title: "Panel components", rows: [FKTabBarFilterPanelsCatalog.rootRow])
  }
}
