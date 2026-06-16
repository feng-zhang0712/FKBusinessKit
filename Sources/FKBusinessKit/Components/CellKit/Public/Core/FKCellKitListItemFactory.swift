import FKUIKit

/// Builds ``FKListItem`` entries and stores payloads for CellKit custom rows.
public enum FKCellKitListItemFactory {
  /// ListKit registry key for ``FKUserListCell`` (`String(describing:)`).
  public static var userListCellTypeIdentifier: String { FKUserListCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKOrderListCell``.
  public static var orderListCellTypeIdentifier: String { FKOrderListCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKNotificationListCell``.
  public static var notificationListCellTypeIdentifier: String { FKNotificationListCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKSettingsProfileCell``.
  public static var settingsProfileCellTypeIdentifier: String { FKSettingsProfileCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKProductGridCell``.
  public static var productGridCellTypeIdentifier: String { FKProductGridCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKMediaTileCell``.
  public static var mediaTileCellTypeIdentifier: String { FKMediaTileCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKFeedContentCell``.
  public static var feedContentCellTypeIdentifier: String { FKFeedContentCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKFeedVideoCell``.
  public static var feedVideoCellTypeIdentifier: String { FKFeedVideoCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKAddressListCell``.
  public static var addressListCellTypeIdentifier: String { FKAddressListCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKPaymentMethodCell``.
  public static var paymentMethodCellTypeIdentifier: String { FKPaymentMethodCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKCommentThreadCell``.
  public static var commentThreadCellTypeIdentifier: String { FKCommentThreadCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKTimelineEventCell``.
  public static var timelineEventCellTypeIdentifier: String { FKTimelineEventCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKSearchResultCell``.
  public static var searchResultCellTypeIdentifier: String { FKSearchResultCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKReviewListCell``.
  public static var reviewListCellTypeIdentifier: String { FKReviewListCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKFileAttachmentCell``.
  public static var fileAttachmentCellTypeIdentifier: String { FKFileAttachmentCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKCartLineItemCell``.
  public static var cartLineItemCellTypeIdentifier: String { FKCartLineItemCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKCartQuantityCell``.
  public static var cartQuantityCellTypeIdentifier: String { FKCartQuantityCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKUserSelectCell``.
  public static var userSelectCellTypeIdentifier: String { FKUserSelectCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKInlineToggleCell``.
  public static var inlineToggleCellTypeIdentifier: String { FKInlineToggleCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKTagPickerCell``.
  public static var tagPickerCellTypeIdentifier: String { FKTagPickerCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKRatingInputCell``.
  public static var ratingInputCellTypeIdentifier: String { FKRatingInputCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKInviteCodeCell``.
  public static var inviteCodeCellTypeIdentifier: String { FKInviteCodeCell.listKitCellTypeIdentifier }

  /// ListKit registry key for ``FKCellKitUserListSkeletonTableCell``.
  public static var userListSkeletonCellTypeIdentifier: String {
    FKCellKitUserListSkeletonTableCell.listKitCellTypeIdentifier
  }

  /// ListKit registry key for ``FKCellKitMediaTileSkeletonCollectionCell``.
  public static var mediaTileSkeletonCellTypeIdentifier: String {
    FKCellKitMediaTileSkeletonCollectionCell.listKitCellTypeIdentifier
  }

  /// Creates a custom list item for ``FKUserListCell``.
  public static func userList(_ item: FKUserListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: userListCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKOrderListCell``.
  public static func orderList(_ item: FKOrderListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: orderListCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKNotificationListCell``.
  public static func notificationList(_ item: FKNotificationListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: notificationListCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKSettingsProfileCell``.
  public static func settingsProfile(_ item: FKSettingsProfileItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: settingsProfileCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKFeedContentCell``.
  public static func feedContent(_ item: FKFeedContentItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: feedContentCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKFeedVideoCell``.
  public static func feedVideo(_ item: FKFeedVideoItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: feedVideoCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKAddressListCell``.
  public static func addressList(_ item: FKAddressListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: addressListCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKPaymentMethodCell``.
  public static func paymentMethod(_ item: FKPaymentMethodItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: paymentMethodCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKCommentThreadCell``.
  public static func commentThread(_ item: FKCommentThreadItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: commentThreadCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKTimelineEventCell``.
  public static func timelineEvent(_ item: FKTimelineEventItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: timelineEventCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKSearchResultCell``.
  public static func searchResult(_ item: FKSearchResultItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: searchResultCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKReviewListCell``.
  public static func reviewList(_ item: FKReviewListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: reviewListCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKFileAttachmentCell``.
  public static func fileAttachment(_ item: FKFileAttachmentItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: fileAttachmentCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKCartLineItemCell``.
  public static func cartLineItem(_ item: FKCartLineItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: cartLineItemCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKCartQuantityCell``.
  public static func cartQuantity(_ item: FKCartQuantityItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: cartQuantityCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKUserSelectCell``.
  public static func userSelect(_ item: FKUserSelectItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: userSelectCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKInlineToggleCell``.
  public static func inlineToggle(_ item: FKInlineToggleItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: inlineToggleCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKTagPickerCell``.
  public static func tagPicker(_ item: FKTagPickerItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: tagPickerCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKRatingInputCell``.
  public static func ratingInput(_ item: FKRatingInputItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: ratingInputCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKInviteCodeCell``.
  public static func inviteCode(_ item: FKInviteCodeItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: inviteCodeCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKProductGridCell``.
  public static func productGrid(_ item: FKProductListItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: productGridCellTypeIdentifier)
  }

  /// Creates a custom list item for ``FKMediaTileCell``.
  public static func mediaTile(_ item: FKMediaTileItem) -> FKListItem {
    .custom(id: .init(item.id), cellTypeIdentifier: mediaTileCellTypeIdentifier)
  }

  /// Creates a skeleton placeholder list item matching ``FKUserListCell`` layout.
  public static func userListSkeleton(id: FKListItemID = FKListItemID("skeleton.userList")) -> FKListItem {
    .custom(id: id, cellTypeIdentifier: userListSkeletonCellTypeIdentifier)
  }

  /// Creates a skeleton placeholder list item matching ``FKMediaTileCell`` layout.
  public static func mediaTileSkeleton(id: FKListItemID = FKListItemID("skeleton.mediaTile")) -> FKListItem {
    .custom(id: id, cellTypeIdentifier: mediaTileSkeletonCellTypeIdentifier)
  }

  /// Stores a user list payload before applying a snapshot.
  @MainActor
  public static func storeUserListPayload(_ item: FKUserListItem, on controller: FKDiffableTableViewController) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores an order list payload before applying a snapshot.
  @MainActor
  public static func storeOrderListPayload(_ item: FKOrderListItem, on controller: FKDiffableTableViewController) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a notification list payload before applying a snapshot.
  @MainActor
  public static func storeNotificationListPayload(
    _ item: FKNotificationListItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a settings profile payload before applying a snapshot.
  @MainActor
  public static func storeSettingsProfilePayload(
    _ item: FKSettingsProfileItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a product grid payload before applying a snapshot.
  @MainActor
  public static func storeProductGridPayload(
    _ item: FKProductListItem,
    on controller: FKDiffableCollectionViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a media tile payload before applying a snapshot.
  @MainActor
  public static func storeMediaTilePayload(
    _ item: FKMediaTileItem,
    on controller: FKDiffableCollectionViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a feed content payload before applying a snapshot.
  @MainActor
  public static func storeFeedContentPayload(
    _ item: FKFeedContentItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a feed video payload before applying a snapshot.
  @MainActor
  public static func storeFeedVideoPayload(
    _ item: FKFeedVideoItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores an address list payload before applying a snapshot.
  @MainActor
  public static func storeAddressListPayload(
    _ item: FKAddressListItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a payment method payload before applying a snapshot.
  @MainActor
  public static func storePaymentMethodPayload(
    _ item: FKPaymentMethodItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a comment thread payload before applying a snapshot.
  @MainActor
  public static func storeCommentThreadPayload(
    _ item: FKCommentThreadItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a user-list skeleton payload for a placeholder row.
  @MainActor
  public static func storeUserListSkeletonPayload(
    id: FKListItemID = FKListItemID("skeleton.userList"),
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(FKCellKitUserListSkeletonContext()), for: id)
  }

  /// Stores a media-tile skeleton payload for a placeholder item.
  @MainActor
  public static func storeMediaTileSkeletonPayload(
    id: FKListItemID = FKListItemID("skeleton.mediaTile"),
    on controller: FKDiffableCollectionViewController
  ) {
    controller.setPayload(FKListItemPayload(FKCellKitMediaTileSkeletonContext()), for: id)
  }

  /// Stores feed content payloads for each item.
  @MainActor
  public static func storeFeedContentPayloads(
    _ items: [FKFeedContentItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeFeedContentPayload($0, on: controller) }
  }

  /// Stores feed video payloads for each item.
  @MainActor
  public static func storeFeedVideoPayloads(
    _ items: [FKFeedVideoItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeFeedVideoPayload($0, on: controller) }
  }

  /// Stores address list payloads for each item.
  @MainActor
  public static func storeAddressListPayloads(
    _ items: [FKAddressListItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeAddressListPayload($0, on: controller) }
  }

  /// Stores payment method payloads for each item.
  @MainActor
  public static func storePaymentMethodPayloads(
    _ items: [FKPaymentMethodItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storePaymentMethodPayload($0, on: controller) }
  }

  /// Stores comment thread payloads for each item.
  @MainActor
  public static func storeCommentThreadPayloads(
    _ items: [FKCommentThreadItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeCommentThreadPayload($0, on: controller) }
  }

  /// Stores a timeline event payload before applying a snapshot.
  @MainActor
  public static func storeTimelineEventPayload(
    _ item: FKTimelineEventItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a search result payload before applying a snapshot.
  @MainActor
  public static func storeSearchResultPayload(
    _ item: FKSearchResultItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a review list payload before applying a snapshot.
  @MainActor
  public static func storeReviewListPayload(
    _ item: FKReviewListItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a file attachment payload before applying a snapshot.
  @MainActor
  public static func storeFileAttachmentPayload(
    _ item: FKFileAttachmentItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a cart line item payload before applying a snapshot.
  @MainActor
  public static func storeCartLineItemPayload(
    _ item: FKCartLineItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a cart quantity payload before applying a snapshot.
  @MainActor
  public static func storeCartQuantityPayload(
    _ item: FKCartQuantityItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a user select payload before applying a snapshot.
  @MainActor
  public static func storeUserSelectPayload(
    _ item: FKUserSelectItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores an inline toggle payload before applying a snapshot.
  @MainActor
  public static func storeInlineTogglePayload(
    _ item: FKInlineToggleItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a tag picker payload before applying a snapshot.
  @MainActor
  public static func storeTagPickerPayload(
    _ item: FKTagPickerItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores a rating input payload before applying a snapshot.
  @MainActor
  public static func storeRatingInputPayload(
    _ item: FKRatingInputItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores an invite code payload before applying a snapshot.
  @MainActor
  public static func storeInviteCodePayload(
    _ item: FKInviteCodeItem,
    on controller: FKDiffableTableViewController
  ) {
    controller.setPayload(FKListItemPayload(item), for: .init(item.id))
  }

  /// Stores timeline event payloads for each item.
  @MainActor
  public static func storeTimelineEventPayloads(
    _ items: [FKTimelineEventItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeTimelineEventPayload($0, on: controller) }
  }

  /// Stores search result payloads for each item.
  @MainActor
  public static func storeSearchResultPayloads(
    _ items: [FKSearchResultItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeSearchResultPayload($0, on: controller) }
  }

  /// Stores review list payloads for each item.
  @MainActor
  public static func storeReviewListPayloads(
    _ items: [FKReviewListItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeReviewListPayload($0, on: controller) }
  }

  /// Stores file attachment payloads for each item.
  @MainActor
  public static func storeFileAttachmentPayloads(
    _ items: [FKFileAttachmentItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeFileAttachmentPayload($0, on: controller) }
  }

  /// Stores cart line item payloads for each item.
  @MainActor
  public static func storeCartLineItemPayloads(
    _ items: [FKCartLineItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeCartLineItemPayload($0, on: controller) }
  }

  /// Stores cart quantity payloads for each item.
  @MainActor
  public static func storeCartQuantityPayloads(
    _ items: [FKCartQuantityItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeCartQuantityPayload($0, on: controller) }
  }

  /// Stores user select payloads for each item.
  @MainActor
  public static func storeUserSelectPayloads(
    _ items: [FKUserSelectItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeUserSelectPayload($0, on: controller) }
  }

  /// Stores inline toggle payloads for each item.
  @MainActor
  public static func storeInlineTogglePayloads(
    _ items: [FKInlineToggleItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeInlineTogglePayload($0, on: controller) }
  }

  /// Stores tag picker payloads for each item.
  @MainActor
  public static func storeTagPickerPayloads(
    _ items: [FKTagPickerItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeTagPickerPayload($0, on: controller) }
  }

  /// Stores rating input payloads for each item.
  @MainActor
  public static func storeRatingInputPayloads(
    _ items: [FKRatingInputItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeRatingInputPayload($0, on: controller) }
  }

  /// Stores invite code payloads for each item.
  @MainActor
  public static func storeInviteCodePayloads(
    _ items: [FKInviteCodeItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeInviteCodePayload($0, on: controller) }
  }

  /// Stores user list payloads for each item.
  @MainActor
  public static func storeUserListPayloads(
    _ items: [FKUserListItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeUserListPayload($0, on: controller) }
  }

  /// Stores order list payloads for each item.
  @MainActor
  public static func storeOrderListPayloads(
    _ items: [FKOrderListItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeOrderListPayload($0, on: controller) }
  }

  /// Stores notification list payloads for each item.
  @MainActor
  public static func storeNotificationListPayloads(
    _ items: [FKNotificationListItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeNotificationListPayload($0, on: controller) }
  }

  /// Stores settings profile payloads for each item.
  @MainActor
  public static func storeSettingsProfilePayloads(
    _ items: [FKSettingsProfileItem],
    on controller: FKDiffableTableViewController
  ) {
    items.forEach { storeSettingsProfilePayload($0, on: controller) }
  }

  /// Stores product grid payloads for each item.
  @MainActor
  public static func storeProductGridPayloads(
    _ items: [FKProductListItem],
    on controller: FKDiffableCollectionViewController
  ) {
    items.forEach { storeProductGridPayload($0, on: controller) }
  }

  /// Stores media tile payloads for each item.
  @MainActor
  public static func storeMediaTilePayloads(
    _ items: [FKMediaTileItem],
    on controller: FKDiffableCollectionViewController
  ) {
    items.forEach { storeMediaTilePayload($0, on: controller) }
  }
}
