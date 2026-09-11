import UIKit
import FKUIKit

/// Comment list screen hosting a table of ``FKCommentRowCell`` rows and a bottom ``FKCommentComposerView``.
///
/// Wire ``commentDataSource`` and optionally ``commentDelegate``. The controller never performs networking itself.
@MainActor
open class FKCommentListViewController: FKBaseTableViewController, UITableViewDataSource, UITableViewDelegate {
  /// App-provided data operations.
  public weak var commentDataSource: FKCommentListDataSource?
  /// App-provided interaction callbacks.
  public weak var commentDelegate: FKCommentListDelegate?

  /// Appearance and feature flags.
  public var commentConfiguration: FKCommentKitConfiguration = .init() {
    didSet { applyCommentConfiguration() }
  }

  /// Optional per-item extra more-menu actions. When set, overrides ``FKCommentKitConfiguration/additionalMoreActions``.
  public var additionalMoreActionsProvider: ((FKCommentItem) -> [FKCommentCustomMoreAction])?

  /// Flat ordered rows currently displayed.
  public private(set) var comments: [FKCommentItem] = []

  /// Bottom composer view.
  public let composerView = FKCommentComposerView()

  private var hasMorePages: Bool = false
  private var isLoadingInitial: Bool = false
  private var isLoadingRepliesFor: Set<String> = []
  private let standardCellReuseIdentifier = "FKCommentRowCell"
  private let compactCellReuseIdentifier = "FKCommentCompactRowCell"
  private var tableBottomToComposerConstraint: NSLayoutConstraint?
  private var tableBottomToKeyboardConstraint: NSLayoutConstraint?

  public override init(style: UITableView.Style = .plain) {
    super.init(style: style)
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - Lifecycle

  open override func setupUI() {
    super.setupUI()
    // Keep the keyboard up so tapping another row can switch the reply target.
    dismissKeyboardOnTapEnabled = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
    tableView.register(FKCommentRowCell.self, forCellReuseIdentifier: standardCellReuseIdentifier)
    tableView.register(
      FKCommentCompactRowCell.self,
      forCellReuseIdentifier: compactCellReuseIdentifier
    )
    tableView.estimatedRowHeight = FKCommentRowCell.preferredRowHeight

    composerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(composerView)

    composerView.onSend = { [weak self] text in
      self?.handleSend(text: text)
    }
    composerView.onCancelReply = { [weak self] in
      self?.composerView.replyTarget = nil
    }

    applyCommentConfiguration()
  }

  open override func setupConstraints() {
    let toComposer = tableView.bottomAnchor.constraint(equalTo: composerView.topAnchor)
    let toKeyboard = tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
    tableBottomToComposerConstraint = toComposer
    tableBottomToKeyboardConstraint = toKeyboard

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: tableViewTopLayoutAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      toComposer,

      composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      composerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
    ])
    applyComposerVisibilityConstraints()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    reloadComments()
  }

  // MARK: - Public API

  /// Reloads the first page from ``commentDataSource``.
  public func reloadComments() {
    guard let commentDataSource else { return }
    guard !isLoadingInitial else { return }
    isLoadingInitial = true
    let isRefresh = !comments.isEmpty
    beginListLoadIfNeeded(isRefresh: isRefresh, currentItemCount: comments.count)
    commentDataSource.commentListLoadInitial { [weak self] result in
      guard let self else { return }
      self.isLoadingInitial = false
      self.endPullToRefresh(success: result.isSuccess)
      switch result {
      case .success(let page):
        self.comments = page.items
        self.hasMorePages = page.hasMore
        if page.hasMore {
          self.markLoadMoreFinished()
        } else {
          self.markLoadMoreNoMoreData()
        }
        self.tableView.reloadData()
        let outcome: FKBaseListPresentationOutcome = page.items.isEmpty
          ? .empty
          : .content(itemCount: page.items.count)
        self.finishListLoadPresentation(outcome: outcome, isRefresh: isRefresh) { [weak self] _ in
          self?.reloadComments()
        }
      case .failure:
        self.finishListLoadPresentation(
          outcome: .failed(kind: .transport, message: nil),
          isRefresh: isRefresh
        ) { [weak self] _ in
          self?.reloadComments()
        }
      }
    }
  }

  /// Replaces the in-memory list (e.g. after external mutation) and reloads the table.
  public func replaceComments(_ items: [FKCommentItem], hasMore: Bool? = nil) {
    comments = items
    if let hasMore {
      hasMorePages = hasMore
      if hasMore {
        markLoadMoreFinished()
      } else {
        markLoadMoreNoMoreData()
      }
    }
    tableView.reloadData()
  }

  /// Updates a single comment in place (e.g. after a successful server sync).
  public func updateComment(_ item: FKCommentItem) {
    comments = FKCommentListMutation.replacing(item, in: comments)
    reloadRow(id: item.id, preferLikeOnly: false)
  }

  /// Removes a comment and its expanded children from the list (call after delete succeeds).
  public func removeComment(id: String) {
    comments = FKCommentListMutation.removing(id: id, from: comments)
    tableView.reloadData()
    if comments.isEmpty {
      finishListLoadPresentation(outcome: .empty, isRefresh: false) { [weak self] _ in
        self?.reloadComments()
      }
    }
  }

  /// Applies an optimistic like toggle and notifies the delegate.
  public func toggleLike(for item: FKCommentItem) {
    let previousIsLiked = item.isLiked
    let previousLikeCount = item.likeCount
    let updated = FKCommentLikeOptimisticController.toggled(item)
    comments = FKCommentLikeOptimisticController.replacing(updated, in: comments)
    reloadRow(id: updated.id, preferLikeOnly: true)
    commentDelegate?.commentList(
      self,
      didToggleLike: updated,
      previousIsLiked: previousIsLiked,
      previousLikeCount: previousLikeCount
    )
  }

  /// Rolls back like state after a failed network call.
  public func rollbackLike(
    commentId: String,
    previousIsLiked: Bool,
    previousLikeCount: Int
  ) {
    guard let index = comments.firstIndex(where: { $0.id == commentId }) else { return }
    let rolled = FKCommentLikeOptimisticController.rolledBack(
      comments[index],
      previousIsLiked: previousIsLiked,
      previousLikeCount: previousLikeCount
    )
    comments[index] = rolled
    reloadRow(id: commentId, preferLikeOnly: true)
  }

  /// Sets the composer reply target and focuses input.
  public func beginReply(to item: FKCommentItem) {
    guard commentConfiguration.showsComposer else {
      commentDelegate?.commentList(self, didTapReply: item)
      return
    }
    composerView.replyTarget = FKCommentReplyTarget(id: item.id, displayName: item.authorName)
    // Defer until after reply-banner layout so `becomeFirstResponder` reliably shows the keyboard.
    DispatchQueue.main.async { [weak self] in
      self?.composerView.focus()
    }
    commentDelegate?.commentList(self, didTapReply: item)
  }

  // MARK: - Refresh

  open override func performPullToRefresh() {
    reloadComments()
  }

  open override func performLoadMore() {
    guard hasMorePages, let commentDataSource else {
      markLoadMoreNoMoreData()
      return
    }
    commentDataSource.commentListLoadMore { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let page):
        self.comments = FKCommentListMutation.appendingUnique(page.items, onto: self.comments)
        self.hasMorePages = page.hasMore
        self.tableView.reloadData()
        if page.hasMore {
          self.markLoadMoreFinished()
        } else {
          self.markLoadMoreNoMoreData()
        }
      case .failure(let error):
        self.markLoadMoreFailed(error)
      }
    }
  }

  // MARK: - UITableViewDataSource

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    listDataSourceRowCount(actualCount: comments.count)
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isShowingSkeletonPlaceholders {
      return dequeueDefaultSkeletonTableCell(in: tableView, at: indexPath)
    }
    let item = comments[indexPath.row]
    switch commentConfiguration.layoutPreset {
    case .compact:
      return makeCompactCell(in: tableView, at: indexPath, item: item)
    case .standard:
      return makeStandardCell(in: tableView, at: indexPath, item: item)
    }
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    guard !isShowingSkeletonPlaceholders else { return }
    guard commentConfiguration.beginsReplyOnRowTap else { return }
    guard comments.indices.contains(indexPath.row) else { return }
    beginReply(to: comments[indexPath.row])
  }

  // MARK: - Private

  private func makeStandardCell(
    in tableView: UITableView,
    at indexPath: IndexPath,
    item: FKCommentItem
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: standardCellReuseIdentifier,
      for: indexPath
    )
    guard let rowCell = cell as? FKCommentRowCell else { return cell }
    rowCell.apply(kitConfiguration: commentConfiguration)
    rowCell.hasAdditionalMoreActions = !resolvedAdditionalMoreActions(for: item).isEmpty
    rowCell.configure(with: item)
    rowCell.onLike = { [weak self] item in
      self?.toggleLike(for: item)
    }
    rowCell.onReply = { [weak self] item in
      self?.beginReply(to: item)
    }
    rowCell.onRowTap = { [weak self] item in
      self?.beginReply(to: item)
    }
    rowCell.onMore = { [weak self] item, sourceView in
      self?.presentMoreMenu(for: item, sourceView: sourceView)
    }
    rowCell.onAvatar = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapAvatar: item)
    }
    rowCell.onAuthor = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapAuthor: item)
    }
    rowCell.onComment = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapComment: item)
    }
    rowCell.onLongPress = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didLongPressComment: item)
    }
    rowCell.onToggleExpand = { [weak self] item in
      self?.toggleExpand(for: item)
    }
    rowCell.onBodyExpansionChange = { [weak self] in
      guard let self else { return }
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
    }
    rowCell.setExpandLoading(isLoadingRepliesFor.contains(item.id))
    return rowCell
  }

  private func makeCompactCell(
    in tableView: UITableView,
    at indexPath: IndexPath,
    item: FKCommentItem
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: compactCellReuseIdentifier,
      for: indexPath
    )
    guard let rowCell = cell as? FKCommentCompactRowCell else { return cell }
    rowCell.apply(kitConfiguration: commentConfiguration)
    rowCell.hasAdditionalMoreActions = !resolvedAdditionalMoreActions(for: item).isEmpty
    rowCell.configure(with: item)
    rowCell.onLike = { [weak self] item in
      self?.toggleLike(for: item)
    }
    rowCell.onReply = { [weak self] item in
      self?.beginReply(to: item)
    }
    rowCell.onRowTap = { [weak self] item in
      self?.beginReply(to: item)
    }
    rowCell.onMore = { [weak self] item, sourceView in
      self?.presentMoreMenu(for: item, sourceView: sourceView)
    }
    rowCell.onAvatar = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapAvatar: item)
    }
    rowCell.onAuthor = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapAuthor: item)
    }
    rowCell.onComment = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didTapComment: item)
    }
    rowCell.onLongPress = { [weak self] item in
      guard let self else { return }
      self.commentDelegate?.commentList(self, didLongPressComment: item)
    }
    rowCell.onToggleExpand = { [weak self] item in
      self?.toggleExpand(for: item)
    }
    rowCell.onBodyExpansionChange = { [weak self] in
      guard let self else { return }
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
    }
    rowCell.setExpandLoading(isLoadingRepliesFor.contains(item.id))
    return rowCell
  }

  private func applyCommentConfiguration() {
    isPullToRefreshEnabled = commentConfiguration.isPullToRefreshEnabled
    isLoadMoreEnabled = commentConfiguration.isLoadMoreEnabled
    composerView.configuration = commentConfiguration.composer
    composerView.strings = commentConfiguration.strings
    composerView.isHidden = !commentConfiguration.showsComposer
    composerView.isUserInteractionEnabled = commentConfiguration.showsComposer
    switch commentConfiguration.layoutPreset {
    case .compact:
      tableView.separatorStyle = .none
      tableView.estimatedRowHeight = FKCommentCompactRowCell.preferredRowHeight
      tableView.rowHeight = UITableView.automaticDimension
      tableView.separatorInset = .zero
    case .standard:
      tableView.separatorStyle = .singleLine
      tableView.estimatedRowHeight = FKCommentRowCell.preferredRowHeight
      tableView.rowHeight = UITableView.automaticDimension
      tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
    }
    applyComposerVisibilityConstraints()
    tableView.reloadData()
  }

  private func applyComposerVisibilityConstraints() {
    let showsComposer = commentConfiguration.showsComposer
    tableBottomToComposerConstraint?.isActive = showsComposer
    tableBottomToKeyboardConstraint?.isActive = !showsComposer
  }

  private func handleSend(text: String) {
    guard let commentDataSource else { return }
    let request = FKCommentSubmitRequest(
      text: text,
      replyToCommentId: composerView.replyTarget?.id
    )
    composerView.isSending = true
    commentDataSource.commentListSubmit(request) { [weak self] result in
      guard let self else { return }
      self.composerView.isSending = false
      switch result {
      case .success(let item):
        self.comments = FKCommentListMutation.insertingSubmitted(item, into: self.comments)
        self.composerView.resetAll()
        self.tableView.reloadData()
        self.scrollToComment(id: item.id, animated: true)
        self.commentDelegate?.commentList(self, didSubmit: item)
        if !self.comments.isEmpty {
          self.finishListLoadPresentation(
            outcome: .content(itemCount: self.comments.count),
            isRefresh: false
          )
        }
      case .failure(let error):
        self.commentDelegate?.commentList(self, didFailSubmit: request, error: error)
      }
    }
  }

  private func toggleExpand(for item: FKCommentItem) {
    if item.areRepliesExpanded {
      guard let parentIndex = comments.firstIndex(where: { $0.id == item.id }) else { return }
      let end = FKCommentListMutation.endIndexOfSubtree(rootedAt: parentIndex, in: comments)
      let deletePaths = ((parentIndex + 1)..<end).map { IndexPath(row: $0, section: 0) }
      comments = FKCommentListMutation.collapsingReplies(parentId: item.id, in: comments)
      tableView.performBatchUpdates {
        if !deletePaths.isEmpty {
          tableView.deleteRows(at: deletePaths, with: .fade)
        }
        tableView.reloadRows(at: [IndexPath(row: parentIndex, section: 0)], with: .none)
      }
      commentDelegate?.commentList(self, didExpandRepliesFor: item.id, inserted: [], error: nil)
      return
    }

    guard let commentDataSource else { return }
    guard !isLoadingRepliesFor.contains(item.id) else { return }
    isLoadingRepliesFor.insert(item.id)
    setExpandLoading(true, for: item.id)

    commentDataSource.commentListLoadReplies(parentId: item.id) { [weak self] result in
      guard let self else { return }
      self.isLoadingRepliesFor.remove(item.id)
      switch result {
      case .success(let replies):
        guard self.comments.contains(where: { $0.id == item.id }) else {
          self.setExpandLoading(false, for: item.id)
          return
        }
        self.comments = FKCommentListMutation.insertingReplies(
          replies,
          parentId: item.id,
          into: self.comments,
          maxCount: self.commentConfiguration.maxExpandedReplies
        )
        guard let parentIndex = self.comments.firstIndex(where: { $0.id == item.id }) else {
          self.tableView.reloadData()
          return
        }
        let insertedEnd = FKCommentListMutation.endIndexOfSubtree(
          rootedAt: parentIndex,
          in: self.comments
        )
        let insertPaths = ((parentIndex + 1)..<insertedEnd).map { IndexPath(row: $0, section: 0) }
        self.tableView.performBatchUpdates {
          if !insertPaths.isEmpty {
            self.tableView.insertRows(at: insertPaths, with: .fade)
          }
          self.tableView.reloadRows(at: [IndexPath(row: parentIndex, section: 0)], with: .none)
        }
        let inserted = self.comments.filter { $0.parentId == item.id }
        self.commentDelegate?.commentList(
          self,
          didExpandRepliesFor: item.id,
          inserted: inserted,
          error: nil
        )
      case .failure(let error):
        self.setExpandLoading(false, for: item.id)
        self.commentDelegate?.commentList(
          self,
          didExpandRepliesFor: item.id,
          inserted: [],
          error: error
        )
      }
    }
  }

  private func setExpandLoading(_ loading: Bool, for commentId: String) {
    guard let index = comments.firstIndex(where: { $0.id == commentId }) else { return }
    let indexPath = IndexPath(row: index, section: 0)
    UIView.performWithoutAnimation {
      if let cell = self.tableView.cellForRow(at: indexPath) as? FKCommentRowCell {
        cell.setExpandLoading(loading)
      } else if let cell = self.tableView.cellForRow(at: indexPath) as? FKCommentCompactRowCell {
        cell.setExpandLoading(loading)
      }
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
    }
  }

  private func presentMoreMenu(for item: FKCommentItem, sourceView: UIView) {
    if !commentConfiguration.presentsDefaultMoreMenu {
      commentDelegate?.commentList(self, didTapMore: item, sourceView: sourceView)
      return
    }

    let strings = commentConfiguration.strings
    var actions: [UIAlertAction] = []

    if commentConfiguration.showsCopyAction, !item.body.isEmpty {
      actions.append(UIAlertAction(title: strings.copy, style: .default) { [weak self] _ in
        UIPasteboard.general.string = item.body
        guard let self else { return }
        self.commentDelegate?.commentList(self, didSelectMore: .copy, for: item)
      })
    }

    if commentConfiguration.showsReportAction {
      actions.append(UIAlertAction(title: strings.report, style: .default) { [weak self] _ in
        guard let self else { return }
        self.commentDelegate?.commentList(self, didSelectMore: .report, for: item)
      })
    }

    if item.isDeletable {
      actions.append(UIAlertAction(title: strings.delete, style: .destructive) { [weak self] _ in
        guard let self else { return }
        self.commentDelegate?.commentList(self, didSelectMore: .delete, for: item)
      })
    }

    let customActions = resolvedAdditionalMoreActions(for: item)
    for custom in customActions {
      let style: UIAlertAction.Style = custom.isDestructive ? .destructive : .default
      actions.append(UIAlertAction(title: custom.title, style: style) { [weak self] _ in
        guard let self else { return }
        self.commentDelegate?.commentList(self, didSelectCustomMoreAction: custom.id, for: item)
      })
    }

    guard !actions.isEmpty else { return }

    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actions.forEach(sheet.addAction)
    sheet.addAction(UIAlertAction(title: strings.cancel, style: .cancel))

    if let popover = sheet.popoverPresentationController {
      popover.sourceView = sourceView
      popover.sourceRect = sourceView.bounds
      popover.permittedArrowDirections = [.up, .down]
    }
    present(sheet, animated: true)
  }

  private func resolvedAdditionalMoreActions(for item: FKCommentItem) -> [FKCommentCustomMoreAction] {
    additionalMoreActionsProvider?(item) ?? commentConfiguration.additionalMoreActions
  }

  private func reloadRow(id: String, preferLikeOnly: Bool) {
    guard let index = comments.firstIndex(where: { $0.id == id }) else {
      tableView.reloadData()
      return
    }
    let indexPath = IndexPath(row: index, section: 0)
    let item = comments[index]
    if preferLikeOnly {
      if let cell = tableView.cellForRow(at: indexPath) as? FKCommentRowCell {
        cell.applyLikeState(isLiked: item.isLiked, likeCount: item.likeCount)
        return
      }
      if let cell = tableView.cellForRow(at: indexPath) as? FKCommentCompactRowCell {
        cell.applyLikeState(
          isLiked: item.isLiked,
          likeCount: item.likeCount,
          likeCountText: item.likeCountText
        )
        return
      }
    }
    tableView.reloadRows(at: [indexPath], with: .none)
  }

  private func scrollToComment(id: String, animated: Bool) {
    guard let index = comments.firstIndex(where: { $0.id == id }) else { return }
    let indexPath = IndexPath(row: index, section: 0)
    tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
  }
}

private extension Result {
  var isSuccess: Bool {
    if case .success = self { return true }
    return false
  }
}
