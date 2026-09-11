import Foundation
import FKBusinessKit

/// Static sample comments and replies for CommentKit demos.
enum FKCommentKitExampleSampleData {
  static func remoteImageURL(id: Int, width: Int = 80, height: Int = 80) -> URL {
    URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")!
  }

  /// Top-level page 1.
  static var topLevelPage1: [FKCommentItem] {
    [
      FKCommentItem(
        id: "c1",
        authorName: "Alex Chen",
        avatarURL: remoteImageURL(id: 11),
        body: "Great write-up. The flat replyTo model feels closer to how most content apps actually ship comments.",
        timestampText: "2h",
        likeCount: 12,
        isLiked: false,
        replyCount: 3,
        isVerified: true
      ),
      FKCommentItem(
        id: "c2",
        authorName: "Jordan Lee",
        avatarURL: remoteImageURL(id: 22),
        body: String(repeating: "This body is intentionally long so expandable text can be exercised. ", count: 8),
        timestampText: "5h",
        likeCount: 4,
        isLiked: true,
        replyCount: 1,
        isOwnedByCurrentUser: true,
        isDeletable: true
      ),
      FKCommentItem(
        id: "c3",
        authorName: "Sam Rivera",
        avatarURL: remoteImageURL(id: 33),
        body: "Short note.",
        timestampText: "1d",
        likeCount: 0,
        replyCount: 0
      ),
      FKCommentItem(
        id: "c4",
        authorName: "Taylor Kim",
        avatarURL: remoteImageURL(id: 44),
        body: "Could we also cover keyboard avoidance with the composer?",
        timestampText: "2d",
        likeCount: 7,
        replyCount: 2,
        isVerified: true
      ),
    ]
  }

  /// Top-level page 2 (load-more).
  static var topLevelPage2: [FKCommentItem] {
    [
      FKCommentItem(
        id: "c5",
        authorName: "Morgan Blake",
        avatarURL: remoteImageURL(id: 55),
        body: "Page 2 comment loaded via load-more.",
        timestampText: "3d",
        likeCount: 1,
        replyCount: 0
      ),
      FKCommentItem(
        id: "c6",
        authorName: "Casey Quinn",
        avatarURL: remoteImageURL(id: 66),
        body: "Another page-2 row to exercise pagination.",
        timestampText: "4d",
        likeCount: 0,
        replyCount: 0
      ),
    ]
  }

  /// Replies keyed by parent id.
  static var repliesByParentId: [String: [FKCommentItem]] {
    [
      "c1": [
        FKCommentItem(
          id: "c1.r1",
          authorName: "Riley Ng",
          avatarURL: remoteImageURL(id: 71),
          body: "Agreed — especially for news and social feeds.",
          timestampText: "1h",
          likeCount: 2,
          parentId: "c1",
          replyTo: FKCommentReplyTarget(id: "c1", displayName: "Alex Chen"),
          depth: 1
        ),
        FKCommentItem(
          id: "c1.r2",
          authorName: "Alex Chen",
          avatarURL: remoteImageURL(id: 11),
          body: "Exactly. Nested trees get expensive fast.",
          timestampText: "50m",
          likeCount: 5,
          isLiked: true,
          parentId: "c1",
          replyTo: FKCommentReplyTarget(id: "c1.r1", displayName: "Riley Ng"),
          depth: 1,
          isVerified: true,
          isOwnedByCurrentUser: true,
          isDeletable: true
        ),
        FKCommentItem(
          id: "c1.r3",
          authorName: "Jamie Ortiz",
          avatarURL: remoteImageURL(id: 72),
          body: "Thanks for the pointer to CommentKit.",
          timestampText: "40m",
          parentId: "c1",
          replyTo: FKCommentReplyTarget(id: "c1", displayName: "Alex Chen"),
          depth: 1
        ),
      ],
      "c2": [
        FKCommentItem(
          id: "c2.r1",
          authorName: "Pat Singh",
          avatarURL: remoteImageURL(id: 73),
          body: "Expandable body works well here.",
          timestampText: "3h",
          parentId: "c2",
          replyTo: FKCommentReplyTarget(id: "c2", displayName: "Jordan Lee"),
          depth: 1
        ),
      ],
      "c4": [
        FKCommentItem(
          id: "c4.r1",
          authorName: "Dev Support",
          avatarURL: remoteImageURL(id: 74),
          body: "Composer pins above keyboardLayoutGuide in the list VC.",
          timestampText: "1d",
          parentId: "c4",
          replyTo: FKCommentReplyTarget(id: "c4", displayName: "Taylor Kim"),
          depth: 1,
          isVerified: true
        ),
        FKCommentItem(
          id: "c4.r2",
          authorName: "Taylor Kim",
          avatarURL: remoteImageURL(id: 44),
          body: "Perfect, thanks!",
          timestampText: "1d",
          parentId: "c4",
          replyTo: FKCommentReplyTarget(id: "c4.r1", displayName: "Dev Support"),
          depth: 1
        ),
      ],
    ]
  }

  static var longBodyOnly: [FKCommentItem] {
    [
      FKCommentItem(
        id: "long.1",
        authorName: "Expandable Demo",
        avatarURL: remoteImageURL(id: 88),
        body: String(
          repeating: "Tap Read More to expand this paragraph. CommentKit uses FKExpandableText when usesExpandableBody is enabled. ",
          count: 10
        ),
        timestampText: "Now",
        likeCount: 3,
        replyCount: 0
      ),
    ]
  }

  /// One root thread with a deep expandable chain (floors 1…5) plus a shallow sibling.
  static var nestedSubRepliesTopLevel: [FKCommentItem] {
    [
      FKCommentItem(
        id: "n1",
        authorName: "Alex Chen",
        avatarURL: remoteImageURL(id: 11),
        body: "Expand each “View replies” in order. Indent grows until maxDepth; deeper floors still nest via expand + replyTo.",
        timestampText: "1h",
        likeCount: 9,
        replyCount: 2,
        isVerified: true
      ),
    ]
  }

  /// Nested reply maps: one deep chain (5 floors) and one shallow sibling under the root.
  static var nestedSubRepliesByParentId: [String: [FKCommentItem]] {
    [
      "n1": [
        FKCommentItem(
          id: "n1.f1",
          authorName: "Riley Ng",
          avatarURL: remoteImageURL(id: 71),
          body: "Floor 1 — expand again for floor 2.",
          timestampText: "50m",
          likeCount: 3,
          replyCount: 1,
          parentId: "n1",
          replyTo: FKCommentReplyTarget(id: "n1", displayName: "Alex Chen"),
          depth: 1
        ),
        FKCommentItem(
          id: "n1.side",
          authorName: "Sam Rivera",
          avatarURL: remoteImageURL(id: 33),
          body: "Floor 1 sibling — no further nesting on this branch.",
          timestampText: "48m",
          replyCount: 0,
          parentId: "n1",
          replyTo: FKCommentReplyTarget(id: "n1", displayName: "Alex Chen"),
          depth: 1
        ),
      ],
      "n1.f1": [
        FKCommentItem(
          id: "n1.f2",
          authorName: "Jordan Lee",
          avatarURL: remoteImageURL(id: 22),
          body: "Floor 2 — keep expanding.",
          timestampText: "45m",
          likeCount: 1,
          replyCount: 1,
          parentId: "n1.f1",
          replyTo: FKCommentReplyTarget(id: "n1.f1", displayName: "Riley Ng"),
          depth: 2
        ),
      ],
      "n1.f2": [
        FKCommentItem(
          id: "n1.f3",
          authorName: "Jamie Ortiz",
          avatarURL: remoteImageURL(id: 72),
          body: "Floor 3 — still expandable.",
          timestampText: "40m",
          replyCount: 1,
          parentId: "n1.f2",
          replyTo: FKCommentReplyTarget(id: "n1.f2", displayName: "Jordan Lee"),
          depth: 3
        ),
      ],
      "n1.f3": [
        FKCommentItem(
          id: "n1.f4",
          authorName: "Pat Singh",
          avatarURL: remoteImageURL(id: 73),
          body: "Floor 4 — one more level below.",
          timestampText: "35m",
          likeCount: 2,
          replyCount: 1,
          parentId: "n1.f3",
          replyTo: FKCommentReplyTarget(id: "n1.f3", displayName: "Jamie Ortiz"),
          depth: 4
        ),
      ],
      "n1.f4": [
        FKCommentItem(
          id: "n1.f5",
          authorName: "Alex Chen",
          avatarURL: remoteImageURL(id: 11),
          body: "Floor 5 — leaf. Visual indent is capped by maxDepth (demo uses 4); replyTo still names floor 4.",
          timestampText: "30m",
          likeCount: 4,
          isLiked: true,
          replyCount: 0,
          parentId: "n1.f4",
          replyTo: FKCommentReplyTarget(id: "n1.f4", displayName: "Pat Singh"),
          depth: 5,
          isVerified: true,
          isOwnedByCurrentUser: true,
          isDeletable: true
        ),
      ],
    ]
  }

  /// Thread focused on reply-to chrome: parent, sibling, and deeper floors.
  static var replyTargetsTopLevel: [FKCommentItem] {
    [
      FKCommentItem(
        id: "t1",
        authorName: "Taylor Kim",
        avatarURL: remoteImageURL(id: 44),
        body: "Tap Reply on different rows — composer banner should name that author. Includes replies back to this parent from deeper floors.",
        timestampText: "3h",
        likeCount: 5,
        replyCount: 4,
        isVerified: true
      ),
    ]
  }

  static var replyTargetsByParentId: [String: [FKCommentItem]] {
    [
      "t1": [
        FKCommentItem(
          id: "t1.r1",
          authorName: "Dev Support",
          avatarURL: remoteImageURL(id: 74),
          body: "Replying to the parent (Taylor).",
          timestampText: "2h",
          likeCount: 1,
          replyCount: 2,
          parentId: "t1",
          replyTo: FKCommentReplyTarget(id: "t1", displayName: "Taylor Kim"),
          depth: 1,
          isVerified: true
        ),
        FKCommentItem(
          id: "t1.r2",
          authorName: "Morgan Blake",
          avatarURL: remoteImageURL(id: 55),
          body: "Also replying to the parent — same floor, different author.",
          timestampText: "90m",
          parentId: "t1",
          replyTo: FKCommentReplyTarget(id: "t1", displayName: "Taylor Kim"),
          depth: 1
        ),
        FKCommentItem(
          id: "t1.r3",
          authorName: "Casey Quinn",
          avatarURL: remoteImageURL(id: 66),
          body: "Replying to Dev Support (sibling floor), not the root.",
          timestampText: "80m",
          parentId: "t1",
          replyTo: FKCommentReplyTarget(id: "t1.r1", displayName: "Dev Support"),
          depth: 1
        ),
        FKCommentItem(
          id: "t1.r4",
          authorName: "You",
          avatarURL: remoteImageURL(id: 100),
          body: "Owned row — try Reply here, or expand Dev Support for deeper reply-to-parent samples.",
          timestampText: "70m",
          parentId: "t1",
          replyTo: FKCommentReplyTarget(id: "t1.r2", displayName: "Morgan Blake"),
          depth: 1,
          isOwnedByCurrentUser: true,
          isDeletable: true
        ),
      ],
      "t1.r1": [
        FKCommentItem(
          id: "t1.r1.a",
          authorName: "Jordan Lee",
          avatarURL: remoteImageURL(id: 22),
          body: "Deeper floor — replyTo is Dev Support.",
          timestampText: "60m",
          parentId: "t1.r1",
          replyTo: FKCommentReplyTarget(id: "t1.r1", displayName: "Dev Support"),
          depth: 2
        ),
        FKCommentItem(
          id: "t1.r1.b",
          authorName: "Alex Chen",
          avatarURL: remoteImageURL(id: 11),
          body: "Deeper floor — replyTo jumps back to the root parent Taylor.",
          timestampText: "55m",
          likeCount: 4,
          parentId: "t1.r1",
          replyTo: FKCommentReplyTarget(id: "t1", displayName: "Taylor Kim"),
          depth: 2,
          isVerified: true
        ),
      ],
    ]
  }

  /// Compact-preset sample: meta timestamp, large like counts, reply-to in author line.
  static var compactTopLevel: [FKCommentItem] {
    [
      FKCommentItem(
        id: "sv1",
        authorName: "Ming Xiao",
        avatarURL: remoteImageURL(id: 11),
        body: "Looks delicious — where is this place?",
        timestampText: "12h ago",
        likeCount: 14_000,
        likeCountText: "14k",
        replyCount: 3,
        isVerified: true
      ),
      FKCommentItem(
        id: "sv2",
        authorName: "Travel Notes",
        avatarURL: remoteImageURL(id: 22),
        body: "Went last weekend. Queue was long but worth it 🔥",
        timestampText: "8h ago",
        likeCount: 860,
        likeCountText: "860",
        isLiked: true,
        replyCount: 1
      ),
      FKCommentItem(
        id: "sv3",
        authorName: "Local Guide",
        avatarURL: remoteImageURL(id: 33),
        body: "Try the slow-cooked beef set. Ask for less salt.",
        timestampText: "3h ago",
        likeCount: 42,
        replyCount: 0,
        isOwnedByCurrentUser: true,
        isDeletable: true
      ),
    ]
  }

  static var compactRepliesByParentId: [String: [FKCommentItem]] {
    [
      "sv1": [
        FKCommentItem(
          id: "sv1.r1",
          authorName: "Foodie Lin",
          avatarURL: remoteImageURL(id: 71),
          body: "Same street as the night market — look for the red sign.",
          timestampText: "10h ago",
          likeCount: 210,
          likeCountText: "210",
          parentId: "sv1",
          replyTo: FKCommentReplyTarget(id: "sv1", displayName: "Ming Xiao"),
          depth: 1
        ),
        FKCommentItem(
          id: "sv1.r2",
          authorName: "Ming Xiao",
          avatarURL: remoteImageURL(id: 11),
          body: "Got it, thanks!",
          timestampText: "9h ago",
          likeCount: 18,
          parentId: "sv1",
          replyTo: FKCommentReplyTarget(id: "sv1.r1", displayName: "Foodie Lin"),
          depth: 1,
          isVerified: true
        ),
        FKCommentItem(
          id: "sv1.r3",
          authorName: "Weekend Trip",
          avatarURL: remoteImageURL(id: 72),
          body: "Saving this for next month.",
          timestampText: "6h ago",
          likeCount: 5,
          parentId: "sv1",
          replyTo: FKCommentReplyTarget(id: "sv1", displayName: "Ming Xiao"),
          depth: 1
        ),
      ],
      "sv2": [
        FKCommentItem(
          id: "sv2.r1",
          authorName: "Sam Rivera",
          avatarURL: remoteImageURL(id: 33),
          body: "How long was the wait?",
          timestampText: "7h ago",
          likeCount: 3,
          parentId: "sv2",
          replyTo: FKCommentReplyTarget(id: "sv2", displayName: "Travel Notes"),
          depth: 1
        ),
      ],
    ]
  }

  /// Large top-level list for scroll performance checks (Standard / Compact).
  static func makeLongScrollList(count: Int = 200, compactStyle: Bool) -> [FKCommentItem] {
    let names = [
      "Alex Chen", "Jordan Lee", "Sam Rivera", "Taylor Kim", "Morgan Blake",
      "Casey Quinn", "Ming Xiao", "Travel Notes", "Local Guide", "Riley Ng",
    ]
    let shortBodies = [
      "Short note.",
      "Looks good to me.",
      "Thanks for sharing.",
      "Agreed.",
      "Nice catch.",
    ]
    let mediumBodies = [
      "The flat replyTo model feels closer to how most content apps ship comments.",
      "Could we also cover keyboard avoidance with the composer?",
      "Went last weekend. Queue was long but worth it.",
      "Try the slow-cooked beef set. Ask for less salt.",
    ]
    let longFragment = "This body is intentionally long so expandable text and scroll cost can be exercised. "
    return (0..<count).map { index in
      let id = compactStyle ? "long.sv.\(index)" : "long.c.\(index)"
      let name = names[index % names.count]
      let body: String
      switch index % 5 {
      case 0:
        body = shortBodies[index % shortBodies.count]
      case 1, 2:
        body = mediumBodies[index % mediumBodies.count]
      default:
        body = String(repeating: longFragment, count: 2 + (index % 4))
      }
      let likes = (index * 17) % 1400
      let likeText: String? = compactStyle && likes >= 1000
        ? String(format: "%.1fk", locale: Locale(identifier: "en_US_POSIX"), Double(likes) / 1000)
        : nil
      return FKCommentItem(
        id: id,
        authorName: name,
        avatarURL: remoteImageURL(id: 10 + (index % 90)),
        body: body,
        timestampText: compactStyle ? "\(1 + index % 20)h ago" : "\(1 + index % 48)h",
        likeCount: likes,
        likeCountText: likeText,
        isLiked: index % 7 == 0,
        replyCount: index % 11 == 0 ? (1 + index % 4) : 0,
        isVerified: index % 9 == 0,
        isOwnedByCurrentUser: index % 23 == 0,
        isDeletable: index % 23 == 0
      )
    }
  }
}
