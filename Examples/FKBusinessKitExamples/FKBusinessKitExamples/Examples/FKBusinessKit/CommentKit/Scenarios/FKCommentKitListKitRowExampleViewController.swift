import FKBusinessKit
import UIKit

/// Demonstrates CommentKit ListKit registration for ``standard`` or ``compact`` rows.
final class FKCommentKitListKitRowExampleViewController: FKDiffableTableViewController, FKListDelegate {
  private let layoutPreset: FKCommentLayoutPreset
  private var items: [FKCommentItem]
  private let kitConfiguration: FKCommentKitConfiguration

  init(layoutPreset: FKCommentLayoutPreset = .standard) {
    self.layoutPreset = layoutPreset
    self.kitConfiguration = .configuration(for: layoutPreset)
    self.items = layoutPreset == .compact
      ? FKCommentKitExampleSampleData.compactTopLevel
      : FKCommentKitExampleSampleData.topLevelPage1
    super.init(configuration: FKListDefaults.feedConfiguration)
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = layoutPreset == .compact ? "ListKit Compact Row" : "ListKit Comment Row"
    FKCommentListRegistration.registerCommentRowCell(on: self, layoutPreset: layoutPreset)
    tableView.estimatedRowHeight = layoutPreset == .compact
      ? FKCommentCompactRowCell.preferredRowHeight
      : FKCommentRowCell.preferredRowHeight
    tableView.rowHeight = UITableView.automaticDimension
    if layoutPreset == .compact {
      tableView.separatorStyle = .none
    }
    super.viewDidLoad()
    applyItems()
  }

  override func configureCustomCell(
    _ cell: UITableViewCell,
    at indexPath: IndexPath,
    with item: FKListItem
  ) {
    guard let comment = payload(for: item.id)?.unwrap(FKCommentItem.self) else { return }
    switch layoutPreset {
    case .standard:
      guard let rowCell = cell as? FKCommentRowCell else { return }
      rowCell.apply(kitConfiguration: kitConfiguration)
      rowCell.configure(with: comment)
      rowCell.onLike = { [weak self] tapped in
        self?.toggleLike(tapped, standardCell: rowCell, compactCell: nil)
      }
      rowCell.onReply = { [weak self] item in
        self?.flash("Reply: \(item.authorName)")
      }
      rowCell.onRowTap = { [weak self] item in
        self?.flash("Row tap → reply: \(item.id)")
      }
      rowCell.onMore = { [weak self] item, _ in
        self?.flash("More: \(item.id)")
      }
      rowCell.onAuthor = { [weak self] item in
        self?.flash("Author: \(item.authorName)")
      }
      rowCell.onAvatar = { [weak self] item in
        self?.flash("Avatar: \(item.authorName)")
      }
      rowCell.onToggleExpand = { [weak self] item in
        self?.flash("Expand: \(item.id) — use Interactive list for full expand")
      }
      rowCell.onBodyExpansionChange = { [weak self] in
        self?.tableView.beginUpdates()
        self?.tableView.endUpdates()
      }
    case .compact:
      guard let rowCell = cell as? FKCommentCompactRowCell else { return }
      rowCell.apply(kitConfiguration: kitConfiguration)
      rowCell.configure(with: comment)
      rowCell.onLike = { [weak self] tapped in
        self?.toggleLike(tapped, standardCell: nil, compactCell: rowCell)
      }
      rowCell.onReply = { [weak self] item in
        self?.flash("Reply: \(item.authorName)")
      }
      rowCell.onRowTap = { [weak self] item in
        self?.flash("Row tap → reply: \(item.id)")
      }
      rowCell.onAuthor = { [weak self] item in
        self?.flash("Author: \(item.authorName)")
      }
      rowCell.onAvatar = { [weak self] item in
        self?.flash("Avatar: \(item.authorName)")
      }
      rowCell.onToggleExpand = { [weak self] item in
        self?.flash("Expand: \(item.id) — use Interactive list for full expand")
      }
      rowCell.onBodyExpansionChange = { [weak self] in
        self?.tableView.beginUpdates()
        self?.tableView.endUpdates()
      }
    }
  }

  private func applyItems() {
    for item in items {
      setPayload(FKListItemPayload(item), for: FKListItemID(item.id))
    }
    let cellType: String = layoutPreset == .compact
      ? FKCommentCompactRowCell.listKitCellTypeIdentifier
      : FKCommentRowCell.listKitCellTypeIdentifier
    let listItems = items.map { item in
      FKListItem.custom(
        id: FKListItemID(item.id),
        cellTypeIdentifier: cellType
      )
    }
    applySnapshot(FKListSnapshot(items: listItems), animatingDifferences: false)
  }

  private func toggleLike(
    _ tapped: FKCommentItem,
    standardCell: FKCommentRowCell?,
    compactCell: FKCommentCompactRowCell?
  ) {
    guard let index = items.firstIndex(where: { $0.id == tapped.id }) else { return }
    let updated = FKCommentLikeOptimisticController.toggled(tapped)
    items[index] = updated
    setPayload(FKListItemPayload(updated), for: FKListItemID(updated.id))
    standardCell?.applyLikeState(isLiked: updated.isLiked, likeCount: updated.likeCount)
    compactCell?.applyLikeState(
      isLiked: updated.isLiked,
      likeCount: updated.likeCount,
      likeCountText: updated.likeCountText
    )
  }

  /// Lightweight feedback — ListKit host is not ``FKBaseViewController``.
  private func flash(_ message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    present(alert, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak alert] in
      alert?.dismiss(animated: true)
    }
  }

  func list(
    _ list: FKDiffableTableViewController,
    willDisplay item: FKListItemID,
    at indexPath: IndexPath
  ) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
  }

  func list(
    _ list: FKDiffableTableViewController,
    didEndDisplaying item: FKListItemID,
    at indexPath: IndexPath
  ) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
  }
}
