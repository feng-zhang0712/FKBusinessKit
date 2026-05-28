import UIKit
import FKUIKit

/// Invoked on the main actor after the panel applies the selection; single-select panels also update the tab title and collapse.
public typealias FKTabBarFilterSelectionHandler<TabID: Hashable> = @MainActor (_ context: FKTabBarFilterSelectionContext<TabID>) -> Void

@MainActor
private final class FKTabBarFilterRuntimeState<TabID: Hashable> {
  weak var dropdown: FKTabBarFilterDropdownController<TabID>?
  var onSelection: FKTabBarFilterSelectionHandler<TabID>?
  private var titleOverrides: [TabID: String] = [:]

  func displayTitle(for id: TabID, fallback: @escaping () -> String) -> String {
    titleOverrides[id] ?? fallback()
  }

  func setTitleOverride(_ title: String, for id: TabID) {
    titleOverrides[id] = title
  }

  func removeTitleOverride(for id: TabID) {
    titleOverrides[id] = nil
  }

  func removeAllTitleOverrides() {
    titleOverrides.removeAll(keepingCapacity: false)
  }

  func dismissIfSingleSelect(mode: FKTabBarFilterSelectionMode) {
    guard mode == .single else { return }
    dropdown?.collapsePanel(animated: true)
  }
}

/// Filter strip plus anchored dropdown panels, built from ``FKTabBarFilterPanelFactory``.
@MainActor
public final class FKTabBarFilterController<TabID: Hashable>: UIViewController {
  public let dropdownController: FKTabBarFilterDropdownController<TabID>
  public let panelFactory: FKTabBarFilterPanelFactory

  /// Shared filter chrome and dropdown defaults.
  public private(set) var filterConfiguration: FKTabBarFilterConfiguration<TabID>

  private var filterTabs: [FKTabBarFilterTab<TabID>]
  private let runtime = FKTabBarFilterRuntimeState<TabID>()

  /// Invoked after the panel applies the selection; single-select panels also update the tab title and collapse.
  public var onSelection: FKTabBarFilterSelectionHandler<TabID>? {
    get { runtime.onSelection }
    set { runtime.onSelection = newValue }
  }

  public init(
    tabs: [FKTabBarFilterTab<TabID>],
    panelFactory: FKTabBarFilterPanelFactory,
    filterConfiguration: FKTabBarFilterConfiguration<TabID> = FKTabBarFilterConfiguration(),
    tabBarHost: (any FKTabBarFilterTabBarHost)? = nil,
    onSelection: FKTabBarFilterSelectionHandler<TabID>? = nil
  ) {
    self.filterTabs = tabs
    self.panelFactory = panelFactory
    self.filterConfiguration = filterConfiguration
    runtime.onSelection = onSelection
    self.dropdownController = FKTabBarFilterDropdownController(
      tabs: Self.makeAnchoredTabs(
        tabs: tabs,
        panelFactory: panelFactory,
        runtime: runtime,
        defaultTabStrip: filterConfiguration.defaultTabStrip
      ),
      tabBarHost: tabBarHost,
      configuration: filterConfiguration.dropdownConfiguration,
      events: filterConfiguration.dropdownEvents
    )
    super.init(nibName: nil, bundle: nil)
    runtime.dropdown = dropdownController
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    addChild(dropdownController)
    dropdownController.loadViewIfNeeded()
    guard let hostView = dropdownController.view else {
      assertionFailure("FKTabBarFilterController child view is missing after loadViewIfNeeded()")
      return
    }
    hostView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hostView)
    NSLayoutConstraint.activate([
      hostView.topAnchor.constraint(equalTo: view.topAnchor),
      hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    dropdownController.didMove(toParent: self)
  }

  /// Replaces tabs, clears title overrides, and reloads the strip.
  public func replaceTabs(_ tabs: [FKTabBarFilterTab<TabID>]) {
    filterTabs = tabs
    runtime.removeAllTitleOverrides()
    dropdownController.updateTabs(
      Self.makeAnchoredTabs(
        tabs: tabs,
        panelFactory: panelFactory,
        runtime: runtime,
        defaultTabStrip: filterConfiguration.defaultTabStrip
      )
    )
  }

  /// Updates dropdown configuration and strip defaults without changing the tab list.
  public func setFilterConfiguration(_ configuration: FKTabBarFilterConfiguration<TabID>) {
    filterConfiguration = configuration
    dropdownController.configuration = configuration.dropdownConfiguration
    dropdownController.events = configuration.dropdownEvents
    dropdownController.updateTabs(
      Self.makeAnchoredTabs(
        tabs: filterTabs,
        panelFactory: panelFactory,
        runtime: runtime,
        defaultTabStrip: configuration.defaultTabStrip
      )
    )
  }

  public func removeTitleOverride(for tabID: TabID) {
    runtime.removeTitleOverride(for: tabID)
    dropdownController.reloadTabBarItems()
  }

  public func removeAllTitleOverrides() {
    runtime.removeAllTitleOverrides()
    dropdownController.reloadTabBarItems()
  }

  public func invalidateCachedPanelContent(for tab: TabID) {
    dropdownController.invalidateCachedContent(for: tab)
  }

  /// Pins mask and panel layout to `hostView` while the tab bar remains the anchor source.
  public func pinAnchoredPresentationOverlay(to hostView: UIView) {
    dropdownController.setAnchor(source: dropdownController.tabBar, overlayHost: hostView)
  }

  private static func makeAnchoredTabs(
    tabs: [FKTabBarFilterTab<TabID>],
    panelFactory: FKTabBarFilterPanelFactory,
    runtime: FKTabBarFilterRuntimeState<TabID>,
    defaultTabStrip: FKTabBarFilterTabStripConfiguration
  ) -> [FKTabBarFilterDropdownTab<TabID>] {
    tabs.map { tab in
      let tabID = tab.id
      let baseTitle = tab.title
      let m = tab.tabStrip ?? defaultTabStrip
      let titleForBar: () -> String = {
        runtime.displayTitle(for: tabID, fallback: baseTitle)
      }
      return FKTabBarFilterDropdownTab.chevronTitle(
        id: tab.id,
        title: titleForBar,
        subtitle: tab.subtitle,
        normalTitleColor: m.normalTitleColor,
        expandedTitleColor: m.expandedTitleColor,
        normalChevronColor: m.normalChevronColor,
        expandedChevronColor: m.expandedChevronColor,
        titleFont: UIFont.preferredFont(forTextStyle: m.titleTextStyle),
        subtitleFont: UIFont.preferredFont(forTextStyle: m.subtitleTextStyle),
        chevronSize: m.chevronSize,
        chevronSpacing: m.chevronSpacing,
        titleSubtitleSpacing: m.titleSubtitleSpacing,
        content: .viewController {
          panelFactory.makePanel(
            for: tab.panelKind,
            allowsMultipleSelection: tab.allowsMultipleSelection,
            onSelection: { selection in
              if selection.effectiveSelectionMode == .single {
                runtime.setTitleOverride(selection.item.title, for: tab.id)
                runtime.dropdown?.reloadTabBarItems()
              }
              let context = FKTabBarFilterSelectionContext(tabID: tab.id, panelKind: tab.panelKind, selection: selection)
              runtime.onSelection?(context)
              runtime.dismissIfSingleSelect(mode: selection.effectiveSelectionMode)
            }
          ) ?? UIViewController()
        }
      )
    }
  }
}
