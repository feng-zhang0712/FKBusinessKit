import UIKit
import FKUIKit

@MainActor
enum FKTabBarFilterTabResolver {
  private static let missingPanelFactory = FKTabBarFilterPanelFactory(sourcesByPanelKind: [:])

  static func resolve<TabID: Hashable>(
    tabs: [FKTabBarFilterTab<TabID>],
    panelFactory: FKTabBarFilterPanelFactory?,
    runtime: FKTabBarFilterRuntimeState<TabID>,
    tabAppearance: FKTabBarFilterTabAppearance
  ) -> [FKTabBarFilterResolvedTab<TabID>] {
    #if DEBUG
    if panelFactory == nil, tabs.contains(where: { $0.panelKind != nil }) {
      assertionFailure(
        "FKTabBarFilterController requires a non-nil panelFactory when any tab uses panelKind / .panelContent(.panelKind)."
      )
    }
    #endif
    let factory = panelFactory ?? missingPanelFactory
    return tabs.map { tab in
      let tabID = tab.id
      let baseTitle = tab.title
      let appearance = tab.appearance ?? tabAppearance
      let titleForBar: () -> String = {
        runtime.displayTitle(for: tabID, fallback: baseTitle)
      }

      let resolvedPanel: FKTabBarFilterResolvedTab<TabID>.PanelContent
      switch tab.panelContent {
      case let .panelKind(kind):
        resolvedPanel = .viewController {
          factory.makePanel(
            for: kind,
            allowsMultipleSelection: tab.allowsMultipleSelection,
            onSelection: { selection in
              if selection.effectiveSelectionMode == .single {
                runtime.setTitleOverride(selection.item.title, for: tab.id)
                runtime.controller?.reloadTabBarItems()
              }
              let context = FKTabBarFilterSelectionContext(
                tabID: tab.id,
                panelKind: kind,
                selection: selection
              )
              runtime.onSelection?(context)
              runtime.dismissIfSingleSelect(mode: selection.effectiveSelectionMode)
            }
          ) ?? factory.makeFallbackPanel()
        }
      case let .viewController(make):
        resolvedPanel = .viewController(make)
      case let .view(make):
        resolvedPanel = .view(make)
      }

      return FKTabBarFilterResolvedTab.chevronTitle(
        id: tab.id,
        title: titleForBar,
        subtitle: tab.subtitle,
        normalTitleColor: appearance.normalTitleColor,
        expandedTitleColor: appearance.expandedTitleColor,
        normalChevronColor: appearance.normalChevronColor,
        expandedChevronColor: appearance.expandedChevronColor,
        titleFont: UIFont.preferredFont(forTextStyle: appearance.titleTextStyle),
        subtitleFont: UIFont.preferredFont(forTextStyle: appearance.subtitleTextStyle),
        chevronSize: appearance.chevronSize,
        chevronSpacing: appearance.chevronSpacing,
        titleSubtitleSpacing: appearance.titleSubtitleSpacing,
        content: resolvedPanel
      )
    }
  }
}
