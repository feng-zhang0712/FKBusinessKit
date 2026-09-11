import Foundation
import FKBusinessKit

/// Configurable in-memory backend for CommentKit demos.
@MainActor
final class FKCommentKitExampleMockStore {
  struct Behavior {
    var initialOutcome: Outcome = .success
    var submitFails: Bool = false
    var likeShouldRollback: Bool = false
    var pageSize: Int = 4
    var delay: TimeInterval = 0.45
    var seed: Seed = .standard

    enum Outcome {
      case success
      case empty
      case failure
    }

    enum Seed {
      case standard
      case longBody
      case nestedSubReplies
      case replyTargets
      case compact
      case longListStandard
      case longListCompact
      case none
    }
  }

  var behavior: Behavior
  private var topLevel: [FKCommentItem] = []
  private var repliesByParentId: [String: [FKCommentItem]] = [:]
  private var nextPageIndex: Int = 1
  private var submitCounter: Int = 0

  init(behavior: Behavior = .init()) {
    self.behavior = behavior
    resetSeed()
  }

  func resetSeed() {
    nextPageIndex = 1
    submitCounter = 0
    switch behavior.seed {
    case .standard:
      topLevel = FKCommentKitExampleSampleData.topLevelPage1
      repliesByParentId = FKCommentKitExampleSampleData.repliesByParentId
    case .longBody:
      topLevel = FKCommentKitExampleSampleData.longBodyOnly
      repliesByParentId = [:]
    case .nestedSubReplies:
      topLevel = FKCommentKitExampleSampleData.nestedSubRepliesTopLevel
      repliesByParentId = FKCommentKitExampleSampleData.nestedSubRepliesByParentId
    case .replyTargets:
      topLevel = FKCommentKitExampleSampleData.replyTargetsTopLevel
      repliesByParentId = FKCommentKitExampleSampleData.replyTargetsByParentId
    case .compact:
      topLevel = FKCommentKitExampleSampleData.compactTopLevel
      repliesByParentId = FKCommentKitExampleSampleData.compactRepliesByParentId
    case .longListStandard:
      topLevel = FKCommentKitExampleSampleData.makeLongScrollList(count: 200, compactStyle: false)
      repliesByParentId = [:]
    case .longListCompact:
      topLevel = FKCommentKitExampleSampleData.makeLongScrollList(count: 200, compactStyle: true)
      repliesByParentId = [:]
    case .none:
      topLevel = []
      repliesByParentId = [:]
    }
  }

  func loadInitial(completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void) {
    run(delay: behavior.delay) { [weak self] in
      guard let self else { return }
      self.resetSeed()
      switch self.behavior.initialOutcome {
      case .success:
        let page = Array(self.topLevel.prefix(self.behavior.pageSize))
        let hasMoreInSeed: Bool
        switch self.behavior.seed {
        case .standard:
          hasMoreInSeed = self.topLevel.count > page.count
            || !FKCommentKitExampleSampleData.topLevelPage2.isEmpty
        case .longListStandard, .longListCompact:
          hasMoreInSeed = self.topLevel.count > page.count
        default:
          hasMoreInSeed = false
        }
        self.nextPageIndex = 1
        completion(.success(FKCommentListPage(items: page, hasMore: hasMoreInSeed)))
      case .empty:
        completion(.success(FKCommentListPage(items: [], hasMore: false)))
      case .failure:
        completion(.failure(FKCommentKitExampleMockError.loadFailed))
      }
    }
  }

  func loadMore(completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void) {
    run(delay: behavior.delay) { [weak self] in
      guard let self else { return }
      switch self.behavior.seed {
      case .longListStandard, .longListCompact:
        let start = self.behavior.pageSize * self.nextPageIndex
        guard start < self.topLevel.count else {
          completion(.success(FKCommentListPage(items: [], hasMore: false)))
          return
        }
        let end = min(self.topLevel.count, start + self.behavior.pageSize)
        let page = Array(self.topLevel[start..<end])
        self.nextPageIndex += 1
        let hasMore = end < self.topLevel.count
        completion(.success(FKCommentListPage(items: page, hasMore: hasMore)))
        return
      case .standard:
        break
      default:
        completion(.success(FKCommentListPage(items: [], hasMore: false)))
        return
      }

      // Remaining items from page 1 when pageSize < full seed.
      if self.topLevel.count > self.behavior.pageSize, self.nextPageIndex == 1 {
        let remaining = Array(self.topLevel.dropFirst(self.behavior.pageSize))
        self.nextPageIndex = 2
        let hasMore = !FKCommentKitExampleSampleData.topLevelPage2.isEmpty
        completion(.success(FKCommentListPage(items: remaining, hasMore: hasMore)))
        return
      }

      if self.nextPageIndex >= 3 {
        completion(.success(FKCommentListPage(items: [], hasMore: false)))
        return
      }

      self.nextPageIndex = 3
      let page = FKCommentKitExampleSampleData.topLevelPage2
      let existing = Set(self.topLevel.map(\.id))
      let unique = page.filter { !existing.contains($0.id) }
      self.topLevel.append(contentsOf: unique)
      completion(.success(FKCommentListPage(items: unique, hasMore: false)))
    }
  }

  func loadReplies(
    parentId: String,
    completion: @escaping @MainActor (Result<[FKCommentItem], Error>) -> Void
  ) {
    run(delay: behavior.delay) { [weak self] in
      guard let self else { return }
      let replies = self.repliesByParentId[parentId] ?? []
      completion(.success(replies))
    }
  }

  func submit(
    _ request: FKCommentSubmitRequest,
    completion: @escaping @MainActor (Result<FKCommentItem, Error>) -> Void
  ) {
    run(delay: behavior.delay) { [weak self] in
      guard let self else { return }
      if self.behavior.submitFails {
        completion(.failure(FKCommentKitExampleMockError.submitFailed))
        return
      }
      self.submitCounter += 1
      let id = "local.\(self.submitCounter)"
      let replyToCommentId = request.replyToCommentId
      let resolvedParent = replyToCommentId.flatMap { self.findComment(id: $0) }
      let replyTo = resolvedParent.map {
        FKCommentReplyTarget(id: $0.id, displayName: $0.authorName)
      }
      // Flat thread root for storage: nest under the tapped comment id.
      let parentId = replyToCommentId
      let depth: Int
      if let resolvedParent {
        depth = resolvedParent.depth + 1
      } else {
        depth = 0
      }
      let item = FKCommentItem(
        id: id,
        authorName: "You",
        avatarURL: FKCommentKitExampleSampleData.remoteImageURL(id: 100),
        body: request.text,
        timestampText: "Just now",
        likeCount: 0,
        parentId: parentId,
        replyTo: replyTo,
        depth: depth,
        isOwnedByCurrentUser: true,
        isDeletable: true
      )
      if let parentId {
        var replies = self.repliesByParentId[parentId] ?? []
        replies.append(item)
        self.repliesByParentId[parentId] = replies
        self.bumpReplyCount(for: parentId)
      } else {
        self.topLevel.append(item)
      }
      completion(.success(item))
    }
  }

  private func findComment(id: String) -> FKCommentItem? {
    if let top = topLevel.first(where: { $0.id == id }) {
      return top
    }
    for replies in repliesByParentId.values {
      if let match = replies.first(where: { $0.id == id }) {
        return match
      }
    }
    return nil
  }

  private func bumpReplyCount(for id: String) {
    if let index = topLevel.firstIndex(where: { $0.id == id }) {
      var parent = topLevel[index]
      parent.replyCount += 1
      topLevel[index] = parent
      return
    }
    for key in repliesByParentId.keys {
      guard var replies = repliesByParentId[key],
            let index = replies.firstIndex(where: { $0.id == id }) else { continue }
      var parent = replies[index]
      parent.replyCount += 1
      replies[index] = parent
      repliesByParentId[key] = replies
      return
    }
  }

  private func run(delay: TimeInterval, work: @escaping @MainActor () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
  }
}

enum FKCommentKitExampleMockError: LocalizedError {
  case loadFailed
  case submitFailed

  var errorDescription: String? {
    switch self {
    case .loadFailed:
      return "Mock load failure"
    case .submitFailed:
      return "Mock submit failure"
    }
  }
}
