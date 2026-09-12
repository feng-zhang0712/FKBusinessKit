import FKBusinessKit
import UIKit

/// Parameterized ``FKCommentListViewController`` demo covering CommentKit list capabilities.
final class FKCommentKitScenarioExampleViewController: FKCommentListViewController {
  private let scenario: FKCommentKitExampleScenario
  private let store: FKCommentKitExampleMockStore

  init(scenario: FKCommentKitExampleScenario) {
    self.scenario = scenario
    self.store = FKCommentKitExampleMockStore(behavior: Self.behavior(for: scenario))
    super.init(style: .plain)
    commentDataSource = self
    commentDelegate = self
    commentConfiguration = Self.configuration(for: scenario)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = scenario.title
    super.viewDidLoad()
    if scenario == .updateRemoveAPI {
      navigationItem.rightBarButtonItems = [
        UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(handleUpdateFirst)),
        UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(handleRemoveFirst)),
      ]
    }
  }

  // MARK: - Scenario mapping

  private static func behavior(for scenario: FKCommentKitExampleScenario) -> FKCommentKitExampleMockStore.Behavior {
    var behavior = FKCommentKitExampleMockStore.Behavior()
    switch scenario {
    case .emptyState:
      behavior.initialOutcome = .empty
      behavior.seed = .none
    case .loadFailure:
      behavior.initialOutcome = .failure
      behavior.seed = .none
    case .likeRollback:
      behavior.likeShouldRollback = true
    case .submitFailure:
      behavior.submitFails = true
    case .expandableBody:
      behavior.seed = .longBody
      behavior.pageSize = 1
    case .nestedSubReplies:
      behavior.seed = .nestedSubReplies
      behavior.pageSize = 1
      behavior.delay = 0.55
    case .replyToDifferentPeople:
      behavior.seed = .replyTargets
      behavior.pageSize = 1
      behavior.delay = 0.55
    case .layoutPresetCompact, .compactInteractions, .compactMetaComposer:
      behavior.seed = .compact
      behavior.pageSize = 3
      behavior.delay = 0.4
    case .longListStandard:
      behavior.seed = .longListStandard
      behavior.pageSize = 200
      behavior.delay = 0
    case .longListCompact:
      behavior.seed = .longListCompact
      behavior.pageSize = 200
      behavior.delay = 0
    case .pagination:
      behavior.pageSize = 2
      behavior.delay = 0.6
    default:
      break
    }
    return behavior
  }

  private static func configuration(for scenario: FKCommentKitExampleScenario) -> FKCommentKitConfiguration {
    switch scenario {
    case .layoutPresetStandard, .longListStandard:
      return .configuration(for: .standard)
    case .layoutPresetCompact, .compactInteractions, .longListCompact:
      return .configuration(for: .compact)
    case .compactMetaComposer:
      var configuration = FKCommentKitConfiguration.configuration(for: .compact)
      configuration.row.showsMetaReplyButton = true
      configuration.composer.showsSendButton = true
      configuration.composer.showsReplyTargetBanner = true
      configuration.composer.usesCapsuleInput = true
      configuration.strings.composerPlaceholder = "Meta Reply + reply banner + Send…"
      return configuration
    default:
      break
    }

    var configuration = FKCommentKitConfiguration()
    switch scenario {
    case .readOnly:
      configuration.showsComposer = false
    case .hiddenActions:
      configuration.showsLikeAction = false
      configuration.showsReplyAction = false
      configuration.showsMoreAction = false
      configuration.showsCopyAction = false
      configuration.showsReportAction = false
      configuration.beginsReplyOnRowTap = false
    case .expandableBody:
      configuration.row.bodyMaxLines = 3
      configuration.row.usesExpandableBody = true
    case .nestedSubReplies:
      configuration.row.maxDepth = 4
      configuration.row.indentWidth = 16
    case .replyToDifferentPeople:
      configuration.row.maxDepth = 2
      configuration.row.indentWidth = 20
    case .composerLimits:
      configuration.composer.maxCharacterCount = 80
      configuration.composer.maxContentHeight = 72
      configuration.strings.composerPlaceholder = "Max 80 characters…"
    case .customAppearance:
      configuration.strings = FKCommentKitStrings(
        like: "Love",
        unlike: "Unlove",
        reply: "Respond",
        more: "Options",
        copy: "Copy text",
        delete: "Remove",
        report: "Flag",
        send: "Post",
        composerPlaceholder: "Share your thoughts…",
        replyToFormat: "→ %@",
        viewRepliesFormat: "Show %d replies",
        hideReplies: "Collapse",
        cancelReply: "Clear",
        cancel: "Dismiss"
      )
      configuration.actionBar.likedTintColor = .systemPink
      configuration.actionBar.buttonTintColor = .systemIndigo
      configuration.row.avatarSize = .s
      configuration.row.indentWidth = 28
    case .pagination:
      configuration.isPullToRefreshEnabled = true
      configuration.isLoadMoreEnabled = true
    default:
      break
    }
    return configuration
  }

  @objc private func handleUpdateFirst() {
    guard var first = comments.first else {
      showToast("No comments to update")
      return
    }
    first.body = first.body + " [edited]"
    first.timestampText = "Edited"
    updateComment(first)
    showToast("updateComment applied")
  }

  @objc private func handleRemoveFirst() {
    guard let first = comments.first else {
      showToast("No comments to remove")
      return
    }
    removeComment(id: first.id)
    showToast("removeComment(\(first.id))")
  }
}

extension FKCommentKitScenarioExampleViewController: FKCommentListDataSource {
  func commentListLoadInitial(
    completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void
  ) {
    store.loadInitial(completion: completion)
  }

  func commentListLoadMore(
    completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void
  ) {
    store.loadMore(completion: completion)
  }

  func commentListLoadReplies(
    parentId: String,
    completion: @escaping @MainActor (Result<[FKCommentItem], Error>) -> Void
  ) {
    store.loadReplies(parentId: parentId, completion: completion)
  }

  func commentListSubmit(
    _ request: FKCommentSubmitRequest,
    completion: @escaping @MainActor (Result<FKCommentItem, Error>) -> Void
  ) {
    store.submit(request, completion: completion)
  }
}

extension FKCommentKitScenarioExampleViewController: FKCommentListDelegate {
  func commentList(
    _ controller: FKCommentListViewController,
    didToggleLike item: FKCommentItem,
    previousIsLiked: Bool,
    previousLikeCount: Int
  ) {
    guard store.behavior.likeShouldRollback else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
      self?.rollbackLike(
        commentId: item.id,
        previousIsLiked: previousIsLiked,
        previousLikeCount: previousLikeCount
      )
      self?.showToast("Like rolled back for \(item.id)")
    }
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didTapAvatar item: FKCommentItem
  ) {
    showToast("Avatar: \(item.authorName)")
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didTapAuthor item: FKCommentItem
  ) {
    showToast("Author: \(item.authorName)")
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didLongPressComment item: FKCommentItem
  ) {
    showToast("Long press: \(item.id)")
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didSelectMore action: FKCommentMoreAction,
    for item: FKCommentItem
  ) {
    if case .delete = action {
      removeComment(id: item.id)
    }
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didExpandRepliesFor parentId: String,
    inserted: [FKCommentItem],
    error: Error?
  ) {
    if let error {
      showToast("Expand failed: \(error.localizedDescription)")
    }
  }

  func commentList(
    _ controller: FKCommentListViewController,
    didFailSubmit request: FKCommentSubmitRequest,
    error: Error
  ) {
    showToast("Submit failed: \(error.localizedDescription)")
  }
}
