import UIKit
import FKUIKit
import FKBusinessKit

/// Builds the sample ``FKTabBarFilterDropdownController`` and wires ``FKTabBarFilterDropdownConfiguration/Events`` to the demo log.
enum FKTabBarFilterDropdownExampleFactory {
  static func makeController(
    tabBarHost: FKTabBarFilterTabBarHost,
    onLog: @escaping (String) -> Void
  ) -> FKTabBarFilterDropdownController<FKTabBarFilterExampleTabID> {
    let tabs: [FKTabBarFilterDropdownTab<FKTabBarFilterExampleTabID>] = [
      .chevronTitle(
        id: .sort,
        itemID: "sort",
        title: { "Sort" },
        content: .viewController { FKTabBarFilterSortPanelExampleViewController() }
      ),
      .chevronTitle(
        id: .filters,
        itemID: "filters",
        title: { "Filters" },
        subtitle: { "3 selected" },
        content: .viewController { FKTabBarFilterFiltersPanelExampleViewController() }
      ),
      .chevronTitle(
        id: .search,
        itemID: "search",
        title: { "Search" },
        content: .viewController { FKTabBarFilterSearchPanelExampleViewController() }
      ),
    ]

    var config = FKTabBarFilterDropdownConfiguration.default
    config.applyTintOnlyChevronTabTypography()

    config.presentationConfiguration.contentInsets = .init(top: 8, leading: 12, bottom: 12, trailing: 12)
    config.presentationConfiguration.cornerRadius = 12

    let events = FKTabBarFilterDropdownConfiguration.Events<FKTabBarFilterExampleTabID>(
      onStateChange: { state in onLog("state: \(state)") },
      onExpandedTabChange: { expanded in onLog("expandedTab: \(expanded?.rawValue ?? "nil")") },
      onWillExpand: { tab in onLog("onWillExpand: \(tab.rawValue)") },
      onDidExpand: { tab in onLog("onDidExpand: \(tab.rawValue)") },
      onWillCollapse: { tab, reason in onLog("onWillCollapse: \(tab?.rawValue ?? "nil") reason=\(reason)") },
      onDidCollapse: { tab, reason in onLog("onDidCollapse: \(tab?.rawValue ?? "nil") reason=\(reason)") },
      onWillSwitchTab: { from, to in onLog("onWillSwitchTab: \(from.rawValue) → \(to.rawValue)") },
      onDidSwitchTab: { from, to in onLog("onDidSwitchTab: \(from.rawValue) → \(to.rawValue)") }
    )

    let vc = FKTabBarFilterDropdownController<FKTabBarFilterExampleTabID>(
      tabs: tabs,
      tabBarHost: tabBarHost,
      configuration: config,
      events: events
    )

    vc.selectTab(.filters, animated: false)
    return vc
  }
}
