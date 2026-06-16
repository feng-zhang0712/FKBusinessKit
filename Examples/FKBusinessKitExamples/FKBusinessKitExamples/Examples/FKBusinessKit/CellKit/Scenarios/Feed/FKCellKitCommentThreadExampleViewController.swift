import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKCommentThreadCell`` indentation, thread line, and cached dynamic heights.
final class FKCellKitCommentThreadExampleViewController: FKDiffableTableViewController {
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
    title = "Comment Thread"
    FKCellKitListRegistration.registerCommentThreadCell(on: self)
    rowHeightProvider = { [weak self] item in
      guard let self else { return FKCommentThreadCell.preferredRowHeight }
      guard let comment = self.payload(for: item.id)?.unwrap(FKCommentThreadItem.self) else {
        return FKCommentThreadCell.preferredRowHeight
      }
      let width = self.tableView.bounds.width > 0 ? self.tableView.bounds.width : UIScreen.main.bounds.width
      return FKCommentThreadCellHeightEstimator.estimatedRowHeight(for: comment, width: width, cache: self.heightCache)
    }
    tableView.estimatedRowHeight = FKCommentThreadCell.preferredRowHeight
    let comments = FKCellKitExampleSampleData.commentThread
    FKCellKitListItemFactory.storeCommentThreadPayloads(comments, on: self)
    super.viewDidLoad()
    applySnapshot(
      FKListSnapshot(items: comments.map(FKCellKitListItemFactory.commentThread)),
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
