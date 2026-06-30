import UIKit
import FKUIKit

/// Invoked on the main actor after the panel applies the selection; single-select panels also update the tab title and collapse.
public typealias FKTabBarFilterSelectionHandler<TabID: Hashable> = @MainActor (_ context: FKTabBarFilterSelectionContext<TabID>) -> Void

/// Filter strip: ``FKTabBar`` plus anchor-attached panels via ``FKSheetPresentationController``.
///
/// Factory-backed panels use ``FKTabBarFilterPanelFactory`` (optional when every tab uses custom ``FKTabBarFilterTabPanelContent``).
/// Custom panels use ``FKTabBarFilterTabPanelContent/view`` or ``FKTabBarFilterTabPanelContent/viewController``.
@MainActor
public final class FKTabBarFilterController<TabID: Hashable>: UIViewController {
  /// Why the panel transitioned to the collapsed state.
  public enum DismissReason: Equatable, Sendable {
    case userToggledSameTab
    case backdropOrSwipe
    case programmatic
    case switchingTab
  }

  public enum State: Equatable {
    case collapsed
    case expanding(tab: TabID)
    case expanded(tab: TabID)
    case collapsing(tab: TabID)
    case switching(from: TabID, to: TabID)
  }

  public private(set) var state: State = .collapsed
  public var selectedTabID: TabID? { selectedTabInternal }
  public var expandedTabID: TabID? { expandedTabInternal }
  public var isPanelExpanded: Bool { expandedTabInternal != nil }

  public let tabBarHost: any FKTabBarFilterTabBarHost
  public var tabBar: FKTabBar { tabBarHost.tabBar }

  public var configuration: FKTabBarFilterConfiguration<TabID> {
    didSet {
      if clearsAnchorPlacementOnNextConfigurationChange == false,
         configuration.anchorPlacement == nil,
         let previousPlacement = oldValue.anchorPlacement {
        configuration.anchorPlacement = previousPlacement
      }
      clearsAnchorPlacementOnNextConfigurationChange = false
      applyConfiguration()
      refreshResolvedTabs()
    }
  }

  /// Required when any tab uses ``FKTabBarFilterTabPanelContent/panelKind``; may be `nil` for view / viewController-only strips.
  public let panelFactory: FKTabBarFilterPanelFactory?

  public var onSelection: FKTabBarFilterSelectionHandler<TabID>? {
    get { runtime.onSelection }
    set { runtime.onSelection = newValue }
  }

  public init(
    tabs: [FKTabBarFilterTab<TabID>],
    configuration: FKTabBarFilterConfiguration<TabID> = FKTabBarFilterConfiguration(),
    panelFactory: FKTabBarFilterPanelFactory? = nil,
    tabBarHost: (any FKTabBarFilterTabBarHost)? = nil,
    onSelection: FKTabBarFilterSelectionHandler<TabID>? = nil
  ) {
    self.panelFactory = panelFactory
    self.filterTabs = tabs
    self.configuration = configuration
    self.tabBarHost = tabBarHost ?? FKTabBarFilterDefaultTabBarHost()
    runtime.onSelection = onSelection
    self.tabs = FKTabBarFilterTabResolver.resolve(
      tabs: tabs,
      panelFactory: panelFactory,
      runtime: runtime,
      tabAppearance: configuration.tabAppearance
    )
    super.init(nibName: nil, bundle: nil)
    runtime.controller = self
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Replaces tabs, clears title overrides, and reloads the strip.
  public func replaceTabs(_ tabs: [FKTabBarFilterTab<TabID>]) {
    filterTabs = tabs
    runtime.removeAllTitleOverrides()
    refreshResolvedTabs()
  }

  public func removeTitleOverride(for tabID: TabID) {
    runtime.removeTitleOverride(for: tabID)
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)
  }

  public func removeAllTitleOverrides() {
    runtime.removeAllTitleOverrides()
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)
  }

  public func pinAnchoredPresentationOverlay(to hostView: UIView) {
    setAnchor(source: tabBar, overlayHost: hostView)
  }

  public func applyAnchorInstallation(_ installation: FKTabBarFilterAnchorInstallation) {
    setAnchor(source: installation.sourceView, overlayHost: installation.overlayHost)
    configuration.anchorPlacement?.hostStrategy = installation.hostStrategy
  }

  public func expandPanel(for tab: TabID, animated: Bool = true) {
    enqueueDesiredExpandedTab(tab, animated: animated, collapseReasonWhenDismissing: .programmatic)
  }

  public func collapsePanel(animated: Bool = true) {
    enqueueDesiredExpandedTab(nil, animated: animated, collapseReasonWhenDismissing: .programmatic)
  }

  public func togglePanel(for tab: TabID, animated: Bool = true) {
    if expandedTabInternal == tab {
      enqueueDesiredExpandedTab(nil, animated: animated, collapseReasonWhenDismissing: .programmatic)
    } else {
      enqueueDesiredExpandedTab(tab, animated: animated, collapseReasonWhenDismissing: .programmatic)
    }
  }

  public func selectTab(_ id: TabID, animated: Bool = false) {
    guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
    selectedTabInternal = id
    tabBar.setSelectedIndex(idx, animated: animated, notify: false, reason: .programmatic)
    rebuildTabBarItems(keepSelectedTab: id)
  }

  public func reloadTabBarItems() {
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)
  }

  public func invalidateCachedContent(for tab: TabID) {
    cachedContentControllers[tab] = nil
    refreshPresentedContentIfNeeded(forExpandedTab: tab)
  }

  public func invalidateAllCachedContent() {
    cachedContentControllers.removeAll()
    if let expanded = expandedTabInternal {
      refreshPresentedContentIfNeeded(forExpandedTab: expanded)
    }
  }

  public func setAnchor(source: UIView, overlayHost: UIView? = nil) {
    if configuration.anchorPlacement == nil {
      var next = configuration
      next.anchorPlacement = FKTabBarFilterAnchorPlacement()
      configuration = next
    }
    configuration.anchorPlacement?.sourceView = source
    configuration.anchorPlacement?.overlayHostView = overlayHost
  }

  public func updateAnchorPlacement(
    attachmentEdge: FKAnchor.Edge? = nil,
    expansionDirection: FKAnchor.Direction? = nil,
    horizontalAlignment: FKAnchor.Alignment? = nil,
    widthPolicy: FKAnchor.WidthPolicy? = nil,
    attachmentOffset: CGFloat? = nil
  ) {
    guard let placement = configuration.anchorPlacement else { return }
    if let attachmentEdge { placement.attachmentEdge = attachmentEdge }
    if let expansionDirection { placement.expansionDirection = expansionDirection }
    if let horizontalAlignment { placement.horizontalAlignment = horizontalAlignment }
    if let widthPolicy { placement.widthPolicy = widthPolicy }
    if let attachmentOffset { placement.attachmentOffset = attachmentOffset }
  }

  public func resetAnchorToDefault() {
    guard configuration.anchorPlacement != nil else { return }
    clearsAnchorPlacementOnNextConfigurationChange = true
    var next = configuration
    next.anchorPlacement = nil
    configuration = next
  }

  /// Re-applies anchor layout when the panel is expanded and the strip hierarchy may have shifted
  /// (for example after a full-screen modal dismisses over the presenting view controller).
  public func relayoutExpandedPanelIfNeeded(animated: Bool = false) {
    guard isPanelExpanded else { return }
    guard fkSheetPresentationController?.isPresented == true else { return }

    view.layoutIfNeeded()
    tabBarHost.view.layoutIfNeeded()
    configuration.anchorPlacement?.overlayHostView?.layoutIfNeeded()
    fkSheetPresentationController?.updateLayout(animated: animated, duration: 0, options: .curveLinear)

    DispatchQueue.main.async { [weak self] in
      guard let self, self.isPanelExpanded else { return }
      guard self.fkSheetPresentationController?.isPresented == true else { return }
      self.view.layoutIfNeeded()
      self.tabBarHost.view.layoutIfNeeded()
      self.configuration.anchorPlacement?.overlayHostView?.layoutIfNeeded()
      self.fkSheetPresentationController?.updateLayout(animated: false, duration: 0, options: .curveLinear)
    }
  }

  public func embed(in parent: UIViewController, pinTo container: UIView? = nil) {
    guard let host = container ?? parent.view else {
      assertionFailure("embed(in:pinTo:) requires a loaded parent.view or an explicit container.")
      return
    }
    parent.addChild(self)
    view.translatesAutoresizingMaskIntoConstraints = false
    host.addSubview(view)
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: host.topAnchor),
      view.leadingAnchor.constraint(equalTo: host.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: host.trailingAnchor),
      view.bottomAnchor.constraint(equalTo: host.bottomAnchor),
    ])
    didMove(toParent: parent)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    installTabBarHost()
    applyConfiguration()
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal, animateChevronAccessories: false)
    wireTabBarEvents()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    syncChevronAccessoryAnimations(visualExpandedTabID: expandedTabInternal, animated: false)
    reconcileIfPossible()
    relayoutExpandedPanelIfNeeded(animated: false)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let size = tabBarHost.view.bounds.size
    guard size != lastTabBarHostLayoutSize else { return }
    lastTabBarHostLayoutSize = size
    tabBar.realignSelection(animated: false)
  }

  // MARK: - Internal (module)

  /// When `false`, the next ``configuration`` assignment may copy ``FKTabBarFilterConfiguration/anchorPlacement`` from the previous value (see ``resetAnchorToDefault()``).
  private var clearsAnchorPlacementOnNextConfigurationChange = false

  var filterTabs: [FKTabBarFilterTab<TabID>] = []
  let runtime = FKTabBarFilterRuntimeState<TabID>()
  var tabs: [FKTabBarFilterResolvedTab<TabID>] = []
  var selectedTabInternal: TabID?
  var expandedTabInternal: TabID? {
    didSet { configuration.events.onExpandedTabChange?(expandedTabInternal) }
  }

  var fkSheetPresentationController: FKSheetPresentationController?
  var presentedContentContainer: FKSheetPresentationAnchorContentHostViewController?
  var scheduledDismissReason: DismissReason?
  var lastCollapsingTabID: TabID?
  var pendingSwitchTargetTabID: TabID?
  var pendingSwitchAnimated: Bool = true

  struct DesiredExpandedRequest: Equatable {
    var tab: TabID?
    var animated: Bool
    var collapseReasonWhenDismissing: DismissReason
  }

  var desiredExpanded: DesiredExpandedRequest?
  var isReconciling = false
  var cachedContentControllers: [TabID: UIViewController] = [:]
  var lastTabBarHostLayoutSize: CGSize = .zero

  func refreshResolvedTabs() {
    updateResolvedTabs(
      FKTabBarFilterTabResolver.resolve(
        tabs: filterTabs,
        panelFactory: panelFactory,
        runtime: runtime,
        tabAppearance: configuration.tabAppearance
      )
    )
  }

  func updateResolvedTabs(_ tabs: [FKTabBarFilterResolvedTab<TabID>]) {
    self.tabs = tabs
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)

    if let expanded = expandedTabInternal, tabs.contains(where: { $0.id == expanded }) == false {
      collapsePanel(animated: true)
    }

    switch configuration.contentCachingPolicy {
    case .recreate:
      cachedContentControllers.removeAll()
    case .cachePerTab:
      let keep = Set(tabs.map(\.id))
      cachedContentControllers.keys
        .filter { !keep.contains($0) }
        .forEach { cachedContentControllers[$0] = nil }
    }
  }

  func applyConfiguration() {
    tabBar.configuration = configuration.tabBarConfiguration
    if let container = presentedContentContainer {
      wirePreferredContentSizeLayoutUpdates(to: container)
    }
  }

  func setState(_ newValue: State) {
    if state == newValue { return }
    state = newValue
    configuration.events.onStateChange?(newValue)
  }

  private func installTabBarHost() {
    let hostView = tabBarHost.view
    hostView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hostView)
    NSLayoutConstraint.activate([
      hostView.topAnchor.constraint(equalTo: view.topAnchor),
      hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}
