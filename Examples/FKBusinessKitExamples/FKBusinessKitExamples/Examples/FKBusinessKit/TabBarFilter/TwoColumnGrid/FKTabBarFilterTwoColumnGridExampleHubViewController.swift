import UIKit
import FKUIKit
import FKBusinessKit

final class FKTabBarFilterTwoColumnGridExampleHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "Two-column grid examples", sections: Self.sections)
  }

  private static let sections: [FKTabBarFilterExampleListSection] = [
    ("Baseline", [FKTabBarFilterTwoColumnGridExampleCase.baselineDefaults]),
    (
      "Section headers",
      [
        .sectionCollapsePlain,
        .sectionCollapseInsetGroupedChrome,
        .collapseChevronHidden,
        .headerSelectionWithoutCollapse,
      ]
    ),
    (
      "Selection",
      [
        .globalSingleAcrossSections,
        .withinSectionSingle,
        .multipleSelectionTabAndSections,
      ]
    ),
    (
      "Customization",
      [
        .customLeftAndItemCells,
        .narrowLeftColumn,
        .singleColumnDense,
        .fourColumnsWide,
        .disabledPillItem,
      ]
    ),
    ("Height", [.heightBehaviorFixed, .heightBehaviorCapped]),
    ("Callbacks", [.onChangeOnlyNoSelection]),
  ].map { title, cases in
    FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
  }
}

private extension FKTabBarFilterTwoColumnGridExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterTwoColumnGridExampleDetailViewController(exampleCase: self)
    }
  }
}
