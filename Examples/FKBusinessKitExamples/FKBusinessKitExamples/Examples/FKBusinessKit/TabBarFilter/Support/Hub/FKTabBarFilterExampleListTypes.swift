import UIKit

/// One navigable row in a TabBarFilter example hub.
struct FKTabBarFilterExampleListRow {
  let title: String
  let subtitle: String
  let makeViewController: () -> UIViewController
}

/// Grouped rows in a TabBarFilter example hub.
struct FKTabBarFilterExampleListSection {
  let title: String
  let rows: [FKTabBarFilterExampleListRow]
}
