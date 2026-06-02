import UIKit
import FKUIKit
import FKBusinessKit

/// Builds a sample ``FKTabBarFilterController`` with three custom panels and wires ``FKTabBarFilterConfiguration/Events`` to the demo log.
enum FKTabBarFilterDropdownExampleFactory {
  static func makeController(
    tabBarHost: FKTabBarFilterTabBarHost,
    onLog: @escaping (String) -> Void
  ) -> FKTabBarFilterController<FKTabBarFilterExampleTabID> {
    let tabs: [FKTabBarFilterTab<FKTabBarFilterExampleTabID>] = [
      FKTabBarFilterTab(
        id: .sort,
        title: { "Sort" },
        panelContent: .viewController { FKTabBarFilterSortPanelExampleViewController() }
      ),
      FKTabBarFilterTab(
        id: .filters,
        title: { "Filters" },
        subtitle: { "3 selected" },
        panelContent: .viewController { FKTabBarFilterFiltersPanelExampleViewController() }
      ),
      FKTabBarFilterTab(
        id: .search,
        title: { "Search" },
        panelContent: .viewController { FKTabBarFilterSearchPanelExampleViewController() }
      ),
    ]

    var configuration = FKTabBarFilterConfiguration<FKTabBarFilterExampleTabID>()
    configuration.applyTintOnlyChevronTabTypography()
    configuration.presentationConfiguration.contentInsets = .init(top: 8, leading: 12, bottom: 12, trailing: 12)
    configuration.presentationConfiguration.cornerRadius = 12
    configuration.events = FKTabBarFilterConfiguration.Events(
      onStateChange: { state in onLog("state: \(state)") },
      onExpandedTabChange: { expanded in onLog("expandedTab: \(expanded?.rawValue ?? "nil")") },
      onWillExpand: { tab in onLog("onWillExpand: \(tab.rawValue)") },
      onDidExpand: { tab in onLog("onDidExpand: \(tab.rawValue)") },
      onWillCollapse: { tab, reason in onLog("onWillCollapse: \(tab?.rawValue ?? "nil") reason=\(reason)") },
      onDidCollapse: { tab, reason in onLog("onDidCollapse: \(tab?.rawValue ?? "nil") reason=\(reason)") },
      onWillSwitchTab: { from, to in onLog("onWillSwitchTab: \(from.rawValue) → \(to.rawValue)") },
      onDidSwitchTab: { from, to in onLog("onDidSwitchTab: \(from.rawValue) → \(to.rawValue)") }
    )

    let factory = FKTabBarFilterPanelFactory(sourcesByPanelKind: [:], loadingTitle: FKTabBarFilterExampleAppearance.panelLoadingTitle)
    let controller = FKTabBarFilterController(
      tabs: tabs,
      panelFactory: factory,
      configuration: configuration,
      tabBarHost: tabBarHost
    )
    controller.selectTab(.filters, animated: false)
    return controller
  }
}
