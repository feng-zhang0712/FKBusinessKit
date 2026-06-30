import UIKit
import FKUIKit
import FKBusinessKit

/// Describes one isolated ``FKTabBarFilterTwoColumnListViewController`` configuration for the list examples hub.
enum FKTabBarFilterTwoColumnListExampleCase: Int, CaseIterable {
  case baselinePlainDefaults
  case plainStyleExplicit
  case insetGroupedFullGroupedConfiguration
  case groupedFootersOnly
  case globalSingleAcrossSections
  case withinSectionSingleTwoSections
  case multipleSelectionTabAndSections
  case sectionMultipleTabSingleEffectiveSingle
  case sectionsWithoutVisibleHeaders
  case systemTitledSectionHeaders
  case selectableSectionHeadersPreset
  case selectableHeadersCustomStyle
  case disabledRowAndAttributedText
  case customLeftAndRightCellHooks
  case narrowCategoryColumnRatio
  case wideRightSeparatorInsets
  case heightBehaviorFixed
  case heightBehaviorCapped
  case heightBehaviorScreenFraction
  case heightBehaviorAutomaticTallFloor
  case emptyCategorySyntheticSelection
  case reselectOnChangeOnlyWhenSelectionChanged
  case onChangeOnlyWithoutSelectionHandler
  case customChromeAndListCellStyles
  case sectionCollapsePlainDefaults
  case sectionCollapseInsetGroupedMixedInitial
  case sectionCollapseChevronHidden

  var menuTitle: String {
    switch self {
    case .baselinePlainDefaults: return "Baseline · plain · defaults"
    case .plainStyleExplicit: return "Plain · explicit right table style"
    case .insetGroupedFullGroupedConfiguration: return "Inset grouped · full grouped configuration"
    case .groupedFootersOnly: return "Grouped · section footers only"
    case .globalSingleAcrossSections: return "Single · global across sections"
    case .withinSectionSingleTwoSections: return "Single · within section · two sections"
    case .multipleSelectionTabAndSections: return "Multiple · tab + sections"
    case .sectionMultipleTabSingleEffectiveSingle: return "Sections multiple · tab single (effective single)"
    case .sectionsWithoutVisibleHeaders: return "Sections without visible headers"
    case .systemTitledSectionHeaders: return "System titled section headers"
    case .selectableSectionHeadersPreset: return "Selectable headers · static preset"
    case .selectableHeadersCustomStyle: return "Selectable headers · custom chrome"
    case .disabledRowAndAttributedText: return "Disabled row · attributed title/subtitle"
    case .customLeftAndRightCellHooks: return "Custom left/right cell hooks"
    case .narrowCategoryColumnRatio: return "Narrow category column ratio"
    case .wideRightSeparatorInsets: return "Wide right separator insets"
    case .heightBehaviorFixed: return "Height behavior · fixed"
    case .heightBehaviorCapped: return "Height behavior · capped"
    case .heightBehaviorScreenFraction: return "Height behavior · screen fraction"
    case .heightBehaviorAutomaticTallFloor: return "Height behavior · automatic tall floor"
    case .emptyCategorySyntheticSelection: return "Empty category · synthetic selection"
    case .reselectOnChangeOnlyWhenSelectionChanged: return "Reselect · onChange when selection changed"
    case .onChangeOnlyWithoutSelectionHandler: return "onChange only · no onSelection"
    case .customChromeAndListCellStyles: return "Custom chrome · list cell styles"
    case .sectionCollapsePlainDefaults: return "Section collapse · plain · disclosure"
    case .sectionCollapseInsetGroupedMixedInitial: return "Section collapse · inset grouped · mixed initial"
    case .sectionCollapseChevronHidden: return "Section collapse · disclosure hidden"
    }
  }

  var menuSubtitle: String {
    switch self {
    case .baselinePlainDefaults:
      return "Default Configuration, single within section, titled sections."
    case .plainStyleExplicit:
      return "rightTableViewStyle .plain (same visuals as default)."
    case .insetGroupedFullGroupedConfiguration:
      return "insetGrouped + padding, footers, grouped table/cell/header colors."
    case .groupedFootersOnly:
      return "grouped + sectionFooterHeight only; other grouped fields default/nil."
    case .globalSingleAcrossSections:
      return "singleSelectionScope .globalAcrossSections; only one row selected in the right table."
    case .withinSectionSingleTwoSections:
      return "Default scope; each titled section keeps its own single selection."
    case .multipleSelectionTabAndSections:
      return "allowsMultipleSelection true; both sections use .multiple."
    case .sectionMultipleTabSingleEffectiveSingle:
      return "Sections request .multiple but tab disallows multi → effective single per rules."
    case .sectionsWithoutVisibleHeaders:
      return "Section titles empty → zero header height on the right."
    case .systemTitledSectionHeaders:
      return "rightSectionHeaderBehavior .standard → UIKit title headers."
    case .selectableSectionHeadersPreset:
      return "Configuration.sectionHeaderSelectable + header tap clears row picks."
    case .selectableHeadersCustomStyle:
      return "Selectable headers with custom RightHeaderStyle and grouped header background."
    case .disabledRowAndAttributedText:
      return "One disabled row; another uses AttributedString title and subtitle."
    case .customLeftAndRightCellHooks:
      return "configureLeftCell / configureRightCell build accessory and badges."
    case .narrowCategoryColumnRatio:
      return "leftColumnWidthRatio 0.22."
    case .wideRightSeparatorInsets:
      return "Large left/right separator inset on the right table."
    case .heightBehaviorFixed:
      return ".fixed(300) regardless of row count."
    case .heightBehaviorCapped:
      return ".capped(maximum: 240) with enough rows to hit the cap."
    case .heightBehaviorScreenFraction:
      return ".screenFraction(0.42) with min/max clamps."
    case .heightBehaviorAutomaticTallFloor:
      return ".automatic with high minimum + screen fraction floor."
    case .emptyCategorySyntheticSelection:
      return "Category with no sections → synthetic FKTabBarFilterPanelSelection when chosen."
    case .reselectOnChangeOnlyWhenSelectionChanged:
      return "reselectBehavior .firesOnChangeOnlyWhenSelectionChanged (left, right, header)."
    case .onChangeOnlyWithoutSelectionHandler:
      return "onSelection omitted; only onChange fires (still logged)."
    case .customChromeAndListCellStyles:
      return "Custom backgrounds and FKTabBarFilterListCellStyle on both sides."
    case .sectionCollapsePlainDefaults:
      return "rightSectionHeaderBehavior .togglesSectionCollapse; one section starts collapsed."
    case .sectionCollapseInsetGroupedMixedInitial:
      return "Grouped chrome + collapse; same default collapsed section."
    case .sectionCollapseChevronHidden:
      return "showsSectionCollapseDisclosureIndicator false."
    }
  }

  func makeSpec() -> FKTabBarFilterTwoColumnListExamplePanelSpec {
    switch self {
    case .baselinePlainDefaults:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .plainStyleExplicit:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(rightTableViewStyle: .plain),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .insetGroupedFullGroupedConfiguration:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          rightTableViewStyle: .insetGrouped,
          rightGroupedTableConfiguration: .init(
            sectionHeaderTopPadding: 6,
            sectionFooterHeight: 10,
            selectableSectionHeaderBackgroundColor: UIColor.secondarySystemGroupedBackground,
            tableBackgroundColor: .systemGroupedBackground,
            cellBackgroundColor: .secondarySystemGroupedBackground
          ),
          rightSectionHeaderBehavior: .selectableSectionHeader,
          singleSelectionScope: .globalAcrossSections
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .groupedFootersOnly:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          rightTableViewStyle: .grouped,
          rightGroupedTableConfiguration: .init(sectionFooterHeight: 14)
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .globalSingleAcrossSections:
      return .init(
        model: Self.globalScopeModel(),
        configuration: .init(singleSelectionScope: .globalAcrossSections),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .withinSectionSingleTwoSections:
      return .init(
        model: Self.globalScopeModel(),
        configuration: .init(singleSelectionScope: .withinSection),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .multipleSelectionTabAndSections:
      return .init(
        model: Self.multiSectionModel(),
        configuration: .init(),
        allowsMultipleSelection: true,
        deliversSelectionEvents: true
      )
    case .sectionMultipleTabSingleEffectiveSingle:
      return .init(
        model: Self.multiSectionModel(),
        configuration: .init(),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .sectionsWithoutVisibleHeaders:
      return .init(
        model: Self.blankHeaderTitlesModel(),
        configuration: .init(),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .systemTitledSectionHeaders:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          sectionHeaderHeight: 32,
          rightSectionHeaderBehavior: .standard
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .selectableSectionHeadersPreset:
      return .init(
        model: Self.headerPickModel(),
        configuration: .sectionHeaderSelectable,
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .selectableHeadersCustomStyle:
      let headerStyle = FKTabBarFilterTwoColumnListViewController.RightHeaderStyle(
        normalTextColor: .secondaryLabel,
        selectedTextColor: .systemGreen,
        font: .preferredFont(forTextStyle: .headline),
        contentInsets: .init(top: 12, left: 20, bottom: 12, right: 20),
        minimumHeight: 52
      )
      return .init(
        model: Self.headerPickModel(),
        configuration: .init(
          sectionHeaderHeight: 52,
          rightTableViewStyle: .insetGrouped,
          rightGroupedTableConfiguration: .init(
            sectionHeaderTopPadding: 4,
            sectionFooterHeight: 8,
            selectableSectionHeaderBackgroundColor: UIColor.tertiarySystemGroupedBackground,
            tableBackgroundColor: .systemGroupedBackground,
            cellBackgroundColor: .secondarySystemGroupedBackground
          ),
          rightSectionHeaderStyle: headerStyle,
          rightSectionHeaderBehavior: .selectableSectionHeader,
          singleSelectionScope: .globalAcrossSections
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .disabledRowAndAttributedText:
      return .init(
        model: Self.attributedModel(),
        configuration: .init(rowHeight: 52),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .customLeftAndRightCellHooks:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          configureLeftCell: { cell, _, category in
            cell.textLabel?.text = category.title
            cell.detailTextLabel?.text = nil
            cell.accessoryType = category.isSelected ? .checkmark : .none
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            cell.textLabel?.textColor = category.isSelected ? .systemIndigo : .label
            cell.backgroundColor = category.isSelected ? .systemIndigo.withAlphaComponent(0.12) : .systemGray6
            cell.selectionStyle = .none
          },
          configureRightCell: { cell, _, item, section in
            cell.textLabel?.text = "\(section.id.rawValue.uppercased()) · \(item.title)"
            cell.detailTextLabel?.text = item.subtitle
            cell.accessoryType = item.isSelected ? .checkmark : .none
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            cell.detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)
            cell.backgroundColor = .secondarySystemBackground
            cell.selectionStyle = .default
          }
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .narrowCategoryColumnRatio:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(leftColumnWidthRatio: 0.22),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .wideRightSeparatorInsets:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(rightSeparatorInset: .init(top: 0, left: 32, bottom: 0, right: 32)),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .heightBehaviorFixed:
      return .init(
        model: Self.tallModel(),
        configuration: .init(heightBehavior: .fixed(300)),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .heightBehaviorCapped:
      return .init(
        model: Self.tallModel(),
        configuration: .init(heightBehavior: .capped(maximum: 240, minimum: 100)),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .heightBehaviorScreenFraction:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          heightBehavior: .screenFraction(0.42, minimum: 120, maximum: 420)
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .heightBehaviorAutomaticTallFloor:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          heightBehavior: .automatic(
            minimum: 220,
            screenMinimumFraction: 0.48,
            maximumScreenFraction: 0.92
          )
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .emptyCategorySyntheticSelection:
      return .init(
        model: Self.emptyCategoryModel(),
        configuration: .init(),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .reselectOnChangeOnlyWhenSelectionChanged:
      return .init(
        model: Self.emptyCategoryModel(),
        configuration: .init(reselectBehavior: .firesOnChangeOnlyWhenSelectionChanged),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .onChangeOnlyWithoutSelectionHandler:
      return .init(
        model: Self.catalogModel(),
        configuration: .init(),
        allowsMultipleSelection: false,
        deliversSelectionEvents: false
      )
    case .customChromeAndListCellStyles:
      let leftStyle = FKTabBarFilterListCellStyle(
        font: .italicSystemFont(ofSize: 15),
        normalTextColor: .white,
        selectedTextColor: .systemYellow,
        disabledTextColor: .lightGray,
        textAlignment: .center,
        rowBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.35),
        selectedRowBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.55)
      )
      let rightStyle = FKTabBarFilterListCellStyle(
        font: .monospacedSystemFont(ofSize: 14, weight: .regular),
        normalTextColor: .label,
        selectedTextColor: .systemOrange,
        disabledTextColor: .tertiaryLabel,
        textAlignment: .natural,
        rowBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.08),
        selectedRowBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.18)
      )
      return .init(
        model: Self.catalogModel(),
        configuration: .init(
          leftCellStyle: leftStyle,
          rightCellStyle: rightStyle,
          leftBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.25),
          rightBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.04)
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .sectionCollapsePlainDefaults:
      return .init(
        model: Self.collapseSampleModel(),
        configuration: .init(
          rightSectionHeaderBehavior: .togglesSectionCollapse
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .sectionCollapseInsetGroupedMixedInitial:
      return .init(
        model: Self.collapseSampleModel(),
        configuration: .init(
          rightTableViewStyle: .insetGrouped,
          rightGroupedTableConfiguration: .init(
            sectionFooterHeight: 6,
            tableBackgroundColor: .systemGroupedBackground,
            cellBackgroundColor: .secondarySystemGroupedBackground
          ),
          rightSectionHeaderBehavior: .togglesSectionCollapse
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    case .sectionCollapseChevronHidden:
      return .init(
        model: Self.collapseSampleModel(),
        configuration: .init(
          rightSectionHeaderBehavior: .togglesSectionCollapse,
          showsSectionCollapseDisclosureIndicator: false
        ),
        allowsMultipleSelection: false,
        deliversSelectionEvents: true
      )
    }
  }

  // MARK: - Private sample models

  private static let catAlpha = FKTabBarFilterID(rawValue: "cat.alpha")
  private static let catBeta = FKTabBarFilterID(rawValue: "cat.beta")
  private static let catEmpty = FKTabBarFilterID(rawValue: "cat.empty")

  private static func collapseSampleModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Catalog", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "col.open"),
          title: "Expanded by default",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "col1"), title: "Row 1", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "col2"), title: "Row 2", isSelected: false),
          ],
          isCollapsed: false
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "col.closed"),
          title: "Collapsed by default",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "col3"), title: "Row 3", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "col4"), title: "Row 4", isSelected: false),
          ],
          isCollapsed: true
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func catalogModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Alpha", isSelected: true),
      .init(id: catBeta, title: "Beta", isSelected: false),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "sec.alpha.a"),
          title: "Alpha · Group A",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "a1"), title: "Option A1", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "a2"), title: "Option A2", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "a3"), title: "Option A3", isSelected: false),
          ]
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "sec.alpha.b"),
          title: "Alpha · Group B",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "b1"), title: "Option B1", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "b2"), title: "Option B2", isSelected: true),
          ]
        ),
      ],
      catBeta: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "sec.beta.a"),
          title: "Beta · Group A",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "c1"), title: "Option C1", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "c2"), title: "Option C2", isSelected: false),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func globalScopeModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Scope sample", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "sec.one"),
          title: "First section",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "s1a"), title: "Row 1A", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "s1b"), title: "Row 1B", isSelected: false),
          ]
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "sec.two"),
          title: "Second section",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "s2a"), title: "Row 2A", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "s2b"), title: "Row 2B", isSelected: false),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func multiSectionModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Multi", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "m1"),
          title: "Tags A",
          selectionMode: .multiple,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "t1"), title: "Tag 1", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "t2"), title: "Tag 2", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "t3"), title: "Tag 3", isSelected: false),
          ]
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "m2"),
          title: "Tags B",
          selectionMode: .multiple,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "u1"), title: "Tag 4", isSelected: false),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "u2"), title: "Tag 5", isSelected: false),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func blankHeaderTitlesModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "No headers", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "nh1"),
          title: "",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "r1"), title: "Row without header text", isSelected: true),
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "r2"), title: "Second row", isSelected: false),
          ]
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "nh2"),
          title: nil,
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "r3"), title: "Nil title → no header chrome", isSelected: false),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func headerPickModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Headers", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "hp1"),
          title: "Pick this header",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "p1"), title: "Row under first header", isSelected: false),
          ]
        ),
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "hp2"),
          title: "Or this header",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "p2"), title: "Row under second header", isSelected: true),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func attributedModel() -> FKTabBarFilterTwoColumnModel {
    var titleAttr = AttributedString("Promoted · Rich title")
    titleAttr.foregroundColor = .systemPurple

    var subtitleAttr = AttributedString("Attributed subtitle line")
    subtitleAttr.foregroundColor = .secondaryLabel

    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Attributed", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "at1"),
          title: "Rows",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(
              id: FKTabBarFilterID(rawValue: "att1"),
              title: "Plain title fallback",
              subtitle: "Plain subtitle",
              attributedTitle: titleAttr,
              attributedSubtitle: subtitleAttr,
              isSelected: true
            ),
            FKTabBarFilterOptionItem(
              id: FKTabBarFilterID(rawValue: "att2"),
              title: "Disabled row",
              subtitle: "Cannot be selected",
              isSelected: false,
              isEnabled: false
            ),
            FKTabBarFilterOptionItem(
              id: FKTabBarFilterID(rawValue: "att3"),
              title: "Enabled sibling",
              isSelected: false
            ),
          ]
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func tallModel() -> FKTabBarFilterTwoColumnModel {
    let rows = (1 ... 14).map { idx in
      FKTabBarFilterOptionItem(
        id: FKTabBarFilterID(rawValue: "tall.\(idx)"),
        title: "Tall list row \(idx)",
        isSelected: idx == 1
      )
    }
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "Tall", isSelected: true),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "tall.sec"),
          title: "Many rows",
          selectionMode: .single,
          items: rows
        ),
      ],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }

  private static func emptyCategoryModel() -> FKTabBarFilterTwoColumnModel {
    let categories: [FKTabBarFilterTwoColumnModel.Category] = [
      .init(id: catAlpha, title: "With rows", isSelected: true),
      .init(id: catEmpty, title: "Empty category", isSelected: false),
    ]
    let sections: [FKTabBarFilterID: [FKTabBarFilterSection]] = [
      catAlpha: [
        FKTabBarFilterSection(
          id: FKTabBarFilterID(rawValue: "ec1"),
          title: "Data",
          selectionMode: .single,
          items: [
            FKTabBarFilterOptionItem(id: FKTabBarFilterID(rawValue: "e1"), title: "Only here", isSelected: true),
          ]
        ),
      ],
      catEmpty: [],
    ]
    return FKTabBarFilterTwoColumnModel(categories: categories, sectionsByCategoryID: sections)
  }
}

struct FKTabBarFilterTwoColumnListExamplePanelSpec {
  let model: FKTabBarFilterTwoColumnModel
  let configuration: FKTabBarFilterTwoColumnListViewController.Configuration
  let allowsMultipleSelection: Bool
  let deliversSelectionEvents: Bool
}
