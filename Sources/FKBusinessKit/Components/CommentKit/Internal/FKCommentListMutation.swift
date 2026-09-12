import Foundation

/// Internal helpers for flattening reply insertion under a parent row.
enum FKCommentListMutation {
  /// Inserts `replies` immediately after the parent, replacing any previously expanded children.
  static func insertingReplies(
    _ replies: [FKCommentItem],
    parentId: String,
    into items: [FKCommentItem],
    maxCount: Int
  ) -> [FKCommentItem] {
    guard items.contains(where: { $0.id == parentId }) else {
      return items
    }

    var result = collapsingReplies(parentId: parentId, in: items)
    guard let refreshedParentIndex = result.firstIndex(where: { $0.id == parentId }) else {
      return items
    }

    let parentDepth = result[refreshedParentIndex].depth
    let capped = Array(replies.prefix(maxCount)).map { reply -> FKCommentItem in
      var copy = reply
      copy.parentId = parentId
      copy.depth = max(parentDepth + 1, copy.depth == 0 ? parentDepth + 1 : copy.depth)
      return copy
    }

    result.insert(contentsOf: capped, at: refreshedParentIndex + 1)

    var parent = result[refreshedParentIndex]
    parent.areRepliesExpanded = true
    result[refreshedParentIndex] = parent
    return result
  }

  /// Collapses the contiguous expanded subtree under `parentId` (direct children and descendants).
  static func collapsingReplies(parentId: String, in items: [FKCommentItem]) -> [FKCommentItem] {
    guard let parentIndex = items.firstIndex(where: { $0.id == parentId }) else {
      return items
    }
    var result = items
    let end = endIndexOfSubtree(rootedAt: parentIndex, in: result)
    if end > parentIndex + 1 {
      result.removeSubrange((parentIndex + 1)..<end)
    }
    var parent = result[parentIndex]
    parent.areRepliesExpanded = false
    result[parentIndex] = parent
    return result
  }

  /// Inserts a newly submitted item: top-level at end; replies appear after the target’s subtree.
  static func insertingSubmitted(
    _ item: FKCommentItem,
    into items: [FKCommentItem]
  ) -> [FKCommentItem] {
    if items.contains(where: { $0.id == item.id }) {
      return replacing(item, in: items)
    }

    var result = items
    if let parentId = item.parentId ?? item.replyTo?.id,
       let parentIndex = result.firstIndex(where: { $0.id == parentId }) {
      var copy = item
      copy.parentId = parentId
      let parentDepth = result[parentIndex].depth
      copy.depth = max(parentDepth + 1, copy.depth)
      let insertAt = endIndexOfSubtree(rootedAt: parentIndex, in: result)
      result.insert(copy, at: insertAt)

      var parent = result[parentIndex]
      parent.replyCount += 1
      parent.areRepliesExpanded = true
      result[parentIndex] = parent
      return result
    }

    var topLevel = item
    topLevel.depth = 0
    topLevel.parentId = nil
    result.append(topLevel)
    return result
  }

  /// Replaces the item with a matching `id`, if present.
  static func replacing(_ item: FKCommentItem, in items: [FKCommentItem]) -> [FKCommentItem] {
    items.map { $0.id == item.id ? item : $0 }
  }

  /// Removes a comment and its contiguous descendant subtree.
  static func removing(id: String, from items: [FKCommentItem]) -> [FKCommentItem] {
    guard let removedIndex = items.firstIndex(where: { $0.id == id }) else { return items }
    let removed = items[removedIndex]
    var result = items
    let end = endIndexOfSubtree(rootedAt: removedIndex, in: result)
    result.removeSubrange(removedIndex..<end)
    if let parentId = removed.parentId,
       let parentIndex = result.firstIndex(where: { $0.id == parentId }) {
      var parent = result[parentIndex]
      parent.replyCount = max(0, parent.replyCount - 1)
      if !result.contains(where: { $0.parentId == parentId }) {
        parent.areRepliesExpanded = false
      }
      result[parentIndex] = parent
    }
    return result
  }

  /// Appends page items while skipping ids already present.
  static func appendingUnique(_ pageItems: [FKCommentItem], onto items: [FKCommentItem]) -> [FKCommentItem] {
    let existing = Set(items.map(\.id))
    return items + pageItems.filter { !existing.contains($0.id) }
  }

  /// Exclusive end index of the contiguous display subtree rooted at `rootIndex`.
  static func endIndexOfSubtree(rootedAt rootIndex: Int, in items: [FKCommentItem]) -> Int {
    guard items.indices.contains(rootIndex) else { return rootIndex }
    var subtreeIds: Set<String> = [items[rootIndex].id]
    var index = rootIndex + 1
    while index < items.count {
      guard let parentId = items[index].parentId, subtreeIds.contains(parentId) else {
        break
      }
      subtreeIds.insert(items[index].id)
      index += 1
    }
    return index
  }
}
