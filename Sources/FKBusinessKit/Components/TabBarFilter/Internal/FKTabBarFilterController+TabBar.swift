import UIKit
import FKUIKit

extension FKTabBarFilterController {
  func wireTabBarEvents() {
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

  func handleUserTap(tab id: TabID) {
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

  func rebuildTabBarItems(
    keepSelectedTab: TabID?,
    forceCollapsedChrome: Bool = false,
    animateChevronAccessories: Bool = true
  ) {
    let snapshot = FKTabBarFilterResolvedTab<TabID>.StateSnapshot(
      expandedTab: forceCollapsedChrome ? nil : expandedTabInternal
    )
    let items = tabs.map { $0.makeTabBarItem(snapshot) }
    tabBar.reload(items: items, updatePolicy: .preserveSelection)
    if let keepSelectedTab, let idx = tabs.firstIndex(where: { $0.id == keepSelectedTab }) {
      tabBar.setSelectedIndex(idx, animated: true, notify: false, reason: .programmatic)
    }
    tabBar.reapplyVisibleItemConfigurations()
    syncChevronAccessoryAnimations(
      visualExpandedTabID: forceCollapsedChrome ? nil : expandedTabInternal,
      animated: animateChevronAccessories
    )
  }

  func syncChevronAccessoryAnimations(visualExpandedTabID: TabID?, animated: Bool) {
    for index in tabs.indices {
      guard tabBar.visibleItems.indices.contains(index) else { continue }
      guard tabBar.visibleItems[index].accessoryIcon != nil else { continue }
      let expanded = visualExpandedTabID == tabs[index].id
      applyChevronAccessoryRotation(at: index, expanded: expanded, animated: animated)
    }
  }

  private func applyChevronAccessoryRotation(at index: Int, expanded: Bool, animated: Bool) {
    guard let iconView = tabBar.visibleItemAccessoryView(at: index) else { return }
    let targetTransform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
    guard animated else {
      iconView.layer.removeAllAnimations()
      iconView.transform = targetTransform
      return
    }
    UIView.animate(
      withDuration: 0.28,
      delay: 0,
      options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
    ) {
      iconView.transform = targetTransform
    }
  }
}
