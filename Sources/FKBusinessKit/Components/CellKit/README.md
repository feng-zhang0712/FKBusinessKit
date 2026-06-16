# CellKit (`FKCellKit`)

Business composite **UITableViewCell** / **UICollectionViewCell** templates built on **FKBusinessKit Base**, **FKUIKit Widgets**, and **ListKit** custom-cell registration.

## Directory map

```text
Components/CellKit/
├── README.md
├── Public/
│   ├── Core/           # Defaults, ListKit registration, skeleton layout, visibility forwarder
│   ├── Bridge/         # SwiftUI representables (CellKit + ListKit)
│   ├── Configuration/  # Appearance tokens
│   ├── Models/         # Sendable Item payloads + display models
│   ├── RowParts/       # Reusable leading/trailing composites
│   ├── Table/          # Content + skeleton table cells
│   └── Collection/     # Content + skeleton collection cells
```

## Quick start (ListKit)

```swift
import FKBusinessKit

final class ContactsViewController: FKDiffableTableViewController {
  override func viewDidLoad() {
    FKCellKitListRegistration.registerAllTableCells(on: self)
    super.viewDidLoad()
  }

  func apply(users: [FKUserListItem]) {
    FKCellKitListItemFactory.storeUserListPayloads(users, on: self)
    applySnapshot(FKListSnapshot(items: users.map(FKCellKitListItemFactory.userList)))
  }
}
```

## Visibility forwarding

```swift
extension ContactsViewController: FKListDelegate {
  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
  }
}
```

## Skeleton placeholders (Base table)

```swift
tableView.register(FKCellKitUserListSkeletonTableCell.self, forCellReuseIdentifier: FKCellKitUserListSkeletonTableCell.reuseIdentifier)
// In cellForRow when loading:
FKCellKitSkeletonLayout.applyUserListRow(to: cell)
```

## Dynamic feed heights

Use ``FKFeedContentCellHeightEstimator`` with ListKit ``FKListHeightCache``:

```swift
tableView.rowHeight = UITableView.automaticDimension
listConfiguration.estimatedRowHeightProvider = { [weak self] item, width in
  guard let self,
        let post = self.payload(for: item.id)?.unwrap(FKFeedContentItem.self) else { return 160 }
  return FKFeedContentCellHeightEstimator.estimatedRowHeight(for: post, width: width, cache: self.heightCache)
}
```

## Video feed autoplay

Attach ListKit ``FKListVideoVisibilityCoordinator`` and forward visibility with a shared ``FKVideoPlayerPool``:

```swift
final class VideoFeedViewController: FKDiffableTableViewController {
  private let playerPool = FKVideoPlayerPool(maxPlayers: 2)

  override func viewDidLoad() {
    FKCellKitListRegistration.registerFeedVideoCell(on: self)
    _ = FKCellKitVideoSetup.attachVideoVisibility(to: self, pool: playerPool)
    super.viewDidLoad()
  }
}

extension VideoFeedViewController: FKListDelegate {
  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVideoVisibilityWillDisplay(at: indexPath, pool: playerPool)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVideoVisibilityDidEndDisplaying(at: indexPath, pool: playerPool)
  }
}
```

For standalone SwiftUI playback, use FKUIKit ``FKVideoPlayerSwiftUIView`` — CellKit v1 ships UIKit cells only.

## Interactive custom rows

Register value handlers on ``FKDiffableTableViewController/cellKitValueHandlers`` for quantity, rating, chip selection, and invite share cells. Use ``FKListSwitchHandlerRegistry`` for ``FKInlineToggleCell`` (same as ListKit preset switches).

Build timeline list rows with ``FKTimelineEventItem/makeList(from:)`` instead of hand-computing connector flags.

```swift
cellKitValueHandlers.registerQuantity(id: "cart.quantity") { itemID, quantity in
  // update view model, then reconfigureItems
}
cellKitValueHandlers.registerShare(id: "invite.share") { itemID in
  // present share sheet
}
switchHandlerRegistry.register(id: "contact.mute") { itemID, isOn in
  // update view model, then reconfigureItems
}
let events = FKTimelineEventItem.makeList(from: flowSteps)
```

## SwiftUI bridge

Embed a ListKit diffable controller with all CellKit cells pre-registered:

```swift
import SwiftUI
import FKBusinessKit

struct CommentFeedView: View {
  var body: some View {
    FKCellKitDiffableTableViewRepresentable(
      configuration: FKListDefaults.feedConfiguration
    )
  }
}
```

Subclass ``FKCellKitDiffableTableViewController`` when you need custom ListKit delegate logic in UIKit.

## Public cells

| Cell | Item | Use case |
|------|------|----------|
| `FKUserListCell` | `FKUserListItem` | IM / contacts rows |
| `FKOrderListCell` | `FKOrderListItem` | Orders / tickets |
| `FKNotificationListCell` | `FKNotificationListItem` | Notification center |
| `FKSettingsProfileCell` | `FKSettingsProfileItem` | Settings account header |
| `FKFeedContentCell` | `FKFeedContentItem` | Social feed post (body + nine-grid) |
| `FKFeedVideoCell` | `FKFeedVideoItem` | Social feed post with inline video |
| `FKAddressListCell` | `FKAddressListItem` | Shipping address selection |
| `FKPaymentMethodCell` | `FKPaymentMethodItem` | Payment method selection |
| `FKCommentThreadCell` | `FKCommentThreadItem` | Indented comment thread |
| `FKTimelineEventCell` | `FKTimelineEventItem` | Logistics / audit timeline row |
| `FKSearchResultCell` | `FKSearchResultItem` | Search hit with query highlight |
| `FKReviewListCell` | `FKReviewListItem` | Product review with stars + photos |
| `FKFileAttachmentCell` | `FKFileAttachmentItem` | File list row with status pill |
| `FKCartLineItemCell` | `FKCartLineItem` | Read-only cart line summary |
| `FKCartQuantityCell` | `FKCartQuantityItem` | Cart row with quantity stepper |
| `FKUserSelectCell` | `FKUserSelectItem` | Multi-select user picker row |
| `FKInlineToggleCell` | `FKInlineToggleItem` | Business row with trailing switch |
| `FKTagPickerCell` | `FKTagPickerItem` | Inline FKChipGroup selection row |
| `FKRatingInputCell` | `FKRatingInputItem` | Interactive star rating row |
| `FKInviteCodeCell` | `FKInviteCodeItem` | Invite code with FKCopyChip |
| `FKProductGridCell` | `FKProductListItem` | Product grid tiles |
| `FKMediaTileCell` | `FKMediaTileItem` | Photo / attachment grid |
| `FKCellKitUserListSkeletonTableCell` | `FKCellKitUserListSkeletonContext` | User row skeleton |
| `FKCellKitMediaTileSkeletonCollectionCell` | `FKCellKitMediaTileSkeletonContext` | Media tile skeleton |

Design reference (Chinese): [`docs/FKCellKit_DESIGN.md`](../../../../docs/FKCellKit_DESIGN.md)
