import UIKit
import FKUIKit
import FKBusinessKit

/// Individual anchored-dropdown + ``FKTabBarFilterController`` patterns (English data, ``FKTabBarFilterExampleStaticData``).
enum FKTabBarFilterDropdownAnchoredExample: Int, CaseIterable {
  /// Six panel kinds with a scrollable, intrinsic-width tab strip.
  case scrollableSixPanels
  /// Equal tabs: scope · course grid · multi-select tags.
  case equalCommerce
  /// Equal tabs: two-column browse · formats · sort list.
  case equalLibrary
  /// Equal tabs + default crossfade (baseline for comparing other equal-tab tweaks).
  case compactCrossfadeBaseline
  /// Tab changes dismiss then re-present the anchored shell.
  case switchDismissThenPresent
  /// In-place tab switch with vertical slide.
  case switchSlideVertical
  /// Heavier backdrop dimming.
  case backdropStrongDim
  /// Zero-alpha dim + passthrough interaction on the presenter.
  case backdropPassthrough
  /// No per-tab view-controller cache.
  case contentRecreate
  /// Slower ``FKTabBarFilterDropdownConfiguration/presentationLayoutAnimation`` after height changes.
  case layoutAnimationSlow

  var menuTitle: String {
    switch self {
    case .scrollableSixPanels: return "All panel kinds · scrollable strip"
    case .equalCommerce: return "Equal tabs · scope & catalog & tags"
    case .equalLibrary: return "Equal tabs · browse & formats & sort"
    case .compactCrossfadeBaseline: return "Equal tabs · crossfade baseline"
    case .switchDismissThenPresent: return "Tab switch · dismiss then present"
    case .switchSlideVertical: return "Tab switch · slide vertical"
    case .backdropStrongDim: return "Backdrop · strong dim"
    case .backdropPassthrough: return "Backdrop · passthrough (zero dim)"
    case .contentRecreate: return "Content caching · recreate"
    case .layoutAnimationSlow: return "Layout animation · slow relayout"
    }
  }

  var menuSubtitle: String {
    switch self {
    case .scrollableSixPanels:
      return "Hierarchy, grid, two chip columns, tags, and single list — intrinsic-width tabs."
    case .equalCommerce:
      return "Three equal-width tabs using dual grid, secondary chips, and multi-select tags."
    case .equalLibrary:
      return "Two-column list, primary chip grid, and centered single list."
    case .compactCrossfadeBaseline:
      return "Three compact tabs; default replace-in-place crossfade between panels."
    case .switchDismissThenPresent:
      return "Uses dismiss-then-present when changing tabs while the panel stays open."
    case .switchSlideVertical:
      return "Replace-in-place with a vertical slide between panel contents."
    case .backdropStrongDim:
      return "Higher dim alpha on the anchored presentation backdrop."
    case .backdropPassthrough:
      return "Zero dim + passthrough so taps fall through to the screen behind."
    case .contentRecreate:
      return "contentCachingPolicy .recreate — panels rebuild when re-opened."
    case .layoutAnimationSlow:
      return "Longer presentationLayoutAnimation when preferredContentSize changes."
    }
  }

  var screenTitle: String { menuTitle }

  fileprivate var filterConfiguration: FKTabBarFilterConfiguration<String> {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleAppearance.makeHubFilterConfiguration()
    case .equalCommerce, .equalLibrary:
      return FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration()
    case .compactCrossfadeBaseline:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeAnchoredConfiguration())
    case .switchDismissThenPresent:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeDismissThenPresent())
    case .switchSlideVertical:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeSlideVerticalSwitch())
    case .backdropStrongDim:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeStrongBackdrop())
    case .backdropPassthrough:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreePassthroughBackdrop())
    case .contentRecreate:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeRecreateContent())
    case .layoutAnimationSlow:
      return FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: FKTabBarFilterExampleAppearance.equalThreeSlowLayoutAnimation())
    }
  }

  fileprivate var initialState: FKTabBarFilterExampleState {
    switch self {
    case .scrollableSixPanels:
      return FKTabBarFilterExampleState.presetFullHub()
    case .equalCommerce:
      return FKTabBarFilterExampleState.presetEqualBusiness()
    case .equalLibrary:
      return FKTabBarFilterExampleState.presetEqualKnowledge()
    case .compactCrossfadeBaseline, .switchDismissThenPresent, .switchSlideVertical, .backdropStrongDim, .backdropPassthrough,
         .contentRecreate, .layoutAnimationSlow:
      return FKTabBarFilterExampleState.presetCompactThree()
    }
  }

  /// `tagsTitle` is only read for ``scrollableSixPanels`` (live tab title after clearing tags).
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
    case .equalCommerce:
      return [
        .init(id: "scope", panelKind: .gridSecondary, title: "Scope"),
        .init(id: "catalog", panelKind: .dualHierarchy, title: "Catalog"),
        .init(
          id: "tags",
          panelKind: .tags,
          title: "Topics",
          subtitle: "Optional multi-select",
          allowsMultipleSelection: true
        ),
      ]
    case .equalLibrary, .compactCrossfadeBaseline, .switchDismissThenPresent, .switchSlideVertical, .backdropStrongDim,
         .backdropPassthrough, .contentRecreate, .layoutAnimationSlow:
      return [
        .init(id: "browse", panelKind: .hierarchy, title: "Browse"),
        .init(id: "formats", panelKind: .gridPrimary, title: "Formats"),
        .init(id: "sort", panelKind: .singleList, title: "Sort"),
      ]
    }
  }

  fileprivate var usesTagsTitleCallback: Bool {
    switch self {
    case .scrollableSixPanels: return true
    default: return false
    }
  }
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

    let panelFactory: FKTabBarFilterPanelFactory
    if anchoredExample.usesTagsTitleCallback {
      panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(
        bindingTo: filterState,
        filterConfiguration: anchoredExample.filterConfiguration,
        onTagsSelectionEmptied: { [weak self] in
          guard let self else { return }
          self.tagsTabTitle = "Topics"
          self.filterHost.dropdownController.reloadTabBarItems()
        }
      )
    } else {
      panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(
        bindingTo: filterState,
        filterConfiguration: anchoredExample.filterConfiguration
      )
    }

    let tabs = anchoredExample.makeTabs(tagsTitle: { [weak self] in self?.tagsTabTitle ?? "Topics" })
    filterHost = FKTabBarFilterController(
      tabs: tabs,
      panelFactory: panelFactory,
      filterConfiguration: anchoredExample.filterConfiguration,
      tabBarHost: tabStrip
    )

    guard let strip = FKTabBarFilterExampleChrome.embed(
      filterHost: filterHost,
      in: self,
      topAnchor: view.safeAreaLayoutGuide.topAnchor,
      overlayHost: view,
      logSelection: true
    ) else { return }
    FKTabBarFilterExampleChrome.installBodyPlaceholder(below: strip.bottomAnchor, in: self)
    let tabIDs = anchoredExample.makeTabs(tagsTitle: { [weak self] in self?.tagsTabTitle ?? "Topics" }).map(\.id)
    tabIDs.forEach { filterHost.invalidateCachedPanelContent(for: $0) }
  }
}
