import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKAddressListCell`` default tag and selection checkmark.
final class FKCellKitAddressListExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Address List"
    FKCellKitListRegistration.registerAddressListCell(on: self)
    let items = FKCellKitExampleSampleData.addresses
    FKCellKitListItemFactory.storeAddressListPayloads(items, on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKAddressListCell.preferredRowHeight
    applySnapshot(
      FKListSnapshot(items: items.map(FKCellKitListItemFactory.addressList)),
      animatingDifferences: false
    )
  }
}
