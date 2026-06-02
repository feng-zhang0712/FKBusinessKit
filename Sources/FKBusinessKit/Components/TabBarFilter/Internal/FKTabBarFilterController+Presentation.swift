import UIKit
import FKUIKit

extension FKTabBarFilterController {
  func enqueueDesiredExpandedTab(_ tab: TabID?, animated: Bool, collapseReasonWhenDismissing: DismissReason) {
    desiredExpanded = DesiredExpandedRequest(
      tab: tab,
      animated: animated,
      collapseReasonWhenDismissing: collapseReasonWhenDismissing
    )
    reconcileIfPossible()
  }

  func reconcileIfPossible() {
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
  func transitionToExpand(tab id: TabID, animated: Bool) -> Bool {
    guard let tab = tabs.first(where: { $0.id == id }) else { return false }
    guard fkSheetPresentationController == nil else { return false }
    guard viewIfLoaded?.window != nil else { return false }

    configuration.events.onWillExpand?(id)
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

  func resolveContentController(for tab: FKTabBarFilterResolvedTab<TabID>) -> UIViewController {
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

  func makeContentController(for tab: FKTabBarFilterResolvedTab<TabID>) -> UIViewController {
    switch tab.content {
    case let .viewController(make):
      return make()
    case let .view(make):
      return FKTabBarFilterViewWrappingController(makeView: make)
    }
  }

  func refreshPresentedContentIfNeeded(forExpandedTab tab: TabID) {
    guard expandedTabInternal == tab,
          let tabModel = tabs.first(where: { $0.id == tab }) else { return }
    let next = resolveContentController(for: tabModel)
    if let controller = fkSheetPresentationController, controller.isPresented {
      controller.replaceAnchorContent(next, transition: .none, animateLayout: false, completion: nil)
    } else if let container = presentedContentContainer {
      container.setContent(next, transition: .none, completion: nil)
    }
  }

  func transitionToCollapse(reason: DismissReason, animated: Bool) {
    guard let controller = fkSheetPresentationController else { return }
    let closingTab = expandedTabInternal
    lastCollapsingTabID = closingTab
    scheduledDismissReason = reason
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal, forceCollapsedChrome: true)
    if let closingTab {
      configuration.events.onWillCollapse?(closingTab, reason)
      setState(.collapsing(tab: closingTab))
    } else {
      configuration.events.onWillCollapse?(nil, reason)
      setState(.collapsed)
    }
    controller.dismiss(animated: animated, completion: nil)
  }

  func transitionToSwitch(from: TabID, to: TabID, animated: Bool) {
    guard let controller = fkSheetPresentationController else {
      transitionToExpand(tab: to, animated: animated)
      return
    }
    configuration.events.onWillSwitchTab?(from, to)
    setState(.switching(from: from, to: to))

    let style = configuration.anchorReplacementPolicy
    switch style {
    case let .dismissThenPresent(dismissAnimated, presentAnimated):
      configuration.events.onWillCollapse?(from, .switchingTab)
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
          self.configuration.events.onDidSwitchTab?(from, to)
          self.setState(.expanded(tab: to))
        }
        self.reconcileIfPossible()
      }
    }
  }

  func wirePreferredContentSizeLayoutUpdates(to container: FKSheetPresentationAnchorContentHostViewController) {
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

  func reapplyAnchorShellPreferredContentSize(on container: FKSheetPresentationAnchorContentHostViewController) {
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

  func anchoredShellVerticalContentInset(for presentation: FKSheetPresentationConfiguration) -> CGFloat {
    CGFloat(presentation.contentInsets.top + presentation.contentInsets.bottom)
  }

  func makePresentationAnchorConfiguration() -> FKAnchorConfiguration {
    let placement = configuration.anchorPlacement
    let sourceView = placement?.sourceView ?? tabBarHost.tabBar
    let hostView = placement?.overlayHostView ?? tabBarHost.view
    let expansionDirection = placement?.expansionDirection ?? .down
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

  func resolvePendingSwitchAfterDismiss(previouslyExpanded: TabID?) -> (from: TabID, to: TabID, animated: Bool)? {
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

  func synchronizeDismissedPresentationIfNeeded() -> Bool {
    guard let controller = fkSheetPresentationController else { return false }
    guard controller.isTransitioning == false, controller.isPresented == false else { return false }
    presentationControllerDidDismiss(controller)
    return true
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
