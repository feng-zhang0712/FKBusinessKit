import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKNotificationListCell`` read/unread and summary truncation states.
final class FKCellKitNotificationListExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Notifications"
    FKCellKitListRegistration.registerNotificationListCell(on: self)
    let items = FKCellKitExampleSampleData.notifications
    FKCellKitListItemFactory.storeNotificationListPayloads(items, on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKNotificationListCell.preferredRowHeight
    applySnapshot(
      FKListSnapshot(items: items.map(FKCellKitListItemFactory.notificationList)),
      animatingDifferences: false
    )
  }
}
