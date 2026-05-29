import UIKit
import FKUIKit
import FKBusinessKit

final class FKTabBarFilterTwoColumnListExampleHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "Two-column list examples", sections: Self.sections)
  }

  private static let sections: [FKTabBarFilterExampleListSection] = [
    (
      "Baseline & table style",
      [
        FKTabBarFilterTwoColumnListExampleCase.baselinePlainDefaults,
        .plainStyleExplicit,
        .insetGroupedFullGroupedConfiguration,
        .groupedFootersOnly,
        .customChromeAndListCellStyles,
      ]
    ),
    (
      "Selection",
      [
        .globalSingleAcrossSections,
        .withinSectionSingleTwoSections,
        .multipleSelectionTabAndSections,
        .sectionMultipleTabSingleEffectiveSingle,
      ]
    ),
    (
      "Section headers",
      [
        .sectionsWithoutVisibleHeaders,
        .systemTitledSectionHeaders,
        .selectableSectionHeadersPreset,
        .selectableHeadersCustomStyle,
        .sectionCollapsePlainDefaults,
        .sectionCollapseInsetGroupedMixedInitial,
        .sectionCollapseChevronHidden,
      ]
    ),
    (
      "Rows & hooks",
      [
        .disabledRowAndAttributedText,
        .customLeftAndRightCellHooks,
        .narrowCategoryColumnRatio,
        .wideRightSeparatorInsets,
      ]
    ),
    (
      "Height behavior",
      [
        .heightBehaviorFixed,
        .heightBehaviorCapped,
        .heightBehaviorScreenFraction,
        .heightBehaviorAutomaticTallFloor,
      ]
    ),
    (
      "Lifecycle & edge cases",
      [
        .emptyCategorySyntheticSelection,
        .onChangeOnlyWithoutSelectionHandler,
      ]
    ),
  ].map { title, cases in
    FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
  }
}

private extension FKTabBarFilterTwoColumnListExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterTwoColumnListExampleDetailViewController(exampleCase: self)
    }
  }
}
