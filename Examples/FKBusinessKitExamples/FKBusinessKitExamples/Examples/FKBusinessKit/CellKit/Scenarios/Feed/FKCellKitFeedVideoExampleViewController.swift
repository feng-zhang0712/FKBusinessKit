import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKFeedVideoCell`` with pooled players and scroll-driven autoplay.
final class FKCellKitFeedVideoExampleViewController: FKDiffableTableViewController, FKListDelegate {
  private let playerPool = FKVideoPlayerPool(maxPlayers: 2)

  init() {
    super.init(configuration: FKListDefaults.feedConfiguration)
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Feed Video"
    FKCellKitListRegistration.registerFeedVideoCell(on: self)
    _ = FKCellKitVideoSetup.attachVideoVisibility(to: self, pool: playerPool)
    rowHeightProvider = { [weak self] item in
      guard let self else { return FKFeedVideoCell.preferredRowHeight }
      let hasCaption = self.payload(for: item.id)?.unwrap(FKFeedVideoItem.self)?.caption?.isEmpty == false
      let width = self.tableView.bounds.width > 0 ? self.tableView.bounds.width : UIScreen.main.bounds.width
      return FKFeedVideoCell.preferredRowHeight(forWidth: width, hasCaption: hasCaption)
    }
    tableView.estimatedRowHeight = FKFeedVideoCell.preferredRowHeight
    let videos = FKCellKitExampleSampleData.feedVideos
    FKCellKitListItemFactory.storeFeedVideoPayloads(videos, on: self)
    super.viewDidLoad()
    applySnapshot(
      FKListSnapshot(items: videos.map(FKCellKitListItemFactory.feedVideo)),
      animatingDifferences: false
    )
  }

  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVideoVisibilityWillDisplay(at: indexPath, pool: playerPool)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVideoVisibilityDidEndDisplaying(at: indexPath, pool: playerPool)
  }
}
