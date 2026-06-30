import UIKit
import FKUIKit
import FKBusinessKit

/// Panel-only example sections (isolated view controllers, not embedded in a filter strip).
enum FKTabBarFilterPanelsCatalog {
  static var hubSections: [FKTabBarFilterExampleListSection] {
    twoColumnListSections
      + twoColumnGridSections
      + chipsSections
      + singleListSections
  }

  static var rootRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(
      title: "Panel components",
      subtitle: "Two-column list/grid, chips, and single-list — isolated configurations."
    ) {
      FKTabBarFilterPanelsExampleHubViewController()
    }
  }

  // MARK: - Two-column list

  private static var twoColumnListSections: [FKTabBarFilterExampleListSection] {
    [
      ("Two-column list · baseline & table", [
        FKTabBarFilterTwoColumnListExampleCase.baselinePlainDefaults,
        .plainStyleExplicit,
        .insetGroupedFullGroupedConfiguration,
        .groupedFootersOnly,
        .customChromeAndListCellStyles,
      ]),
      ("Two-column list · selection", [
        .globalSingleAcrossSections,
        .withinSectionSingleTwoSections,
        .multipleSelectionTabAndSections,
        .sectionMultipleTabSingleEffectiveSingle,
      ]),
      ("Two-column list · section headers", [
        .sectionsWithoutVisibleHeaders,
        .systemTitledSectionHeaders,
        .selectableSectionHeadersPreset,
        .selectableHeadersCustomStyle,
        .sectionCollapsePlainDefaults,
        .sectionCollapseInsetGroupedMixedInitial,
        .sectionCollapseChevronHidden,
      ]),
      ("Two-column list · rows & hooks", [
        .disabledRowAndAttributedText,
        .customLeftAndRightCellHooks,
        .narrowCategoryColumnRatio,
        .wideRightSeparatorInsets,
      ]),
      ("Two-column list · height", [
        .heightBehaviorFixed,
        .heightBehaviorCapped,
        .heightBehaviorScreenFraction,
        .heightBehaviorAutomaticTallFloor,
      ]),
      ("Two-column list · edge cases", [
        .emptyCategorySyntheticSelection,
        .reselectOnChangeOnlyWhenSelectionChanged,
        .onChangeOnlyWithoutSelectionHandler,
      ]),
    ].map { title, cases in
      FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
    }
  }

  // MARK: - Two-column grid

  private static var twoColumnGridSections: [FKTabBarFilterExampleListSection] {
    [
      ("Two-column grid · baseline", [FKTabBarFilterTwoColumnGridExampleCase.baselineDefaults]),
      ("Two-column grid · section headers", [
        .sectionCollapsePlain,
        .sectionCollapseInsetGroupedChrome,
        .collapseChevronHidden,
        .headerSelectionWithoutCollapse,
      ]),
      ("Two-column grid · selection", [
        .globalSingleAcrossSections,
        .withinSectionSingle,
        .multipleSelectionTabAndSections,
      ]),
      ("Two-column grid · customization", [
        .customLeftAndItemCells,
        .narrowLeftColumn,
        .singleColumnDense,
        .fourColumnsWide,
        .disabledPillItem,
      ]),
      ("Two-column grid · height", [.heightBehaviorFixed, .heightBehaviorCapped]),
      ("Two-column grid · callbacks", [.onChangeOnlyNoSelection, .reselectOnChangeOnlyWhenSelectionChanged]),
    ].map { title, cases in
      FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
    }
  }

  // MARK: - Chips

  private static var chipsSections: [FKTabBarFilterExampleListSection] {
    [
      ("Chips · structure & selection", [
        FKTabBarFilterChipsPanelExampleCase.baselineSingleSection,
        .twoSectionsSingleSelect,
        .multipleSelectionTabAndSections,
      ]),
      ("Chips · grid layout", [.columnsTwo, .columnsSix]),
      ("Chips · height", [.heightFixed, .heightCapped, .heightScreenFraction]),
      ("Chips · appearance", [.customPillStyle, .wideContentInsets, .tallRowHeight]),
      ("Chips · edge cases", [.disabledChip, .onChangeOnlyNoSelection]),
    ].map { title, cases in
      FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
    }
  }

  // MARK: - Single list

  private static var singleListSections: [FKTabBarFilterExampleListSection] {
    [
      ("Single list · selection", [
        FKTabBarFilterSingleListPanelExampleCase.baselineSingle,
        .multipleSelection,
      ]),
      ("Single list · cell content", [.subtitles, .attributedTitle, .disabledRow, .darkCellStyle]),
      ("Single list · layout & hooks", [.showsFooter, .wideSeparatorInset, .configureCellAccessory, .tallRows]),
      ("Single list · height", [.heightFixed, .heightCapped]),
      ("Single list · callbacks", [.onChangeOnlyNoSelection]),
    ].map { title, cases in
      FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
    }
  }
}

// MARK: - List rows

private extension FKTabBarFilterTwoColumnListExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterTwoColumnListExampleDetailViewController(exampleCase: self)
    }
  }
}

private extension FKTabBarFilterTwoColumnGridExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterTwoColumnGridExampleDetailViewController(exampleCase: self)
    }
  }
}

private extension FKTabBarFilterChipsPanelExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterChipsPanelExampleDetailViewController(exampleCase: self)
    }
  }
}

private extension FKTabBarFilterSingleListPanelExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterSingleListPanelExampleDetailViewController(exampleCase: self)
    }
  }
}
