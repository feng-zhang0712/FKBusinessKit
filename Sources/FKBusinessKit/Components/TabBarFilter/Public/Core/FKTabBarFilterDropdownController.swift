import UIKit
import FKUIKit

/// Hosts an ``FKTabBar`` and presents an anchor-attached panel per tab via ``FKSheetPresentationController``.
///
/// Typical interaction: tap a tab to expand its panel below the bar (or a custom anchor), tap again to collapse,
/// switch tabs while expanded, or dismiss via backdrop / swipe when enabled in ``FKTabBarFilterDropdownConfiguration/presentationConfiguration``.
@MainActor
public final class FKTabBarFilterDropdownController<TabID: Hashable>: UIViewController {
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

  /// Tab index last selected on the strip (may differ from ``expandedTabID`` when collapsed).
  public var selectedTabID: TabID? { selectedTabInternal }

  /// Tab whose panel is currently presented, if any.
  public var expandedTabID: TabID? { expandedTabInternal }

  /// `true` while a tab’s panel is presented (from first expand through until fully dismissed).
  public var isPanelExpanded: Bool { expandedTabInternal != nil }

  public let tabBarHost: any FKTabBarFilterTabBarHost

  public var tabBar: FKTabBar { tabBarHost.tabBar }

  public var configuration: FKTabBarFilterDropdownConfiguration {
    didSet {
      applyConfiguration()
      rebuildTabBarItems(keepSelectedTab: selectedTabInternal)
    }
  }

  public var events: FKTabBarFilterDropdownConfiguration.Events<TabID>

  public init(
    tabs: [FKTabBarFilterDropdownTab<TabID>],
    tabBarHost: (any FKTabBarFilterTabBarHost)? = nil,
    configuration: FKTabBarFilterDropdownConfiguration = .default,
    events: FKTabBarFilterDropdownConfiguration.Events<TabID> = .init()
  ) {
    self.tabs = tabs
    self.tabBarHost = tabBarHost ?? FKTabBarFilterDefaultTabBarHost()
    self.configuration = configuration
    self.events = events
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func updateTabs(_ tabs: [FKTabBarFilterDropdownTab<TabID>]) {
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

  /// Updates strip selection without expanding a panel.
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

  // MARK: - Anchor & embedding

  /// Pins the panel to `source` and optionally uses a larger `overlayHost` for mask/layout bounds.
  public func setAnchor(source: UIView, overlayHost: UIView? = nil) {
    if configuration.anchorPlacement == nil {
      var next = configuration
      next.anchorPlacement = FKTabBarFilterAnchorPlacement()
      configuration = next
    }
    configuration.anchorPlacement?.sourceView = source
    configuration.anchorPlacement?.overlayHostView = overlayHost
  }

  /// Updates anchor geometry on the existing ``FKTabBarFilterAnchorPlacement`` instance.
  ///
  /// No-op until ``setAnchor(source:overlayHost:)`` or ``FKTabBarFilterDropdownConfiguration/anchorPlacement`` is set.
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
    var next = configuration
    next.anchorPlacement = nil
    configuration = next
  }

  /// Adds this controller as a child of `parent` and pins ``view`` to `container` (default: `parent.view`).
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

  // MARK: - UIViewController

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    installTabBarHost()
    applyConfiguration()
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)
    wireTabBarEvents()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reconcileIfPossible()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Avoid calling `realignSelection` on every layout pass: it scrolls with `animated: false` and
    // cancels an in-flight selection scroll animation after a user tap (see `reload` → layout invalidation).
    let size = tabBarHost.view.bounds.size
    guard size != lastTabBarHostLayoutSize else { return }
    lastTabBarHostLayoutSize = size
    tabBar.realignSelection(animated: false)
  }

  // MARK: - Private

  private var tabs: [FKTabBarFilterDropdownTab<TabID>] = []
  private var selectedTabInternal: TabID?
  private var expandedTabInternal: TabID? {
    didSet { events.onExpandedTabChange?(expandedTabInternal) }
  }

  private var fkSheetPresentationController: FKSheetPresentationController?
  private var presentedContentContainer: FKSheetPresentationAnchorContentHostViewController?
  private var scheduledDismissReason: DismissReason?
  private var lastCollapsingTabID: TabID?
  private var pendingSwitchTargetTabID: TabID?
  private var pendingSwitchAnimated: Bool = true

  private struct DesiredExpandedRequest: Equatable {
    var tab: TabID?
    var animated: Bool
    var collapseReasonWhenDismissing: DismissReason
  }

  /// Latest expand/collapse intent; cleared when a reconciliation pass consumes it or starts an async transition.
  private var desiredExpanded: DesiredExpandedRequest?
  /// Prevents nested ``reconcileIfPossible`` while mutating presentation state.
  private var isReconciling = false
  private var cachedContentControllers: [TabID: UIViewController] = [:]
  private var lastTabBarHostLayoutSize: CGSize = .zero

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

  private func wireTabBarEvents() {
    tabBar.tapEventTriggerBehavior = .onceAfterSelection
    tabBar.onSelectionChanged = { [weak self] _, index, reason in
      guard let self else { return }
      guard reason == .userTap else { return }
      guard self.tabs.indices.contains(index) else { return }
      let tab = self.tabs[index]
      self.selectedTabInternal = tab.id
      self.handleUserTap(tab: tab.id)
    }
    tabBar.onReselect = { [weak self] _, index in
      guard let self else { return }
      guard self.tabs.indices.contains(index) else { return }
      let tab = self.tabs[index]
      self.selectedTabInternal = tab.id
      self.handleUserTap(tab: tab.id)
    }
  }

  private func handleUserTap(tab id: TabID) {
    if let expanded = expandedTabInternal {
      if expanded == id {
        enqueueDesiredExpandedTab(nil, animated: true, collapseReasonWhenDismissing: .userToggledSameTab)
      } else {
        enqueueDesiredExpandedTab(id, animated: true, collapseReasonWhenDismissing: .switchingTab)
      }
      return
    }
    enqueueDesiredExpandedTab(id, animated: true, collapseReasonWhenDismissing: .programmatic)
  }

  private func applyConfiguration() {
    tabBar.configuration = configuration.tabBarConfiguration
    if let container = presentedContentContainer {
      wirePreferredContentSizeLayoutUpdates(to: container)
    }
  }

  private func rebuildTabBarItems(keepSelectedTab: TabID?, forceCollapsedChrome: Bool = false) {
    let snapshot = FKTabBarFilterDropdownTab<TabID>.StateSnapshot(
      expandedTab: forceCollapsedChrome ? nil : expandedTabInternal
    )
    let items = tabs.map { $0.makeTabBarItem(snapshot) }
    tabBar.reload(items: items, updatePolicy: .preserveSelection)
    if let keepSelectedTab, let idx = tabs.firstIndex(where: { $0.id == keepSelectedTab }) {
      tabBar.setSelectedIndex(idx, animated: true, notify: false, reason: .programmatic)
    }
    tabBar.reapplyVisibleItemConfigurations()
  }

  private func enqueueDesiredExpandedTab(_ tab: TabID?, animated: Bool, collapseReasonWhenDismissing: DismissReason) {
    desiredExpanded = DesiredExpandedRequest(tab: tab, animated: animated, collapseReasonWhenDismissing: collapseReasonWhenDismissing)
    reconcileIfPossible()
  }

  private func reconcileIfPossible() {
    guard isReconciling == false else { return }
    guard let desiredExpanded else { return }
    if presentedContentContainer?.isTransitioningContent == true { return }
    if synchronizeDismissedPresentationIfNeeded() { return }
    guard let presented = fkSheetPresentationController else {
      if let target = desiredExpanded.tab {
        let started = transitionToExpand(tab: target, animated: desiredExpanded.animated)
        if started {
          self.desiredExpanded = nil
        }
        return
      }
      self.desiredExpanded = nil
      return
    }
    guard presented.isTransitioning == false else { return }

    isReconciling = true
    defer { isReconciling = false }

    let currentExpanded = expandedTabInternal
    let target = desiredExpanded.tab
    let animated = desiredExpanded.animated
    let collapseReasonWhenDismissing = desiredExpanded.collapseReasonWhenDismissing
    self.desiredExpanded = nil

    switch (currentExpanded, target) {
    case (nil, nil):
      return
    case (nil, .some(let to)):
      transitionToExpand(tab: to, animated: animated)
    case (.some, nil):
      transitionToCollapse(reason: collapseReasonWhenDismissing, animated: animated)
    case (.some(let from), .some(let to)):
      if from == to { return }
      transitionToSwitch(from: from, to: to, animated: animated)
    }
  }

  @discardableResult
  private func transitionToExpand(tab id: TabID, animated: Bool) -> Bool {
    guard let tab = tabs.first(where: { $0.id == id }) else { return false }
    guard fkSheetPresentationController == nil else { return false }
    guard viewIfLoaded?.window != nil else { return false }

    events.onWillExpand?(id)
    setState(.expanding(tab: id))
    expandedTabInternal = id
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal ?? id)

    let container = FKSheetPresentationAnchorContentHostViewController()
    wirePreferredContentSizeLayoutUpdates(to: container)

    var cfg = configuration.presentationConfiguration
    cfg.layout = .anchor(makePresentationAnchorConfiguration())

    let contentVC = resolveContentController(for: tab)
    container.setContent(contentVC, transition: .none, completion: nil)
    reapplyAnchorShellPreferredContentSize(on: container)
    presentedContentContainer = container

    let controller = FKSheetPresentationController(
      contentController: container,
      configuration: cfg,
      delegate: self,
      callbackDelivery: .delegateOnly
    )
    fkSheetPresentationController = controller
    controller.present(from: self, animated: animated, completion: nil)
    return true
  }

  private func resolveContentController(for tab: FKTabBarFilterDropdownTab<TabID>) -> UIViewController {
    switch configuration.contentCachingPolicy {
    case .recreate:
      return makeContentController(for: tab)
    case .cachePerTab:
      if let cached = cachedContentControllers[tab.id] {
        return cached
      }
      let created = makeContentController(for: tab)
      cachedContentControllers[tab.id] = created
      return created
    }
  }

  private func makeContentController(for tab: FKTabBarFilterDropdownTab<TabID>) -> UIViewController {
    switch tab.content {
    case let .viewController(make):
      return make()
    case let .view(make):
      return FKTabBarFilterViewWrappingController(makeView: make)
    }
  }

  private func refreshPresentedContentIfNeeded(forExpandedTab tab: TabID) {
    guard expandedTabInternal == tab,
          let tabModel = tabs.first(where: { $0.id == tab }) else { return }
    let next = resolveContentController(for: tabModel)
    if let controller = fkSheetPresentationController, controller.isPresented {
      controller.replaceAnchorContent(next, transition: .none, animateLayout: false, completion: nil)
    } else if let container = presentedContentContainer {
      container.setContent(next, transition: .none, completion: nil)
    }
  }

  private func transitionToCollapse(reason: DismissReason, animated: Bool) {
    guard let controller = fkSheetPresentationController else { return }
    let closingTab = expandedTabInternal
    lastCollapsingTabID = closingTab
    scheduledDismissReason = reason
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal, forceCollapsedChrome: true)
    if let closingTab {
      events.onWillCollapse?(closingTab, reason)
      setState(.collapsing(tab: closingTab))
    } else {
      events.onWillCollapse?(nil, reason)
      setState(.collapsed)
    }
    controller.dismiss(animated: animated, completion: nil)
  }

  private func transitionToSwitch(from: TabID, to: TabID, animated: Bool) {
    guard let controller = fkSheetPresentationController else {
      transitionToExpand(tab: to, animated: animated)
      return
    }
    events.onWillSwitchTab?(from, to)
    setState(.switching(from: from, to: to))

    let style = configuration.anchorReplacementPolicy
    switch style {
    case let .dismissThenPresent(dismissAnimated, presentAnimated):
      events.onWillCollapse?(from, .switchingTab)
      lastCollapsingTabID = from
      scheduledDismissReason = .switchingTab
      pendingSwitchTargetTabID = to
      pendingSwitchAnimated = presentAnimated
      controller.dismiss(animated: dismissAnimated, completion: nil)

    case let .replaceInPlace(contentTransition, animateLayout, layoutDuration):
      guard let tab = tabs.first(where: { $0.id == to }) else { return }
      let nextContent = resolveContentController(for: tab)

      expandedTabInternal = to
      rebuildTabBarItems(keepSelectedTab: selectedTabInternal ?? to)

      controller.replaceAnchorContent(
        nextContent,
        transition: contentTransition,
        animateLayout: animateLayout,
        layoutAnimationDuration: layoutDuration
      ) { [weak self] in
        guard let self else { return }
        if self.expandedTabInternal == to {
          self.events.onDidSwitchTab?(from, to)
          self.setState(.expanded(tab: to))
        }
        self.reconcileIfPossible()
      }
    }
  }

  private func wirePreferredContentSizeLayoutUpdates(to container: FKSheetPresentationAnchorContentHostViewController) {
    let layoutUpdate = configuration.anchorReplacementPolicy.preferredContentSizeLayoutUpdate
    container.onPreferredContentSizeDidChange = { [weak self] in
      guard let self else { return }
      self.reapplyAnchorShellPreferredContentSize(on: container)
      self.fkSheetPresentationController?.updateLayout(
        animated: layoutUpdate.animated,
        duration: layoutUpdate.animated ? layoutUpdate.duration : 0,
        options: .curveEaseInOut
      )
    }
  }

  /// ``FKAnchorHostViewController`` subtracts ``FKSheetPresentationConfiguration/contentInsets`` from the content
  /// container without growing the shell; inflate the reported height so panel content is not clipped.
  private func reapplyAnchorShellPreferredContentSize(on container: FKSheetPresentationAnchorContentHostViewController) {
    let inset = anchoredShellVerticalContentInset(for: configuration.presentationConfiguration)
    guard inset > 0, let expanded = expandedTabInternal,
          let tab = tabs.first(where: { $0.id == expanded }) else { return }
    let contentVC = resolveContentController(for: tab)
    let childSize = contentVC.preferredContentSize
    guard childSize.height > 0 else { return }
    let target = CGSize(width: childSize.width, height: childSize.height + inset)
    if container.preferredContentSize != target {
      container.preferredContentSize = target
    }
  }

  private func anchoredShellVerticalContentInset(
    for presentation: FKSheetPresentationConfiguration
  ) -> CGFloat {
    CGFloat(presentation.contentInsets.top + presentation.contentInsets.bottom)
  }

  private func makePresentationAnchorConfiguration() -> FKAnchorConfiguration {
    let placement = configuration.anchorPlacement
    let sourceView = placement?.sourceView ?? tabBarHost.tabBar
    let hostView = placement?.overlayHostView ?? tabBarHost.view
    let expansionDirection = placement?.expansionDirection ?? .down
    // Upward panels attach near the bottom edge; `.belowAnchorOnly` leaves no tappable mask above the anchor.
    let maskCoveragePolicy: FKAnchorConfiguration.MaskCoveragePolicy =
      expansionDirection == .up ? .fullScreen : .belowAnchorOnly
    let resolvedHostStrategy = placement?.hostStrategy
      ?? .inProvidedContainer(FKWeakReference(hostView))

    return FKAnchorConfiguration(
      anchor: FKAnchor(
        sourceView: sourceView,
        edge: placement?.attachmentEdge ?? .bottom,
        direction: expansionDirection,
        alignment: placement?.horizontalAlignment ?? .fill,
        widthPolicy: placement?.widthPolicy ?? .matchContainer,
        offset: placement?.attachmentOffset ?? 0
      ),
      hostStrategy: resolvedHostStrategy,
      zOrderPolicy: .keepAnchorAbovePresentation,
      maskCoveragePolicy: maskCoveragePolicy
    )
  }

  private func setState(_ newValue: State) {
    if state == newValue { return }
    state = newValue
    events.onStateChange?(newValue)
  }

  private func resolvePendingSwitchAfterDismiss(previouslyExpanded: TabID?) -> (from: TabID, to: TabID, animated: Bool)? {
    guard let from = previouslyExpanded else {
      pendingSwitchTargetTabID = nil
      return nil
    }
    guard let to = pendingSwitchTargetTabID else { return nil }
    let animated = pendingSwitchAnimated
    pendingSwitchTargetTabID = nil
    pendingSwitchAnimated = true
    return (from: from, to: to, animated: animated)
  }

  /// Heals stale bookkeeping when the sheet host is gone but dismiss cleanup did not run.
  private func synchronizeDismissedPresentationIfNeeded() -> Bool {
    guard let controller = fkSheetPresentationController else { return false }
    guard controller.isTransitioning == false, controller.isPresented == false else { return false }
    presentationControllerDidDismiss(controller)
    return true
  }

}

// MARK: - FKSheetPresentationControllerDelegate

extension FKTabBarFilterDropdownController: FKSheetPresentationControllerDelegate {
  public func presentationControllerDidPresent(_ controller: FKSheetPresentationController) {
    guard let expanded = expandedTabInternal else { return }
    events.onDidExpand?(expanded)
    setState(.expanded(tab: expanded))
    reconcileIfPossible()
  }

  public func presentationControllerWillDismiss(_ controller: FKSheetPresentationController) {
    if scheduledDismissReason == nil {
      scheduledDismissReason = .backdropOrSwipe
      lastCollapsingTabID = expandedTabInternal
      rebuildTabBarItems(keepSelectedTab: selectedTabInternal, forceCollapsedChrome: true)
      events.onWillCollapse?(expandedTabInternal, .backdropOrSwipe)
      if let expanded = expandedTabInternal {
        setState(.collapsing(tab: expanded))
      }
    }
  }

  public func presentationControllerDidDismiss(_ controller: FKSheetPresentationController) {
    let reason = scheduledDismissReason ?? .backdropOrSwipe
    let collapsingTab = lastCollapsingTabID ?? expandedTabInternal

    fkSheetPresentationController = nil
    presentedContentContainer = nil
    expandedTabInternal = nil
    scheduledDismissReason = nil
    lastCollapsingTabID = nil

    events.onDidCollapse?(collapsingTab, reason)
    setState(.collapsed)
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)

    if let fromTo = resolvePendingSwitchAfterDismiss(previouslyExpanded: collapsingTab) {
      events.onDidSwitchTab?(fromTo.from, fromTo.to)
      transitionToExpand(tab: fromTo.to, animated: fromTo.animated)
      return
    }

    reconcileIfPossible()
  }
}

private extension FKSheetPresentationAnchorReplacementPolicy {
  var preferredContentSizeLayoutUpdate: (animated: Bool, duration: TimeInterval) {
    switch self {
    case .dismissThenPresent:
      return (false, 0)
    case let .replaceInPlace(_, animateLayout, layoutDuration):
      return (animateLayout, layoutDuration)
    }
  }
}
