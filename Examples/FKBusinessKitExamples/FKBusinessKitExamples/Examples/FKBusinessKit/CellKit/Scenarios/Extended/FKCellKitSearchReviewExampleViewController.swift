import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKSearchResultCell`` and ``FKReviewListCell``.
final class FKCellKitSearchReviewExampleViewController: FKDiffableTableViewController {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Search & Reviews"
    FKCellKitListRegistration.registerSearchResultCell(on: self)
    FKCellKitListRegistration.registerReviewListCell(on: self)
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = FKReviewListCell.preferredRowHeight

    let search = FKCellKitExampleSampleData.searchResults
    let reviews = FKCellKitExampleSampleData.reviews
    FKCellKitListItemFactory.storeSearchResultPayloads(search, on: self)
    FKCellKitListItemFactory.storeReviewListPayloads(reviews, on: self)

    applySnapshot(
      FKListSnapshot(sections: [
        FKListSection(id: "search", items: search.map(FKCellKitListItemFactory.searchResult), header: .title("Search hits")),
        FKListSection(id: "reviews", items: reviews.map(FKCellKitListItemFactory.reviewList), header: .title("Product reviews")),
      ]),
      animatingDifferences: false
    )
  }
}

extension FKCellKitSearchReviewExampleViewController: FKListDelegate {
  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
  }
}
