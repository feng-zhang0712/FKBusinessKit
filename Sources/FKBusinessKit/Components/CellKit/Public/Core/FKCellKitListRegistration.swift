import FKUIKit

/// ListKit registration helpers for CellKit table and collection cells.
public enum FKCellKitListRegistration {
  /// Registers ``FKUserListCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerUserListCell(on controller: FKDiffableTableViewController) {
    register(FKUserListCell.self, on: controller)
  }

  /// Registers ``FKOrderListCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerOrderListCell(on controller: FKDiffableTableViewController) {
    register(FKOrderListCell.self, on: controller)
  }

  /// Registers ``FKNotificationListCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerNotificationListCell(on controller: FKDiffableTableViewController) {
    register(FKNotificationListCell.self, on: controller)
  }

  /// Registers ``FKSettingsProfileCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerSettingsProfileCell(on controller: FKDiffableTableViewController) {
    register(FKSettingsProfileCell.self, on: controller)
  }

  /// Registers ``FKFeedContentCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerFeedContentCell(on controller: FKDiffableTableViewController) {
    register(FKFeedContentCell.self, on: controller)
  }

  /// Registers ``FKFeedVideoCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerFeedVideoCell(on controller: FKDiffableTableViewController) {
    register(FKFeedVideoCell.self, on: controller)
  }

  /// Registers ``FKAddressListCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerAddressListCell(on controller: FKDiffableTableViewController) {
    register(FKAddressListCell.self, on: controller)
  }

  /// Registers ``FKPaymentMethodCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerPaymentMethodCell(on controller: FKDiffableTableViewController) {
    register(FKPaymentMethodCell.self, on: controller)
  }

  /// Registers ``FKCommentThreadCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerCommentThreadCell(on controller: FKDiffableTableViewController) {
    register(FKCommentThreadCell.self, on: controller)
  }

  /// Registers ``FKTimelineEventCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerTimelineEventCell(on controller: FKDiffableTableViewController) {
    register(FKTimelineEventCell.self, on: controller)
  }

  /// Registers ``FKSearchResultCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerSearchResultCell(on controller: FKDiffableTableViewController) {
    register(FKSearchResultCell.self, on: controller)
  }

  /// Registers ``FKReviewListCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerReviewListCell(on controller: FKDiffableTableViewController) {
    register(FKReviewListCell.self, on: controller)
  }

  /// Registers ``FKFileAttachmentCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerFileAttachmentCell(on controller: FKDiffableTableViewController) {
    register(FKFileAttachmentCell.self, on: controller)
  }

  /// Registers ``FKCartLineItemCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerCartLineItemCell(on controller: FKDiffableTableViewController) {
    register(FKCartLineItemCell.self, on: controller)
  }

  /// Registers ``FKCartQuantityCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerCartQuantityCell(on controller: FKDiffableTableViewController) {
    register(FKCartQuantityCell.self, on: controller)
  }

  /// Registers ``FKUserSelectCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerUserSelectCell(on controller: FKDiffableTableViewController) {
    register(FKUserSelectCell.self, on: controller)
  }

  /// Registers ``FKInlineToggleCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerInlineToggleCell(on controller: FKDiffableTableViewController) {
    register(FKInlineToggleCell.self, on: controller)
  }

  /// Registers ``FKTagPickerCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerTagPickerCell(on controller: FKDiffableTableViewController) {
    register(FKTagPickerCell.self, on: controller)
  }

  /// Registers ``FKRatingInputCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerRatingInputCell(on controller: FKDiffableTableViewController) {
    register(FKRatingInputCell.self, on: controller)
  }

  /// Registers ``FKInviteCodeCell`` with its payload type on a diffable table controller.
  @MainActor
  public static func registerInviteCodeCell(on controller: FKDiffableTableViewController) {
    register(FKInviteCodeCell.self, on: controller)
  }

  /// Registers ``FKCellKitUserListSkeletonTableCell`` for ListKit skeleton rows.
  @MainActor
  public static func registerUserListSkeletonCell(on controller: FKDiffableTableViewController) {
    controller.register(
      FKCellKitUserListSkeletonTableCell.self,
      forPayloadType: FKCellKitUserListSkeletonContext.self
    )
  }

  /// Registers ``FKProductGridCell`` with its payload type on a diffable collection controller.
  @MainActor
  public static func registerProductGridCell(on controller: FKDiffableCollectionViewController) {
    register(FKProductGridCell.self, on: controller)
  }

  /// Registers ``FKMediaTileCell`` with its payload type on a diffable collection controller.
  @MainActor
  public static func registerMediaTileCell(on controller: FKDiffableCollectionViewController) {
    register(FKMediaTileCell.self, on: controller)
  }

  /// Registers ``FKCellKitMediaTileSkeletonCollectionCell`` for collection skeleton tiles.
  @MainActor
  public static func registerMediaTileSkeletonCell(on controller: FKDiffableCollectionViewController) {
    controller.register(
      FKCellKitMediaTileSkeletonCollectionCell.self,
      forPayloadType: FKCellKitMediaTileSkeletonContext.self
    )
  }

  /// Registers all CellKit table content cells on a diffable table controller.
  @MainActor
  public static func registerAllTableCells(on controller: FKDiffableTableViewController) {
    registerUserListCell(on: controller)
    registerOrderListCell(on: controller)
    registerNotificationListCell(on: controller)
    registerSettingsProfileCell(on: controller)
    registerFeedContentCell(on: controller)
    registerFeedVideoCell(on: controller)
    registerAddressListCell(on: controller)
    registerPaymentMethodCell(on: controller)
    registerCommentThreadCell(on: controller)
    registerTimelineEventCell(on: controller)
    registerSearchResultCell(on: controller)
    registerReviewListCell(on: controller)
    registerFileAttachmentCell(on: controller)
    registerCartLineItemCell(on: controller)
    registerCartQuantityCell(on: controller)
    registerUserSelectCell(on: controller)
    registerInlineToggleCell(on: controller)
    registerTagPickerCell(on: controller)
    registerRatingInputCell(on: controller)
    registerInviteCodeCell(on: controller)
  }

  /// Registers all CellKit collection content cells on a diffable collection controller.
  @MainActor
  public static func registerAllCollectionCells(on controller: FKDiffableCollectionViewController) {
    registerProductGridCell(on: controller)
    registerMediaTileCell(on: controller)
  }

  /// Registers a CellKit table cell type that inherits ``FKBaseTableViewCell``.
  @MainActor
  public static func register<Cell: FKListTableCellConfigurable>(
    _ cellType: Cell.Type,
    on controller: FKDiffableTableViewController
  ) where Cell: FKBaseTableViewCell {
    controller.register(cellType, forPayloadType: Cell.Item.self)
  }

  /// Registers a CellKit collection cell type that inherits ``FKBaseCollectionViewCell``.
  @MainActor
  public static func register<Cell: FKListCollectionCellConfigurable>(
    _ cellType: Cell.Type,
    on controller: FKDiffableCollectionViewController
  ) where Cell: FKBaseCollectionViewCell {
    controller.register(cellType, forPayloadType: Cell.Item.self)
  }
}
