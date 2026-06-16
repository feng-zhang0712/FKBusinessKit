import Foundation
import FKBusinessKit
import FKUIKit

/// Static fixtures for CellKit example scenarios.
enum FKCellKitExampleSampleData {
  static func remoteImageURL(id: Int, width: Int = 240, height: Int = 240) -> URL {
    URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")!
  }

  static let sampleVideoURL = URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!

  static var users: [FKUserListItem] {
    [
      FKUserListItem(
        id: "user.alex",
        displayName: "Alex Rivera",
        subtitle: "Product design · online",
        avatarURL: remoteImageURL(id: 64, width: 80, height: 80),
        presenceState: .online,
        unreadCount: 3,
        roleTag: FKTagDisplayModel(title: "Admin", variant: .brand),
        timestampText: "2m",
        isVerified: true
      ),
      FKUserListItem(
        id: "user.jordan",
        displayName: "Jordan Lee",
        subtitle: "Away · mobile",
        avatarURL: remoteImageURL(id: 65, width: 80, height: 80),
        presenceState: .away,
        unreadCount: 0,
        roleTag: FKTagDisplayModel(title: "Guest", variant: .neutral),
        timestampText: "1h",
        isVerified: false
      ),
      FKUserListItem(
        id: "user.sam",
        displayName: "Sam Chen",
        subtitle: "Typing…",
        avatarURL: remoteImageURL(id: 66, width: 80, height: 80),
        presenceState: .busy,
        unreadCount: 12,
        timestampText: "Yesterday",
        isVerified: true
      ),
      FKUserListItem(
        id: "user.taylor",
        displayName: "Taylor Brooks",
        subtitle: nil,
        avatarURL: remoteImageURL(id: 67, width: 80, height: 80),
        presenceState: .offline,
        unreadCount: 0,
        timestampText: "Mon",
        isVerified: false
      ),
    ]
  }

  static func users(matching filter: FKCellKitExampleUserFilter) -> [FKUserListItem] {
    switch filter {
    case .all:
      return users
    case .unreadOnly:
      return users.filter { $0.unreadCount > 0 }
    }
  }

  static var orders: [FKOrderListItem] {
    [
      FKOrderListItem(
        id: "order.1001",
        title: "Wireless earbuds · Midnight",
        subtitle: "$129.00 · Mar 12",
        displayOrderNumber: "#1001",
        fullOrderNumber: "ORD-2026-1001",
        statusPill: FKOrderStatusMapper.displayModel(for: "processing"),
        leadingSymbolName: "shippingbox.fill"
      ),
      FKOrderListItem(
        id: "order.1002",
        title: "Desk lamp · Warm white",
        subtitle: "$58.00 · Mar 10",
        displayOrderNumber: "#1002",
        statusPill: FKOrderStatusMapper.displayModel(for: "shipped"),
        showsCopyChip: true
      ),
      FKOrderListItem(
        id: "order.1003",
        title: "USB-C hub",
        subtitle: "$42.00 · Mar 8",
        displayOrderNumber: "#1003",
        statusPill: FKOrderStatusMapper.displayModel(for: "delivered"),
        leadingSymbolName: nil,
        showsCopyChip: false
      ),
    ]
  }

  static var notifications: [FKNotificationListItem] {
    [
      FKNotificationListItem(
        id: "notif.1",
        title: "Shipment update",
        summary: "Order #1002 left the warehouse and is on the way.",
        timestampText: "10:24",
        symbolName: "bell.badge.fill",
        isUnread: true
      ),
      FKNotificationListItem(
        id: "notif.2",
        title: "New follower",
        summary: nil,
        timestampText: "Yesterday",
        symbolName: "person.crop.circle.badge.plus",
        isUnread: false
      ),
      FKNotificationListItem(
        id: "notif.3",
        title: "Weekly digest",
        summary: "Three posts from people you follow plus two product recommendations tailored for you.",
        timestampText: "Sun",
        symbolName: "sparkles",
        isUnread: true
      ),
    ]
  }

  static var settingsProfiles: [FKSettingsProfileItem] {
    [
      FKSettingsProfileItem(
        id: "profile.main",
        displayName: "Alex Rivera",
        accountText: "alex@example.com",
        avatarURL: remoteImageURL(id: 64, width: 96, height: 96),
        isVerified: true
      ),
    ]
  }

  static var addresses: [FKAddressListItem] {
    [
      FKAddressListItem(
        id: "addr.home",
        recipientName: "Alex Rivera",
        phone: "+1 415 555 0100",
        address: "742 Evergreen Terrace\nSpringfield, CA 94107",
        isDefault: true,
        isSelected: true
      ),
      FKAddressListItem(
        id: "addr.office",
        recipientName: "Alex Rivera",
        phone: "+1 415 555 0199",
        address: "1 Market St, Suite 300\nSan Francisco, CA 94105",
        isDefault: false,
        isSelected: false
      ),
    ]
  }

  static var paymentMethods: [FKPaymentMethodItem] {
    [
      FKPaymentMethodItem(
        id: "pay.apple",
        title: "Apple Pay",
        subtitle: "Default wallet",
        symbolName: "apple.logo",
        isSelected: true
      ),
      FKPaymentMethodItem(
        id: "pay.visa",
        title: "Visa",
        subtitle: "•••• 4242",
        symbolName: "creditcard.fill",
        isSelected: false
      ),
    ]
  }

  static var feedPosts: [FKFeedContentItem] {
    [
      FKFeedContentItem(
        id: "post.text",
        authorName: "Jordan Lee",
        avatarURL: remoteImageURL(id: 65, width: 80, height: 80),
        body: "CellKit feed rows support multi-line copy and optional image grids.",
        imageURLs: [],
        timestampText: "1h",
        isVerified: false
      ),
      FKFeedContentItem(
        id: "post.single",
        authorName: "Sam Chen",
        avatarURL: remoteImageURL(id: 66, width: 80, height: 80),
        body: "Single-image layout uses a wider aspect ratio.",
        imageURLs: [remoteImageURL(id: 180, width: 640, height: 480)],
        timestampText: "3h",
        isVerified: true
      ),
      FKFeedContentItem(
        id: "post.grid",
        authorName: "Taylor Brooks",
        avatarURL: remoteImageURL(id: 67, width: 80, height: 80),
        body: "Nine-grid caps at nine thumbnails and shows a +N overflow badge.",
        imageURLs: (1 ... 11).map { remoteImageURL(id: 100 + $0, width: 240, height: 240) },
        timestampText: "Yesterday",
        isVerified: false
      ),
    ]
  }

  static var feedVideos: [FKFeedVideoItem] {
    [
      FKFeedVideoItem(
        id: "video.1",
        authorName: "Alex Rivera",
        avatarURL: remoteImageURL(id: 64, width: 80, height: 80),
        video: FKVideoItem(
          id: "clip.1",
          source: .url(sampleVideoURL),
          title: "Product walkthrough",
          posterURL: remoteImageURL(id: 180, width: 640, height: 360)
        ),
        caption: "Inline playback pauses when scrolled off screen.",
        timestampText: "Now",
        isVerified: true
      ),
      FKFeedVideoItem(
        id: "video.2",
        authorName: "Jordan Lee",
        avatarURL: remoteImageURL(id: 65, width: 80, height: 80),
        video: FKVideoItem(
          id: "clip.2",
          source: .url(sampleVideoURL),
          title: "Behind the scenes",
          posterURL: remoteImageURL(id: 181, width: 640, height: 360)
        ),
        caption: nil,
        timestampText: "5m",
        isVerified: false
      ),
    ]
  }

  static var commentThread: [FKCommentThreadItem] {
    [
      FKCommentThreadItem(
        id: "comment.root",
        depth: 0,
        authorName: "Alex Rivera",
        avatarURL: remoteImageURL(id: 64, width: 48, height: 48),
        body: "Love the new CellKit presets — ListKit registration is one line now.",
        timestampText: "2h",
        replySummaryText: "2 replies",
        isVerified: true
      ),
      FKCommentThreadItem(
        id: "comment.reply1",
        depth: 1,
        authorName: "Jordan Lee",
        avatarURL: remoteImageURL(id: 65, width: 48, height: 48),
        body: "Same here. The visibility forwarder keeps avatar loads tidy.",
        timestampText: "1h",
        replySummaryText: "1 reply"
      ),
      FKCommentThreadItem(
        id: "comment.reply2",
        depth: 2,
        authorName: "Sam Chen",
        avatarURL: remoteImageURL(id: 66, width: 48, height: 48),
        body: "Prefetch + height cache on feed rows is the other big win.",
        timestampText: "45m"
      ),
      FKCommentThreadItem(
        id: "comment.reply3",
        depth: 3,
        authorName: "Taylor Brooks",
        avatarURL: remoteImageURL(id: 67, width: 48, height: 48),
        body: "Depth is capped visually so deeply nested threads stay readable.",
        timestampText: "30m"
      ),
    ]
  }

  static var products: [FKProductListItem] {
    [
      FKProductListItem(
        id: "product.1",
        title: "Canvas tote",
        priceText: "$24.00",
        imageURL: remoteImageURL(id: 201, width: 320, height: 320),
        tags: [FKTagDisplayModel(title: "New", variant: .brand)]
      ),
      FKProductListItem(
        id: "product.2",
        title: "Ceramic mug set",
        priceText: "$36.00",
        imageURL: remoteImageURL(id: 202, width: 320, height: 320),
        tags: [
          FKTagDisplayModel(title: "Sale", variant: .warning),
          FKTagDisplayModel(title: "Limited", variant: .outline),
        ]
      ),
      FKProductListItem(
        id: "product.3",
        title: "Linen throw",
        priceText: "$58.00",
        imageURL: remoteImageURL(id: 203, width: 320, height: 320),
        tags: []
      ),
      FKProductListItem(
        id: "product.4",
        title: "Desk organizer",
        priceText: "$19.00",
        imageURL: remoteImageURL(id: 204, width: 320, height: 320),
        tags: [FKTagDisplayModel(title: "Bestseller", variant: .success)]
      ),
    ]
  }

  static var mediaTiles: [FKMediaTileItem] {
    [
      FKMediaTileItem(
        id: "tile.1",
        imageURL: remoteImageURL(id: 301, width: 240, height: 240),
        durationText: nil,
        isSelected: true
      ),
      FKMediaTileItem(
        id: "tile.2",
        imageURL: remoteImageURL(id: 302, width: 240, height: 240),
        durationText: "01:24",
        isSelected: false
      ),
      FKMediaTileItem(
        id: "tile.3",
        imageURL: remoteImageURL(id: 303, width: 240, height: 240),
        durationText: "00:42",
        isSelected: false
      ),
      FKMediaTileItem(
        id: "tile.4",
        imageURL: remoteImageURL(id: 304, width: 240, height: 240),
        durationText: nil,
        isSelected: true
      ),
    ]
  }

  static func makeUserListSnapshot(_ users: [FKUserListItem]) -> FKListSnapshot {
    FKListSnapshot(items: users.map(FKCellKitListItemFactory.userList))
  }

  static func storeUserListPayloads(_ users: [FKUserListItem], on controller: FKDiffableTableViewController) {
    FKCellKitListItemFactory.storeUserListPayloads(users, on: controller)
  }

  static func delayed<T>(_ value: T, seconds: TimeInterval = 0.55) async throws -> T {
    try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
    return value
  }

  // MARK: - Extended v2 cells

  static var timelineEvents: [FKTimelineEventItem] {
    let steps: [FKFlowStepItem] = [
      FKFlowStepItem(
        id: "timeline.1",
        title: "Order placed",
        subtitle: "Warehouse received your order",
        caption: "Payment confirmed · Visa •••• 4242",
        formattedTimestamp: "Mon 09:12",
        state: .completed
      ),
      FKFlowStepItem(
        id: "timeline.2",
        title: "Packed",
        subtitle: "Items scanned and boxed",
        formattedTimestamp: "Mon 14:40",
        state: .completed
      ),
      FKFlowStepItem(
        id: "timeline.3",
        title: "Out for delivery",
        subtitle: "Courier is en route",
        formattedTimestamp: "Tue 08:05",
        state: .current
      ),
      FKFlowStepItem(
        id: "timeline.4",
        title: "Delivered",
        subtitle: "Signature required",
        formattedTimestamp: "Estimated Tue 18:00",
        state: .upcoming
      ),
    ]
    return FKTimelineEventItem.makeList(from: steps)
  }

  static var searchResults: [FKSearchResultItem] {
    [
      FKSearchResultItem(
        id: "search.1",
        title: "Wireless earbuds",
        highlightedQuery: "Wireless",
        breadcrumbText: "Shop · Audio",
        categoryTagTitle: "Product"
      ),
      FKSearchResultItem(
        id: "search.2",
        title: "Order #1001 — Wireless earbuds",
        highlightedQuery: "1001",
        breadcrumbText: "Orders",
        categoryTagTitle: "Order"
      ),
    ]
  }

  static var reviews: [FKReviewListItem] {
    [
      FKReviewListItem(
        id: "review.1",
        authorName: "Alex Rivera",
        avatarURL: remoteImageURL(id: 64, width: 80, height: 80),
        rating: 4.5,
        reviewText: "Great sound quality and the case feels premium. Battery lasts all day on commute.",
        timestampText: "Mar 12",
        imageURLs: [
          remoteImageURL(id: 401, width: 120, height: 120),
          remoteImageURL(id: 402, width: 120, height: 120),
        ]
      ),
      FKReviewListItem(
        id: "review.2",
        authorName: "Jordan Lee",
        avatarURL: remoteImageURL(id: 65, width: 80, height: 80),
        rating: 3,
        reviewText: "Comfortable fit, but the touch controls are a bit sensitive.",
        timestampText: "Mar 10"
      ),
    ]
  }

  static var fileAttachments: [FKFileAttachmentItem] {
    [
      FKFileAttachmentItem(
        id: "file.1",
        fileName: "Invoice_Mar2026.pdf",
        fileSizeText: "248 KB",
        symbolName: "doc.fill",
        state: .uploaded
      ),
      FKFileAttachmentItem(
        id: "file.2",
        fileName: "ProductPhotos.zip",
        fileSizeText: "12.4 MB",
        symbolName: "archivebox.fill",
        state: .downloading
      ),
    ]
  }

  static var cartLineItems: [FKCartLineItem] {
    [
      FKCartLineItem(
        id: "cart.line.1",
        title: "Wireless earbuds · Midnight",
        variantText: "Color: Midnight · Size: One",
        imageURL: remoteImageURL(id: 201, width: 160, height: 160),
        priceText: "$129.00",
        originalPriceText: "$149.00",
        quantityText: "×1"
      ),
      FKCartLineItem(
        id: "cart.line.2",
        title: "Canvas tote",
        variantText: "Color: Sand",
        imageURL: remoteImageURL(id: 202, width: 160, height: 160),
        priceText: "$24.00",
        quantityText: "×2"
      ),
    ]
  }

  static var cartQuantityItems: [FKCartQuantityItem] {
    [
      FKCartQuantityItem(
        id: "cart.qty.1",
        title: "Wireless earbuds · Midnight",
        variantText: "Color: Midnight",
        imageURL: remoteImageURL(id: 201, width: 160, height: 160),
        priceText: "$129.00",
        quantity: 1,
        quantityHandlerID: "cellkit.cart.quantity"
      ),
      FKCartQuantityItem(
        id: "cart.qty.2",
        title: "Canvas tote",
        variantText: "Color: Sand",
        imageURL: remoteImageURL(id: 202, width: 160, height: 160),
        priceText: "$24.00",
        quantity: 2,
        quantityHandlerID: "cellkit.cart.quantity"
      ),
    ]
  }

  static var userSelectItems: [FKUserSelectItem] {
    users.map { user in
      FKUserSelectItem(
        id: user.id,
        displayName: user.displayName,
        subtitle: user.subtitle,
        avatarURL: user.avatarURL,
        presenceState: user.presenceState,
        isSelected: user.id == "user.alex" || user.id == "user.sam",
        isVerified: user.isVerified
      )
    }
  }

  static var inlineToggleItems: [FKInlineToggleItem] {
    [
      FKInlineToggleItem(
        id: "toggle.mute",
        title: "Mute notifications",
        subtitle: "Silence alerts from this contact",
        leadingSymbolName: "bell.slash.fill",
        isOn: false,
        switchHandlerID: "cellkit.toggle.mute"
      ),
      FKInlineToggleItem(
        id: "toggle.pin",
        title: "Pin conversation",
        subtitle: "Keep thread at the top",
        leadingSymbolName: "pin.fill",
        isOn: true,
        switchHandlerID: "cellkit.toggle.pin"
      ),
    ]
  }

  static var tagPickerItems: [FKTagPickerItem] {
    [
      FKTagPickerItem(
        id: "picker.size",
        title: "Size",
        chips: [
          FKChipItem(id: "s", title: "S"),
          FKChipItem(id: "m", title: "M"),
          FKChipItem(id: "l", title: "L"),
          FKChipItem(id: "xl", title: "XL"),
        ],
        selectedChipIDs: ["m"],
        selectionMode: .single,
        chipHandlerID: "cellkit.picker.size"
      ),
    ]
  }

  static var ratingInputItems: [FKRatingInputItem] {
    [
      FKRatingInputItem(
        id: "rating.product",
        title: "Rate this product",
        subtitle: "Tap a star to submit your score",
        rating: 4,
        ratingHandlerID: "cellkit.rating.product"
      ),
    ]
  }

  static var inviteCodeItems: [FKInviteCodeItem] {
    [
      FKInviteCodeItem(
        id: "invite.main",
        title: "Invite friends",
        inviteCode: "FK-2026-ALEX",
        subtitle: "Share your code to earn rewards",
        showsShareAffordance: true,
        shareHandlerID: "cellkit.invite.share"
      ),
    ]
  }
}

enum FKCellKitExampleUserFilter: String, CaseIterable {
  case all
  case unreadOnly

  var title: String {
    switch self {
    case .all: return "All"
    case .unreadOnly: return "Unread"
    }
  }
}
