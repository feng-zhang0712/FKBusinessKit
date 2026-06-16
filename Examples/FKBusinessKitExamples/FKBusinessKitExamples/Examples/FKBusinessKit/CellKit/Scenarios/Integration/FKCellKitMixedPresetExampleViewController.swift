import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates a single ListKit snapshot mixing preset settings rows and ``FKUserListCell`` custom rows.
final class FKCellKitMixedPresetExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration, style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Mixed Preset + Custom"
    FKCellKitListRegistration.registerUserListCell(on: self)

    let users = Array(FKCellKitExampleSampleData.users.prefix(2))
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)

    let snapshot = FKListSnapshot(sections: [
      FKListSection(
        id: "settings",
        items: [
          FKListItem(id: "account", kind: .preset(.disclosure(FKListDisclosureRow(
            title: "Account",
            subtitle: "Security, password, devices",
            accessory: .disclosureIndicator
          )))),
          FKListItem(id: "notifications", kind: .preset(.switch(FKListSwitchRow(
            title: "Push notifications",
            isOn: true,
            handlerID: "cellkit.notifications"
          )))),
        ]
      ),
      FKListSection(
        id: "contacts",
        items: users.map(FKCellKitListItemFactory.userList),
        header: .title("Suggested contacts")
      ),
    ])

    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = FKUserListCell.preferredRowHeight
    applySnapshot(snapshot, animatingDifferences: false)
  }
}
