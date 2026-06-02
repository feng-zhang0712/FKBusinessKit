import UIKit
import FKUIKit

extension FKTabBarFilterController: FKSheetPresentationControllerDelegate {
  public func presentationControllerDidPresent(_ controller: FKSheetPresentationController) {
    guard let expanded = expandedTabInternal else { return }
    configuration.events.onDidExpand?(expanded)
    setState(.expanded(tab: expanded))
    reconcileIfPossible()
  }

  public func presentationControllerWillDismiss(_ controller: FKSheetPresentationController) {
    if scheduledDismissReason == nil {
      scheduledDismissReason = .backdropOrSwipe
      lastCollapsingTabID = expandedTabInternal
      rebuildTabBarItems(keepSelectedTab: selectedTabInternal, forceCollapsedChrome: true)
      configuration.events.onWillCollapse?(expandedTabInternal, .backdropOrSwipe)
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

    configuration.events.onDidCollapse?(collapsingTab, reason)
    setState(.collapsed)
    rebuildTabBarItems(keepSelectedTab: selectedTabInternal)

    if let fromTo = resolvePendingSwitchAfterDismiss(previouslyExpanded: collapsingTab) {
      configuration.events.onDidSwitchTab?(fromTo.from, fromTo.to)
      transitionToExpand(tab: fromTo.to, animated: fromTo.animated)
      return
    }

    reconcileIfPossible()
  }
}
