import FKUIKit
import ObjectiveC.runtime
import UIKit

// MARK: - Skeleton reuse identifiers

public enum FKBaseListSkeletonReuseIdentifier {
  public static let tableCell = "fk.base.list.skeleton.table"
  public static let collectionCell = "fk.base.list.skeleton.collection"
}

// MARK: - Skeleton layouts

/// Shared placeholder layouts for list skeleton cells (table row and collection tile).
public enum FKBaseListSkeletonLayout {

  /// Avatar + two text lines (list row).
  @MainActor
  public static func applyListRow(to cell: FKSkeletonTableViewCell) {
    cell.resetSkeletonContent()
    let container = cell.skeletonContainer
    let avatar = FKSkeletonView()
    avatar.layer.cornerRadius = 22
    let line1 = FKSkeletonView()
    line1.layer.cornerRadius = 4
    let line2 = FKSkeletonView()
    line2.layer.cornerRadius = 4
    [avatar, line1, line2].forEach { container.addSkeletonSubview($0) }
    NSLayoutConstraint.activate([
      avatar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      avatar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      avatar.widthAnchor.constraint(equalToConstant: 44),
      avatar.heightAnchor.constraint(equalToConstant: 44),
      line1.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
      line1.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      line1.heightAnchor.constraint(equalToConstant: 12),
      line1.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
      line2.leadingAnchor.constraint(equalTo: line1.leadingAnchor),
      line2.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.45),
      line2.heightAnchor.constraint(equalToConstant: 10),
      line2.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
    ])
    container.showSkeleton(animated: false)
  }

  /// Rounded rectangle tile (grid cell).
  @MainActor
  public static func applyGridTile(to cell: FKSkeletonCollectionViewCell) {
    cell.resetSkeletonContent()
    let tile = FKSkeletonView()
    tile.layer.cornerRadius = 8
    cell.skeletonContainer.addSkeletonSubview(tile)
    NSLayoutConstraint.activate([
      tile.topAnchor.constraint(equalTo: cell.skeletonContainer.topAnchor),
      tile.leadingAnchor.constraint(equalTo: cell.skeletonContainer.leadingAnchor),
      tile.trailingAnchor.constraint(equalTo: cell.skeletonContainer.trailingAnchor),
      tile.bottomAnchor.constraint(equalTo: cell.skeletonContainer.bottomAnchor),
    ])
    cell.skeletonContainer.showSkeleton(animated: false)
  }
}

// MARK: - Shared list presentation storage

extension FKBaseViewController {
  fileprivate var listPresentationState: FKBaseListPresentationState {
    get {
      if let existing = objc_getAssociatedObject(self, &FKBaseListPresentationState.associationKey) as? FKBaseListPresentationState {
        return existing
      }
      let created = FKBaseListPresentationState()
      objc_setAssociatedObject(self, &FKBaseListPresentationState.associationKey, created, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return created
    }
    set {
      objc_setAssociatedObject(self, &FKBaseListPresentationState.associationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// List presentation policy; assign before the first load when customizing defaults.
  public var listPresentationOptions: FKBaseListPresentationOptions {
    get { listPresentationState.presentationOptions }
    set { listPresentationState.presentationOptions = newValue }
  }
}

private final class FKBaseListPresentationState {
  nonisolated(unsafe) static var associationKey: UInt8 = 0
  var isShowingSkeletonPlaceholders = false
  var presentationOptions = FKBaseListPresentationOptions()
}

// MARK: - Table

public extension FKBaseTableViewController {

  var isShowingSkeletonPlaceholders: Bool {
    get { listPresentationState.isShowingSkeletonPlaceholders }
    set { listPresentationState.isShowingSkeletonPlaceholders = newValue }
  }

  /// Placeholder row count while ``isShowingSkeletonPlaceholders`` is `true` (synced with ``listPresentationOptions``).
  var skeletonPlaceholderCount: Int {
    get { listPresentationOptions.skeletonPlaceholderCount }
    set { listPresentationOptions.skeletonPlaceholderCount = max(1, newValue) }
  }

  var currentListPresentationPhase: FKBaseListPresentationPhase {
    fk_derivedListPresentationPhase(
      clearingScrollView: listEmptyStateClearingScrollView,
      hostView: listEmptyStateHostView,
      isShowingSkeletonPlaceholders: isShowingSkeletonPlaceholders,
      loadMoreState: loadMoreState,
      pullToRefreshControl: pullToRefreshControl
    )
  }

  func registerDefaultSkeletonTableCell() {
    tableView.register(FKSkeletonTableViewCell.self, forCellReuseIdentifier: FKBaseListSkeletonReuseIdentifier.tableCell)
  }

  func reloadListContent() {
    tableView.reloadData()
  }

  func beginListLoadIfNeeded(isRefresh: Bool, currentItemCount: Int) {
    FKBaseListPresentationCoordinator.beginListLoadIfNeeded(
      isRefresh: isRefresh,
      currentItemCount: currentItemCount,
      options: listPresentationOptions,
      isShowingSkeletonPlaceholders: isShowingSkeletonPlaceholders,
      beginSkeleton: { [weak self] in
        self?.beginSkeletonPlaceholderLoading(
          count: self?.listPresentationOptions.skeletonPlaceholderCount,
          reloadData: true
        )
      }
    )
  }

  func finishListLoadPresentation(
    outcome: FKBaseListPresentationOutcome,
    isRefresh: Bool,
    retryHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    _ = isRefresh
    let wasShowingSkeleton = isShowingSkeletonPlaceholders
    endSkeletonPlaceholderLoading(reloadData: false)
    let animated = listPresentationOptions.animatesEmptyState
    FKBaseListPresentationCoordinator.finishListLoadPresentation(
      outcome: outcome,
      options: listPresentationOptions,
      applyEmptyState: { [weak self] configuration, handler in
        self?.applyListEmptyState(configuration, animated: animated, actionHandler: handler)
      },
      syncEmptyState: { [weak self] configuration, handler in
        self?.syncListEmptyState(itemCount: 0, emptyConfiguration: configuration, animated: animated, actionHandler: handler)
      },
      hideEmptyState: { [weak self] in
        self?.hideListEmptyState(animated: animated)
      },
      retryHandler: retryHandler
    )
    if wasShowingSkeleton {
      reloadListContent()
    }
  }

  func handleListEmptyStatePrimaryAction() {
    guard isPullToRefreshEnabled else { return }
    if let control = pullToRefreshControl {
      control.beginRefreshing()
    } else {
      performPullToRefresh()
    }
  }

  func beginSkeletonPlaceholderLoading(count: Int? = nil, reloadData: Bool = true) {
    if let count { skeletonPlaceholderCount = count }
    FKBaseListEmptyStateHost.hide(
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: false
    )
    hideLoading()
    isShowingSkeletonPlaceholders = true
    if reloadData { tableView.reloadData() }
  }

  func endSkeletonPlaceholderLoading(reloadData: Bool = true) {
    isShowingSkeletonPlaceholders = false
    if reloadData { tableView.reloadData() }
  }

  func applyListEmptyState(
    _ configuration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    hideLoading()
    hideEmptyView()
    FKBaseListEmptyStateHost.apply(
      configuration,
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false,
      actionHandler: actionHandler
    )
  }

  func hideListEmptyState(animated: Bool = true) {
    FKBaseListEmptyStateHost.hide(
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false
    )
  }

  func syncListEmptyState(
    itemCount: Int,
    emptyConfiguration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    guard !isShowingSkeletonPlaceholders else { return }
    FKBaseListEmptyStateHost.sync(
      itemCount: itemCount,
      configuration: emptyConfiguration,
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false,
      actionHandler: actionHandler
    )
  }

  func configureDefaultSkeletonTableCell(_ cell: FKSkeletonTableViewCell, at index: Int) {
    _ = index
    FKBaseListSkeletonLayout.applyListRow(to: cell)
  }

  func listDataSourceRowCount(actualCount: Int) -> Int {
    isShowingSkeletonPlaceholders ? skeletonPlaceholderCount : actualCount
  }

  func dequeueDefaultSkeletonTableCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: FKBaseListSkeletonReuseIdentifier.tableCell,
      for: indexPath
    ) as! FKSkeletonTableViewCell
    configureDefaultSkeletonTableCell(cell, at: indexPath.row)
    return cell
  }
}

// MARK: - Collection

public extension FKBaseCollectionViewController {

  var isShowingSkeletonPlaceholders: Bool {
    get { listPresentationState.isShowingSkeletonPlaceholders }
    set { listPresentationState.isShowingSkeletonPlaceholders = newValue }
  }

  var skeletonPlaceholderCount: Int {
    get { listPresentationOptions.skeletonPlaceholderCount }
    set { listPresentationOptions.skeletonPlaceholderCount = max(1, newValue) }
  }

  var currentListPresentationPhase: FKBaseListPresentationPhase {
    fk_derivedListPresentationPhase(
      clearingScrollView: listEmptyStateClearingScrollView,
      hostView: listEmptyStateHostView,
      isShowingSkeletonPlaceholders: isShowingSkeletonPlaceholders,
      loadMoreState: loadMoreState,
      pullToRefreshControl: pullToRefreshControl
    )
  }

  func registerDefaultSkeletonCollectionCell() {
    collectionView.register(
      FKSkeletonCollectionViewCell.self,
      forCellWithReuseIdentifier: FKBaseListSkeletonReuseIdentifier.collectionCell
    )
  }

  func reloadListContent() {
    collectionView.reloadData()
  }

  func beginListLoadIfNeeded(isRefresh: Bool, currentItemCount: Int) {
    FKBaseListPresentationCoordinator.beginListLoadIfNeeded(
      isRefresh: isRefresh,
      currentItemCount: currentItemCount,
      options: listPresentationOptions,
      isShowingSkeletonPlaceholders: isShowingSkeletonPlaceholders,
      beginSkeleton: { [weak self] in
        self?.beginSkeletonPlaceholderLoading(
          count: self?.listPresentationOptions.skeletonPlaceholderCount,
          reloadData: true
        )
      }
    )
  }

  func finishListLoadPresentation(
    outcome: FKBaseListPresentationOutcome,
    isRefresh: Bool,
    retryHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    _ = isRefresh
    let wasShowingSkeleton = isShowingSkeletonPlaceholders
    endSkeletonPlaceholderLoading(reloadData: false)
    let animated = listPresentationOptions.animatesEmptyState
    FKBaseListPresentationCoordinator.finishListLoadPresentation(
      outcome: outcome,
      options: listPresentationOptions,
      applyEmptyState: { [weak self] configuration, handler in
        self?.applyListEmptyState(configuration, animated: animated, actionHandler: handler)
      },
      syncEmptyState: { [weak self] configuration, handler in
        self?.syncListEmptyState(itemCount: 0, emptyConfiguration: configuration, animated: animated, actionHandler: handler)
      },
      hideEmptyState: { [weak self] in
        self?.hideListEmptyState(animated: animated)
      },
      retryHandler: retryHandler
    )
    if wasShowingSkeleton {
      reloadListContent()
    }
  }

  func handleListEmptyStatePrimaryAction() {
    guard isPullToRefreshEnabled else { return }
    if let control = pullToRefreshControl {
      control.beginRefreshing()
    } else {
      performPullToRefresh()
    }
  }

  func beginSkeletonPlaceholderLoading(count: Int? = nil, reloadData: Bool = true) {
    if let count { skeletonPlaceholderCount = count }
    FKBaseListEmptyStateHost.hide(
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: false
    )
    hideLoading()
    isShowingSkeletonPlaceholders = true
    if reloadData { collectionView.reloadData() }
  }

  func endSkeletonPlaceholderLoading(reloadData: Bool = true) {
    isShowingSkeletonPlaceholders = false
    if reloadData { collectionView.reloadData() }
  }

  func applyListEmptyState(
    _ configuration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    hideLoading()
    hideEmptyView()
    FKBaseListEmptyStateHost.apply(
      configuration,
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false,
      actionHandler: actionHandler
    )
  }

  func hideListEmptyState(animated: Bool = true) {
    FKBaseListEmptyStateHost.hide(
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false
    )
  }

  func syncListEmptyState(
    itemCount: Int,
    emptyConfiguration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    guard !isShowingSkeletonPlaceholders else { return }
    FKBaseListEmptyStateHost.sync(
      itemCount: itemCount,
      configuration: emptyConfiguration,
      on: listEmptyStateHostView,
      clearingScrollView: listEmptyStateClearingScrollView,
      animated: listPresentationOptions.animatesEmptyState ? animated : false,
      actionHandler: actionHandler
    )
  }

  func configureDefaultSkeletonCollectionCell(_ cell: FKSkeletonCollectionViewCell, at index: Int) {
    _ = index
    FKBaseListSkeletonLayout.applyGridTile(to: cell)
  }

  func listDataSourceItemCount(actualCount: Int) -> Int {
    isShowingSkeletonPlaceholders ? skeletonPlaceholderCount : actualCount
  }

  func dequeueDefaultSkeletonCollectionCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: FKBaseListSkeletonReuseIdentifier.collectionCell,
      for: indexPath
    ) as! FKSkeletonCollectionViewCell
    configureDefaultSkeletonCollectionCell(cell, at: indexPath.item)
    return cell
  }
}

// MARK: - Phase derivation

extension FKBaseViewController {

  fileprivate func fk_derivedListPresentationPhase(
    clearingScrollView: UIScrollView?,
    hostView: UIView,
    isShowingSkeletonPlaceholders: Bool,
    loadMoreState: FKBaseLoadMoreState,
    pullToRefreshControl: FKRefreshControl?
  ) -> FKBaseListPresentationPhase {
    if isShowingSkeletonPlaceholders { return .initialLoading }
    if pullToRefreshControl?.state == .refreshing { return .refreshing }
    if loadMoreState == .loading { return .loadingNextPage }
    if hostView.fk_isEmptyStateOverlayVisible {
      switch hostView.fk_emptyStateConfiguration?.phase {
      case .error:
        return .error
      case .empty, .loading:
        return .empty
      default:
        break
      }
    }
    if clearingScrollView?.fk_isEmptyStateOverlayVisible == true {
      return .empty
    }
    return .content
  }
}
