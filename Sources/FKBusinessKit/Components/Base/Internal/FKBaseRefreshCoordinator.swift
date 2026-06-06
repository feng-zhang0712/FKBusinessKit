import FKUIKit
import UIKit

@MainActor
final class FKBaseRefreshCoordinator {
  var isPullToRefreshEnabled = false
  var isLoadMoreEnabled = false

  private(set) var pullToRefreshControl: FKRefreshControl?
  private(set) var loadMoreControl: FKRefreshControl?
  private(set) var loadMoreState: FKBaseLoadMoreState = .idle

  private var didInstallControls = false

  func installIfNeeded(
    on scrollView: UIScrollView,
    pullHandler: @escaping () -> Void,
    loadMoreHandler: (() -> Void)? = nil
  ) {
    guard !didInstallControls else { return }
    didInstallControls = true

    if isPullToRefreshEnabled {
      pullToRefreshControl = scrollView.fk_addPullToRefresh {
        pullHandler()
      }
    }

    if isLoadMoreEnabled {
      loadMoreControl = scrollView.fk_addLoadMore {
        loadMoreHandler?()
      }
    }
  }

  func endPullToRefresh(success: Bool) {
    guard let control = pullToRefreshControl else { return }
    if success {
      control.endRefreshing()
    } else {
      control.endRefreshingWithError(nil)
    }
  }

  func markLoadMoreFinished() {
    loadMoreState = .idle
    loadMoreControl?.endLoadingMore()
  }

  func markLoadMoreNoMoreData() {
    loadMoreState = .completed
    loadMoreControl?.endRefreshingWithNoMoreData()
  }

  func markLoadMoreFailed(_ error: Error? = nil) {
    loadMoreState = .failed
    loadMoreControl?.endRefreshingWithError(error)
  }

  func handleLoadMoreInvoked(performLoadMore: () -> Void) {
    guard loadMoreState != .completed else {
      loadMoreControl?.endRefreshingWithNoMoreData()
      return
    }
    guard loadMoreState != .loading else { return }
    loadMoreState = .loading
    performLoadMore()
  }
}
