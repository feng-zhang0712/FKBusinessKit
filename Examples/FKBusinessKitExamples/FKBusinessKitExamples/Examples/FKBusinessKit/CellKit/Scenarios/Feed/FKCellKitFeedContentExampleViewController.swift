import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKFeedContentCell`` with dynamic heights via ``FKFeedContentCellHeightEstimator``.
final class FKCellKitFeedContentExampleViewController: FKDiffableTableViewController {
  private let heightCache = FKListHeightCache()
  private var lastMeasuredTableWidth: CGFloat = 0

  init() {
    super.init(configuration: FKListDefaults.feedConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Feed Content"
    FKCellKitListRegistration.registerFeedContentCell(on: self)
    rowHeightProvider = { [weak self] item in
      guard let self else { return FKFeedContentCell.preferredRowHeight }
      guard let post = self.payload(for: item.id)?.unwrap(FKFeedContentItem.self) else {
        return FKFeedContentCell.preferredRowHeight
      }
      let width = self.tableView.bounds.width > 0 ? self.tableView.bounds.width : UIScreen.main.bounds.width
      return FKFeedContentCellHeightEstimator.estimatedRowHeight(for: post, width: width, cache: self.heightCache)
    }
    tableView.estimatedRowHeight = FKFeedContentCell.preferredRowHeight
    let posts = FKCellKitExampleSampleData.feedPosts
    FKCellKitListItemFactory.storeFeedContentPayloads(posts, on: self)
    super.viewDidLoad()
    applySnapshot(
      FKListSnapshot(items: posts.map(FKCellKitListItemFactory.feedContent)),
      animatingDifferences: false
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let width = tableView.bounds.width
    guard width > 0, abs(width - lastMeasuredTableWidth) > 0.5 else { return }
    lastMeasuredTableWidth = width
    heightCache.invalidateAll()
    guard tableView.numberOfSections > 0 else { return }
    tableView.reloadData()
  }
}
