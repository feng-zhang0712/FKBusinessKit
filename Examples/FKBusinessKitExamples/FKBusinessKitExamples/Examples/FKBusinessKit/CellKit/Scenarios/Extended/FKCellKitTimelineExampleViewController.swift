import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKTimelineEventCell`` logistics-style connector rows.
final class FKCellKitTimelineExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Timeline Events"
    FKCellKitListRegistration.registerTimelineEventCell(on: self)
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = FKTimelineEventCell.preferredRowHeight

    let events = FKCellKitExampleSampleData.timelineEvents
    FKCellKitListItemFactory.storeTimelineEventPayloads(events, on: self)
    applySnapshot(FKListSnapshot(items: events.map(FKCellKitListItemFactory.timelineEvent)), animatingDifferences: false)
  }
}
