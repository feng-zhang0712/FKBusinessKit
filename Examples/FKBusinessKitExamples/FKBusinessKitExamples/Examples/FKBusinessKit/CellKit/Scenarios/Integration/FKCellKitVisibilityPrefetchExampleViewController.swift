import FKBusinessKit
import FKUIKit
import UIKit

/// Logs visibility forwarding and image prefetch callbacks for ``FKUserListCell``.
final class FKCellKitVisibilityPrefetchExampleViewController: FKDiffableTableViewController, FKListDelegate {
  private var statusLabel: UILabel!

  init() {
    super.init(configuration: FKListDefaults.feedConfiguration)
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Visibility & Prefetch"
    FKCellKitListRegistration.registerUserListCell(on: self)
    let users = FKCellKitExampleSampleData.users
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKUserListCell.preferredRowHeight
    statusLabel = FKCellKitExampleStatusStrip.install(on: self, above: tableView)
    applySnapshot(
      FKCellKitExampleSampleData.makeUserListSnapshot(users),
      animatingDifferences: false
    )
  }

  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
    FKCellKitExampleStatusStrip.append("willDisplay \(item.rawValue)", to: statusLabel)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
    FKCellKitExampleStatusStrip.append("didEndDisplaying \(item.rawValue)", to: statusLabel)
  }

  func list(_ list: FKDiffableTableViewController, prefetchItems ids: [FKListItemID]) {
    FKListImagePrefetchHelper.prefetchImages(
      for: ids,
      in: currentSnapshot,
      payloadProvider: { [weak self] id in self?.payload(for: id) }
    )
    FKCellKitExampleStatusStrip.append("prefetch \(ids.count) avatar(s)", to: statusLabel)
  }

  func list(_ list: FKDiffableTableViewController, cancelPrefetching ids: [FKListItemID]) {
    FKListImagePrefetchHelper.cancelPrefetchImages(
      for: ids,
      in: currentSnapshot,
      payloadProvider: { [weak self] id in self?.payload(for: id) }
    )
    FKCellKitExampleStatusStrip.append("cancel prefetch \(ids.count)", to: statusLabel)
  }
}
