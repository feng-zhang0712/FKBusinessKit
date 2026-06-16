import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKOrderListCell`` with copy chip, status pill, and ``reconfigureItems`` updates.
final class FKCellKitOrderListExampleViewController: FKDiffableTableViewController {
  private var orders = FKCellKitExampleSampleData.orders
  private let statusKeys = ["processing", "shipped", "delivered", "cancelled"]

  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Order List"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Advance",
      style: .plain,
      target: self,
      action: #selector(advanceFirstOrderStatus)
    )
    FKCellKitListRegistration.registerOrderListCell(on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKOrderListCell.preferredRowHeight
    applyOrders(animated: false)
  }

  @objc private func advanceFirstOrderStatus() {
    guard !orders.isEmpty else { return }
    let currentKey = orders[0].statusPill.title.lowercased().replacingOccurrences(of: " ", with: "_")
    let nextIndex = (statusKeys.firstIndex(of: currentKey) ?? -1) + 1
    let nextKey = statusKeys[nextIndex % statusKeys.count]
    orders[0].statusPill = FKOrderStatusMapper.displayModel(for: nextKey)
    setPayload(FKListItemPayload(orders[0]), for: .init(orders[0].id))
    applyMutation(.reconfigureItems([.init(orders[0].id)]), animatingDifferences: false)
  }

  private func applyOrders(animated: Bool) {
    FKCellKitListItemFactory.storeOrderListPayloads(orders, on: self)
    applySnapshot(
      FKListSnapshot(items: orders.map(FKCellKitListItemFactory.orderList)),
      animatingDifferences: animated
    )
  }
}
