import UIKit
import FKUIKit
import FKBusinessKit

/// Anchored-dropdown + ``FKTabBarFilterController`` patterns that need a dedicated screen layout.
enum FKTabBarFilterDropdownAnchoredExample: Int, CaseIterable {
  /// Six panel kinds with a scrollable, intrinsic-width tab strip.
  case scrollableSixPanels
  /// ``FKTabBarFilterPanelFactory/PanelSource/custom(make:)`` tab.
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
      return "Hierarchy, grid, two chip columns, tags, and single list — intrinsic-width tabs."
    case .customPanelKind:
      return "Middle tab uses PanelSource.custom instead of a built-in panel recipe."
    }
  }

  var screenTitle: String { menuTitle }

  fileprivate var filterConfiguration: FKTabBarFilterConfiguration<String> {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleAppearance.makeHubFilterConfiguration()
    case .customPanelKind:
      return FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration()
    }
  }

  fileprivate var initialState: FKTabBarFilterExampleState {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleState.presetFullHub()
    case .customPanelKind:
      return FKTabBarFilterExampleState.presetEqualKnowledge()
    }
  }

  fileprivate func makeTabs(tagsTitle: @escaping () -> String) -> [FKTabBarFilterTab<String>] {
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

  fileprivate var usesTagsTitleCallback: Bool {
    self == .scrollableSixPanels
  }

  fileprivate var includesCustomPromoPanel: Bool {
    self == .customPanelKind
  }

  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(
      title: menuTitle,
      subtitle: menuSubtitle,
      makeViewController: { FKTabBarFilterDropdownAnchoredExampleViewController(anchoredExample: self) }
    )
  }

  static let hubSections: [FKTabBarFilterExampleListSection] = [
    FKTabBarFilterExampleListSection(
      title: "Filter strip demos",
      rows: [
        FKTabBarFilterDropdownAnchoredExample.scrollableSixPanels.listRow,
        FKTabBarFilterExampleListRow(
          title: "Equal-width tabs",
          subtitle: "Commerce vs library datasets — switch panel recipes on one screen."
        ) {
          FKTabBarFilterEqualWidthTabsPlaygroundViewController()
        },
        FKTabBarFilterExampleListRow(
          title: "Configuration playground",
          subtitle: "Tab switching, caching, backdrop, hairline, and slow relayout — toggles on one screen."
        ) {
          FKTabBarFilterConfigurationPlaygroundViewController()
        },
        FKTabBarFilterDropdownAnchoredExample.customPanelKind.listRow,
      ]
    ),
  ]
}

/// Hosts ``FKTabBarFilterController`` for a single ``FKTabBarFilterDropdownAnchoredExample`` pattern.
final class FKTabBarFilterDropdownAnchoredExampleViewController: UIViewController {
  private let anchoredExample: FKTabBarFilterDropdownAnchoredExample
  private let filterState: FKTabBarFilterExampleState
  private let tabStrip = FKTabBarFilterExampleTabStripView()
  private var tagsTabTitle = "Topics"
  private var filterHost: FKTabBarFilterController<String>!

  init(anchoredExample: FKTabBarFilterDropdownAnchoredExample) {
    self.anchoredExample = anchoredExample
    self.filterState = anchoredExample.initialState
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = anchoredExample.screenTitle
    view.backgroundColor = .systemBackground

    let panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(
      bindingTo: filterState,
      wrapsPanelWithTopHairline: true,
      onTagsSelectionEmptied: anchoredExample.usesTagsTitleCallback ? { [weak self] in
        guard let self else { return }
        self.tagsTabTitle = "Topics"
        self.filterHost.reloadTabBarItems()
      } : nil,
      includesCustomPromoPanel: anchoredExample.includesCustomPromoPanel
    )

    let tabs = anchoredExample.makeTabs(tagsTitle: { [weak self] in self?.tagsTabTitle ?? "Topics" })
    filterHost = FKTabBarFilterController(
      tabs: tabs,
      panelFactory: panelFactory,
      configuration: anchoredExample.filterConfiguration,
      tabBarHost: tabStrip
    )

    guard let strip = FKTabBarFilterExampleChrome.embed(
      filterHost: filterHost,
      in: self,
      topAnchor: view.safeAreaLayoutGuide.topAnchor,
      overlayHost: view,
      logSelection: true
    ) else { return }
    _ = FKTabBarFilterExampleChrome.installBodyPlaceholder(below: strip.bottomAnchor, in: self)
  }
}
