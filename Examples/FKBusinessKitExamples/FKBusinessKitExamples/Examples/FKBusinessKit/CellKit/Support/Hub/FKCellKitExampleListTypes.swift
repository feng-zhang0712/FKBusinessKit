import UIKit

/// One navigable row in a CellKit example hub.
struct FKCellKitExampleListRow {
  let title: String
  let subtitle: String
  let makeViewController: () -> UIViewController
}

/// Grouped rows in a CellKit example hub.
struct FKCellKitExampleListSection {
  let title: String
  let rows: [FKCellKitExampleListRow]
}
