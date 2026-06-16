import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKUserListCell`` with ListKit refresh, load-more, and full row payload variants.
final class FKCellKitUserListExampleViewController: FKDiffableTableViewController, FKListDataProviding {
  init() {
    var config = FKListDefaults.feedConfiguration
    config.refresh.loadMorePreloadOffset = 120
    super.init(configuration: config)
    dataProvider = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "User List"
    FKCellKitListRegistration.registerUserListCell(on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKUserListCell.preferredRowHeight
  }

  func fetchInitial(page: Int) async throws -> FKListFetchResult {
    let users = try await FKCellKitExampleSampleData.delayed(FKCellKitExampleSampleData.users)
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    return FKListFetchResult(
      snapshot: FKCellKitExampleSampleData.makeUserListSnapshot(users),
      hasMorePages: true
    )
  }

  func fetchNextPage(after pagination: FKRefreshPagination) async throws -> FKListFetchResult {
    let extra = FKUserListItem(
      id: "user.page.\(pagination.nextPage)",
      displayName: "Page \(pagination.nextPage) contact",
      subtitle: "Loaded via load-more",
      avatarURL: FKCellKitExampleSampleData.remoteImageURL(id: 70 + pagination.nextPage, width: 80, height: 80),
      presenceState: .online,
      unreadCount: pagination.nextPage,
      timestampText: "Now"
    )
    let users = FKCellKitExampleSampleData.users + [extra]
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    return FKListFetchResult(
      snapshot: FKCellKitExampleSampleData.makeUserListSnapshot(users),
      hasMorePages: pagination.nextPage < 3
    )
  }

  func fetchRefresh(page: Int) async throws -> FKListFetchResult {
    let users = try await FKCellKitExampleSampleData.delayed(FKCellKitExampleSampleData.users, seconds: 0.45)
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    return FKListFetchResult(
      snapshot: FKCellKitExampleSampleData.makeUserListSnapshot(users),
      hasMorePages: true
    )
  }
}
