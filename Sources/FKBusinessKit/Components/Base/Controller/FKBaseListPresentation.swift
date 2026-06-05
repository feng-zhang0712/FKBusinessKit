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

// MARK: - Table

public extension FKBaseTableViewController {

  /// When `true`, ``UITableViewDataSource`` should serve ``FKSkeletonTableViewCell`` placeholder rows.
  var isShowingSkeletonPlaceholders: Bool {
    get { listPresentationState.isShowingSkeletonPlaceholders }
    set { listPresentationState.isShowingSkeletonPlaceholders = newValue }
  }

  /// Placeholder row count while ``isShowingSkeletonPlaceholders`` is `true`.
  var skeletonPlaceholderCount: Int {
    get { listPresentationState.skeletonPlaceholderCount }
    set { listPresentationState.skeletonPlaceholderCount = max(1, newValue) }
  }

  /// Registers ``FKSkeletonTableViewCell`` with ``FKBaseListSkeletonReuseIdentifier/tableCell``.
  func registerDefaultSkeletonTableCell() {
    tableView.register(FKSkeletonTableViewCell.self, forCellReuseIdentifier: FKBaseListSkeletonReuseIdentifier.tableCell)
  }

  /// Shows skeleton placeholder rows and hides ``FKEmptyState`` overlays.
  func beginSkeletonPlaceholderLoading(count: Int? = nil, reloadData: Bool = true) {
    if let count { skeletonPlaceholderCount = count }
    hideListEmptyState(animated: false)
    hideLoading()
    isShowingSkeletonPlaceholders = true
    if reloadData { tableView.reloadData() }
  }

  /// Clears skeleton placeholder mode (call before applying real data or empty/error overlays).
  func endSkeletonPlaceholderLoading(reloadData: Bool = true) {
    isShowingSkeletonPlaceholders = false
    if reloadData { tableView.reloadData() }
  }

  /// Applies ``FKEmptyState`` on ``tableView`` (loading / empty / error).
  func applyListEmptyState(
    _ configuration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    hideLoading()
    hideEmptyView()
    hideErrorView()
    tableView.fk_applyEmptyState(configuration, animated: animated, actionHandler: actionHandler)
  }

  /// Hides scroll-view ``FKEmptyState`` overlay (`phase = .content`).
  func hideListEmptyState(animated: Bool = true) {
    var hidden = tableView.fk_emptyStateConfiguration ?? FKEmptyStateConfiguration(phase: .content)
    hidden.phase = .content
    tableView.fk_applyEmptyState(hidden, animated: animated)
  }

  /// Updates empty/error overlay from current row count (no-op while skeleton placeholders are visible).
  func syncListEmptyState(
    itemCount: Int,
    emptyConfiguration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    guard !isShowingSkeletonPlaceholders else { return }
    tableView.fk_updateEmptyState(
      itemCount: itemCount,
      configuration: emptyConfiguration,
      animated: animated,
      actionHandler: actionHandler
    )
  }

  /// Default skeleton cell configuration (override for custom placeholder chrome).
  func configureDefaultSkeletonTableCell(_ cell: FKSkeletonTableViewCell, at index: Int) {
    _ = index
    FKBaseListSkeletonLayout.applyListRow(to: cell)
  }
}

// MARK: - Collection

public extension FKBaseCollectionViewController {

  var isShowingSkeletonPlaceholders: Bool {
    get { listPresentationState.isShowingSkeletonPlaceholders }
    set { listPresentationState.isShowingSkeletonPlaceholders = newValue }
  }

  var skeletonPlaceholderCount: Int {
    get { listPresentationState.skeletonPlaceholderCount }
    set { listPresentationState.skeletonPlaceholderCount = max(1, newValue) }
  }

  func registerDefaultSkeletonCollectionCell() {
    collectionView.register(
      FKSkeletonCollectionViewCell.self,
      forCellWithReuseIdentifier: FKBaseListSkeletonReuseIdentifier.collectionCell
    )
  }

  func beginSkeletonPlaceholderLoading(count: Int? = nil, reloadData: Bool = true) {
    if let count { skeletonPlaceholderCount = count }
    hideListEmptyState(animated: false)
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
    hideErrorView()
    collectionView.fk_applyEmptyState(configuration, animated: animated, actionHandler: actionHandler)
  }

  func hideListEmptyState(animated: Bool = true) {
    var hidden = collectionView.fk_emptyStateConfiguration ?? FKEmptyStateConfiguration(phase: .content)
    hidden.phase = .content
    collectionView.fk_applyEmptyState(hidden, animated: animated)
  }

  func syncListEmptyState(
    itemCount: Int,
    emptyConfiguration: FKEmptyStateConfiguration,
    animated: Bool = true,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    guard !isShowingSkeletonPlaceholders else { return }
    collectionView.fk_updateEmptyState(
      itemCount: itemCount,
      configuration: emptyConfiguration,
      animated: animated,
      actionHandler: actionHandler
    )
  }

  func configureDefaultSkeletonCollectionCell(_ cell: FKSkeletonCollectionViewCell, at index: Int) {
    _ = index
    FKBaseListSkeletonLayout.applyGridTile(to: cell)
  }
}

// MARK: - Shared storage

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
}

private final class FKBaseListPresentationState {
  nonisolated(unsafe) static var associationKey: UInt8 = 0
  var isShowingSkeletonPlaceholders = false
  var skeletonPlaceholderCount = 8
}
