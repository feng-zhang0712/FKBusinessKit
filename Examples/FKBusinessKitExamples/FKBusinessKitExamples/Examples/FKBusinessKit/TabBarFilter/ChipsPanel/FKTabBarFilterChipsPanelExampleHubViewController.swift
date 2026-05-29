import UIKit
import FKUIKit
import FKBusinessKit

final class FKTabBarFilterChipsPanelExampleHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "Chips panel examples", sections: Self.sections)
  }

  private static let sections: [FKTabBarFilterExampleListSection] = [
    (
      "Structure & selection",
      [
        FKTabBarFilterChipsPanelExampleCase.baselineSingleSection,
        .twoSectionsSingleSelect,
        .multipleSelectionTabAndSections,
      ]
    ),
    ("Grid layout", [.columnsTwo, .columnsSix]),
    ("Height", [.heightFixed, .heightCapped, .heightScreenFraction]),
    ("Appearance", [.customPillStyle, .wideContentInsets, .tallRowHeight]),
    ("Edge cases", [.disabledChip, .onChangeOnlyNoSelection]),
  ].map { title, cases in
    FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
  }
}

private extension FKTabBarFilterChipsPanelExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterChipsPanelExampleDetailViewController(exampleCase: self)
    }
  }
}
