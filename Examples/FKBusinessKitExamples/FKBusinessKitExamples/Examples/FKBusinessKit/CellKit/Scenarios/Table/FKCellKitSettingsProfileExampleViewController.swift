import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKSettingsProfileCell`` account header row.
final class FKCellKitSettingsProfileExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Settings Profile"
    FKCellKitListRegistration.registerSettingsProfileCell(on: self)
    let items = FKCellKitExampleSampleData.settingsProfiles
    FKCellKitListItemFactory.storeSettingsProfilePayloads(items, on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKSettingsProfileCell.preferredRowHeight
    applySnapshot(
      FKListSnapshot(items: items.map(FKCellKitListItemFactory.settingsProfile)),
      animatingDifferences: false
    )
  }
}
