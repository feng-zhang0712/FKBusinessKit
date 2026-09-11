# CommentKit (`FKCommentKit`)

Reusable **comment UI kit** for FKBusinessKit: flat `replyTo` threads, like / reply / more actions, composer, and protocol-injected data — **no networking**.

Design guide: [`docs/FKCommentKit_DESIGN.md`](../../../../docs/FKCommentKit_DESIGN.md)  
Layout extension rule: **presets for skeletons, configuration for tokens** — see design guide §7.

## Directory map

```text
Components/CommentKit/
├── README.md
├── Public/
│   ├── Models/           # FKCommentItem, pages, submit request, more actions
│   ├── Protocols/        # FKCommentListDataSource / Delegate
│   ├── Configuration/    # Appearance, feature flags, English strings
│   ├── Presets/          # Layout skeletons (standard + compact, …)
│   │   ├── FKCommentLayoutPreset.swift
│   │   └── Compact/   # Row cell, action rail, defaults
│   ├── Views/            # Action bar, composer, standard row cell
│   ├── Controller/       # FKCommentListViewController
│   └── Core/             # Optimistic like helper, ListKit registration
└── Internal/             # Flat-list mutation helpers
```

## Layout presets

| Preset | Skeleton |
|--------|----------|
| ``FKCommentLayoutPreset/standard`` | Avatar, author + timestamp header, body, bottom like / reply / more strip |
| ``FKCommentLayoutPreset/compact`` | Author → body → meta (like · Reply · more · time), capsule composer |

```swift
commentConfiguration = .configuration(for: .compact)
// or
commentConfiguration.layoutPreset = .compact
commentConfiguration = FKCommentCompactDefaults.makeConfiguration()
```

## Quick start

```swift
import FKBusinessKit

final class HostCommentsViewController: FKCommentListViewController {
  override func viewDidLoad() {
    commentDataSource = self
    commentDelegate = self
    commentConfiguration = .configuration(for: .compact) // or .standard
    super.viewDidLoad()
  }
}

extension HostCommentsViewController: FKCommentListDataSource {
  func commentListLoadInitial(completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void) {
    // Map API → FKCommentItem, then completion(.success(...))
  }

  func commentListLoadMore(completion: @escaping @MainActor (Result<FKCommentListPage, Error>) -> Void) {
    completion(.success(FKCommentListPage(items: [], hasMore: false)))
  }

  func commentListLoadReplies(
    parentId: String,
    completion: @escaping @MainActor (Result<[FKCommentItem], Error>) -> Void
  ) {
    completion(.success([]))
  }

  func commentListSubmit(
    _ request: FKCommentSubmitRequest,
    completion: @escaping @MainActor (Result<FKCommentItem, Error>) -> Void
  ) {
    // POST then completion(.success(createdItem))
  }
}
```

## Notes

- Prefer **CommentKit** when you need actions + composer. Keep CellKit ``FKCommentThreadCell`` for display-only threads.
- ``FKCommentRowCell`` is the ``standard`` skeleton; ``FKCommentCompactRowCell`` is the ``compact`` skeleton. Do not encode a different skeleton only with configuration flags.
- Action icons load from ``FKBusinessKitIcons`` / ``Assets.xcassets`` — not SF Symbols.
- Do **not** merge with ``FKReviewListCell`` (product reviews).
- After delete succeeds, call ``FKCommentListViewController/removeComment(id:)``.
- Read-only lists: set ``FKCommentKitConfiguration/showsComposer`` to `false`.
- Row tap to reply: ``FKCommentKitConfiguration/beginsReplyOnRowTap`` (default `true`); disable when only the Reply button should start a reply.
- Nested “View N replies” works on any row with ``FKCommentItem/replyCount`` (flat list + ``replyTo``); collapse removes the contiguous subtree.
- Visual indent uses ``min(depth, maxDepth) × indentWidth`` — deeper logical floors still expand, but UI indent stops growing after ``FKCommentRowCellConfiguration/maxDepth`` (default `1`).
- Optional ``FKCommentItem/likeCountText`` feeds compact like chrome when provided.
- Compact meta stripe (leading like · reply · more, trailing timestamp): ``FKCommentRowCellConfiguration/showsMetaStripe``, ``showsTimestamp``, ``showsMetaReplyButton``; action visibility via ``FKCommentKitConfiguration/showsLikeAction`` / ``showsReplyAction`` / ``showsMoreAction``.
- Compact action icons: catalog ``FKBusinessKitIcon`` defaults, or override with ``FKCommentActionBarConfiguration/likeImage`` / ``likedImage`` / ``replyImage`` / ``moreImage`` (SVG/PNG/`UIImage`).
- Compact reply title: ``FKCommentActionBarConfiguration/showsReplyTitle`` + ``FKCommentKitStrings/reply``; like count via ``showsLikeCount``.
- More menu: built-in sheet by default (`showsCopyAction` / `showsReportAction` / deletable). Set ``presentsDefaultMoreMenu`` to `false` and implement ``didTapMore`` for a fully custom menu; or append ``additionalMoreActions`` / ``additionalMoreActionsProvider`` and handle ``didSelectCustomMoreAction``.
- Localization: replace ``FKCommentKitConfiguration/strings`` (`FKCommentKitStrings`) — includes like/reply/more/composer/expand-body copy. Defaults are English; CommentKit does not ship `.lproj` tables.
- Compact composer chrome: ``FKCommentComposerConfiguration`` (`usesCapsuleInput`, `showsSendButton`, `showsReplyTargetBanner`, capsule colors, …). Send stays disabled until the input has non-empty trimmed text.
- **Theming tokens** (both presets): row text styles / optional font weights / colors, content insets, section & inline spacings, action-bar icons + tints, expand / reply-to chevron icons, composer text colors & spacings — see ``FKCommentRowCellConfiguration``, ``FKCommentActionBarConfiguration``, ``FKCommentComposerConfiguration``.
- Public row callbacks: avatar, author, comment body, like, reply, more, long-press (via ``FKCommentListDelegate`` / cell `on*` handlers).
- Examples: `Examples/.../CommentKit/` — **Layout presets** lists each preset; tap a preset for its demo group.
- Unit tests are deferred for a follow-up delivery.
