import UIKit
import FKUIKit

/// Appearance tokens for flat CellKit table rows.
public struct FKCellKitTableCellConfiguration: Equatable {
  /// Insets applied to ``FKBaseTableViewCell/containerView``.
  public var contentInsets: UIEdgeInsets
  /// Background color used while the row is selected. Defaults to `.clear` so rows stay tappable without a gray fill; set explicitly when selection chrome is desired.
  public var selectedBackgroundColor: UIColor

  /// Creates table cell chrome configuration.
  public init(
    contentInsets: UIEdgeInsets = UIEdgeInsets(
      top: FKCellKitLayoutMetrics.verticalInset,
      left: FKCellKitLayoutMetrics.horizontalInset,
      bottom: FKCellKitLayoutMetrics.verticalInset,
      right: FKCellKitLayoutMetrics.horizontalInset
    ),
    selectedBackgroundColor: UIColor = .clear
  ) {
    self.contentInsets = contentInsets
    self.selectedBackgroundColor = selectedBackgroundColor
  }

  /// Full-width separator row preset.
  public static var flatRow: FKCellKitTableCellConfiguration { .init() }

  /// Inset card row preset with rounded container styling applied by the cell subclass.
  public static var insetCard: FKCellKitTableCellConfiguration {
    var config = FKCellKitTableCellConfiguration()
    config.contentInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
    return config
  }
}

/// Combined configuration for ``FKUserListCell``.
public struct FKUserListCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var leading: FKUserListLeadingConfiguration
  public var trailing: FKUserListTrailingConfiguration

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    leading: FKUserListLeadingConfiguration = .init(),
    trailing: FKUserListTrailingConfiguration = .init()
  ) {
    self.table = table
    self.leading = leading
    self.trailing = trailing
  }
}

/// Combined configuration for ``FKOrderListCell``.
public struct FKOrderListCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat
  public var metaSpacing: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline,
    leadingSymbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide,
    metaSpacing: CGFloat = 8
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.leadingSymbolSide = leadingSymbolSide
    self.metaSpacing = metaSpacing
  }
}

/// Combined configuration for ``FKNotificationListCell``.
public struct FKNotificationListCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var summaryTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat
  public var unreadDotDiameter: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    summaryTextStyle: UIFont.TextStyle = .subheadline,
    timestampTextStyle: UIFont.TextStyle = .caption1,
    leadingSymbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide,
    unreadDotDiameter: CGFloat = 8
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.summaryTextStyle = summaryTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.leadingSymbolSide = leadingSymbolSide
    self.unreadDotDiameter = unreadDotDiameter
  }
}

/// Combined configuration for ``FKProductGridCell``.
public struct FKProductGridCellConfiguration: Equatable {
  public var contentInsets: UIEdgeInsets
  public var cornerRadius: CGFloat
  public var imageCornerRadius: CGFloat
  public var titleTextStyle: UIFont.TextStyle
  public var priceTextStyle: UIFont.TextStyle
  public var titleNumberOfLines: Int
  public var verticalSpacing: CGFloat
  public var tagSpacing: CGFloat

  public init(
    contentInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
    cornerRadius: CGFloat = 12,
    imageCornerRadius: CGFloat = 8,
    titleTextStyle: UIFont.TextStyle = .subheadline,
    priceTextStyle: UIFont.TextStyle = .headline,
    titleNumberOfLines: Int = 2,
    verticalSpacing: CGFloat = 8,
    tagSpacing: CGFloat = 6
  ) {
    self.contentInsets = contentInsets
    self.cornerRadius = cornerRadius
    self.imageCornerRadius = imageCornerRadius
    self.titleTextStyle = titleTextStyle
    self.priceTextStyle = priceTextStyle
    self.titleNumberOfLines = titleNumberOfLines
    self.verticalSpacing = verticalSpacing
    self.tagSpacing = tagSpacing
  }

  /// Recommended collection item size for a two-column product grid.
  public static var defaultItemSize: CGSize { CGSize(width: 168, height: 248) }
}

/// Combined configuration for ``FKSettingsProfileCell``.
public struct FKSettingsProfileCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  public var titleTextStyle: UIFont.TextStyle
  public var accountTextStyle: UIFont.TextStyle
  public var showsDisclosureIndicator: Bool

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .l,
    titleTextStyle: UIFont.TextStyle = .body,
    accountTextStyle: UIFont.TextStyle = .subheadline,
    showsDisclosureIndicator: Bool = true
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.titleTextStyle = titleTextStyle
    self.accountTextStyle = accountTextStyle
    self.showsDisclosureIndicator = showsDisclosureIndicator
  }
}

/// Combined configuration for ``FKFeedContentCell``.
public struct FKFeedContentCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  public var authorTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var bodyTextStyle: UIFont.TextStyle
  /// When set, truncates body text; `nil` allows unlimited lines.
  public var bodyMaxLines: Int?
  /// Vertical spacing between header, body, and image grid sections.
  public var sectionSpacing: CGFloat
  /// Nine-grid layout tokens.
  public var grid: FKFeedImageGridConfiguration

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .s,
    authorTextStyle: UIFont.TextStyle = .headline,
    timestampTextStyle: UIFont.TextStyle = .caption1,
    bodyTextStyle: UIFont.TextStyle = .body,
    bodyMaxLines: Int? = nil,
    sectionSpacing: CGFloat = 8,
    grid: FKFeedImageGridConfiguration = .default
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.authorTextStyle = authorTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.bodyTextStyle = bodyTextStyle
    self.bodyMaxLines = bodyMaxLines
    self.sectionSpacing = sectionSpacing
    self.grid = grid
  }
}

/// Combined configuration for ``FKMediaTileCell``.
public struct FKMediaTileCellConfiguration: Equatable {
  public var contentInsets: UIEdgeInsets
  public var cornerRadius: CGFloat
  public var imageCornerRadius: CGFloat
  public var durationTextStyle: UIFont.TextStyle
  public var durationBackgroundColor: UIColor
  public var durationTextColor: UIColor
  public var selectionTintColor: UIColor
  public var selectionSymbolName: String

  public init(
    contentInsets: UIEdgeInsets = .zero,
    cornerRadius: CGFloat = 8,
    imageCornerRadius: CGFloat = 8,
    durationTextStyle: UIFont.TextStyle = .caption2,
    durationBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.55),
    durationTextColor: UIColor = .white,
    selectionTintColor: UIColor = .systemBlue,
    selectionSymbolName: String = "checkmark.circle.fill"
  ) {
    self.contentInsets = contentInsets
    self.cornerRadius = cornerRadius
    self.imageCornerRadius = imageCornerRadius
    self.durationTextStyle = durationTextStyle
    self.durationBackgroundColor = durationBackgroundColor
    self.durationTextColor = durationTextColor
    self.selectionTintColor = selectionTintColor
    self.selectionSymbolName = selectionSymbolName
  }

  /// Recommended square tile size for photo grids.
  public static var defaultItemSize: CGSize { CGSize(width: 108, height: 108) }
}

/// Combined configuration for ``FKFeedVideoCell``.
public struct FKFeedVideoCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  public var authorTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var captionTextStyle: UIFont.TextStyle
  public var sectionSpacing: CGFloat
  /// Height-to-width multiplier for the embedded player (9/16 ≈ 16:9 video).
  public var videoHeightMultiplier: CGFloat
  public var videoCornerRadius: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .s,
    authorTextStyle: UIFont.TextStyle = .headline,
    timestampTextStyle: UIFont.TextStyle = .caption1,
    captionTextStyle: UIFont.TextStyle = .body,
    sectionSpacing: CGFloat = 8,
    videoHeightMultiplier: CGFloat = 9.0 / 16.0,
    videoCornerRadius: CGFloat = 8
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.authorTextStyle = authorTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.captionTextStyle = captionTextStyle
    self.sectionSpacing = sectionSpacing
    self.videoHeightMultiplier = videoHeightMultiplier
    self.videoCornerRadius = videoCornerRadius
  }
}

/// Combined configuration for ``FKAddressListCell``.
public struct FKAddressListCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var recipientTextStyle: UIFont.TextStyle
  public var phoneTextStyle: UIFont.TextStyle
  public var addressTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat
  public var selectionSymbolSide: CGFloat
  public var selectionSymbolName: String
  public var selectionTintColor: UIColor
  public var defaultLeadingSymbolName: String
  public var defaultTagTitle: String
  public var defaultTagVariant: FKTagVariant

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    recipientTextStyle: UIFont.TextStyle = .body,
    phoneTextStyle: UIFont.TextStyle = .subheadline,
    addressTextStyle: UIFont.TextStyle = .subheadline,
    leadingSymbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide,
    selectionSymbolSide: CGFloat = 22,
    selectionSymbolName: String = "checkmark.circle.fill",
    selectionTintColor: UIColor = .systemBlue,
    defaultLeadingSymbolName: String = "location.fill",
    defaultTagTitle: String = "Default",
    defaultTagVariant: FKTagVariant = .brand
  ) {
    self.table = table
    self.recipientTextStyle = recipientTextStyle
    self.phoneTextStyle = phoneTextStyle
    self.addressTextStyle = addressTextStyle
    self.leadingSymbolSide = leadingSymbolSide
    self.selectionSymbolSide = selectionSymbolSide
    self.selectionSymbolName = selectionSymbolName
    self.selectionTintColor = selectionTintColor
    self.defaultLeadingSymbolName = defaultLeadingSymbolName
    self.defaultTagTitle = defaultTagTitle
    self.defaultTagVariant = defaultTagVariant
  }
}

/// Combined configuration for ``FKPaymentMethodCell``.
public struct FKPaymentMethodCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat
  public var selectionSymbolSide: CGFloat
  public var selectionSymbolName: String
  public var selectionTintColor: UIColor

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline,
    leadingSymbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide,
    selectionSymbolSide: CGFloat = 22,
    selectionSymbolName: String = "checkmark.circle.fill",
    selectionTintColor: UIColor = .systemBlue
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.leadingSymbolSide = leadingSymbolSide
    self.selectionSymbolSide = selectionSymbolSide
    self.selectionSymbolName = selectionSymbolName
    self.selectionTintColor = selectionTintColor
  }
}

/// Combined configuration for ``FKCommentThreadCell``.
public struct FKCommentThreadCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  /// Leading inset added per nesting depth level.
  public var indentWidth: CGFloat
  /// Maximum depth used when computing indent (deeper items share the same inset).
  public var maxDepth: Int
  public var authorTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var bodyTextStyle: UIFont.TextStyle
  public var replySummaryTextStyle: UIFont.TextStyle
  /// When set, truncates body text; `nil` allows unlimited lines.
  public var bodyMaxLines: Int?
  public var sectionSpacing: CGFloat
  /// Vertical connector line shown when ``FKCommentThreadItem/depth`` is greater than zero.
  public var threadLineColor: UIColor

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .xs,
    indentWidth: CGFloat = 24,
    maxDepth: Int = 4,
    authorTextStyle: UIFont.TextStyle = .subheadline,
    timestampTextStyle: UIFont.TextStyle = .caption2,
    bodyTextStyle: UIFont.TextStyle = .body,
    replySummaryTextStyle: UIFont.TextStyle = .caption1,
    bodyMaxLines: Int? = nil,
    sectionSpacing: CGFloat = 4,
    threadLineColor: UIColor = .separator
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.indentWidth = indentWidth
    self.maxDepth = max(0, maxDepth)
    self.authorTextStyle = authorTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.bodyTextStyle = bodyTextStyle
    self.replySummaryTextStyle = replySummaryTextStyle
    self.bodyMaxLines = bodyMaxLines
    self.sectionSpacing = sectionSpacing
    self.threadLineColor = threadLineColor
  }
}

/// Combined configuration for ``FKTimelineEventCell``.
public struct FKTimelineEventCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var connector: FKTimelineConnectorView.Configuration
  public var connectorColumnWidth: CGFloat
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var captionTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    connector: FKTimelineConnectorView.Configuration = .init(),
    connectorColumnWidth: CGFloat = 36,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline,
    captionTextStyle: UIFont.TextStyle = .caption1,
    timestampTextStyle: UIFont.TextStyle = .caption2
  ) {
    self.table = table
    self.connector = connector
    self.connectorColumnWidth = connectorColumnWidth
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.captionTextStyle = captionTextStyle
    self.timestampTextStyle = timestampTextStyle
  }
}

/// Combined configuration for ``FKSearchResultCell``.
public struct FKSearchResultCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var breadcrumbTextStyle: UIFont.TextStyle
  public var highlightColor: UIColor
  public var categoryTagVariant: FKTagVariant

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    breadcrumbTextStyle: UIFont.TextStyle = .caption1,
    highlightColor: UIColor = .systemBlue,
    categoryTagVariant: FKTagVariant = .neutral
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.breadcrumbTextStyle = breadcrumbTextStyle
    self.highlightColor = highlightColor
    self.categoryTagVariant = categoryTagVariant
  }
}

/// Combined configuration for ``FKReviewListCell``.
public struct FKReviewListCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  public var authorTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var reviewTextStyle: UIFont.TextStyle
  public var reviewMaxLines: Int?
  public var sectionSpacing: CGFloat
  public var photoSide: CGFloat
  public var photoCornerRadius: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .s,
    authorTextStyle: UIFont.TextStyle = .subheadline,
    timestampTextStyle: UIFont.TextStyle = .caption2,
    reviewTextStyle: UIFont.TextStyle = .body,
    reviewMaxLines: Int? = 3,
    sectionSpacing: CGFloat = 8,
    photoSide: CGFloat = 56,
    photoCornerRadius: CGFloat = 8
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.authorTextStyle = authorTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.reviewTextStyle = reviewTextStyle
    self.reviewMaxLines = reviewMaxLines
    self.sectionSpacing = sectionSpacing
    self.photoSide = photoSide
    self.photoCornerRadius = photoCornerRadius
  }
}

/// Combined configuration for ``FKFileAttachmentCell``.
public struct FKFileAttachmentCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat
  public var defaultSymbolName: String

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .caption1,
    leadingSymbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide,
    defaultSymbolName: String = "doc.fill"
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.leadingSymbolSide = leadingSymbolSide
    self.defaultSymbolName = defaultSymbolName
  }
}

/// Combined configuration for ``FKCartLineItemCell``.
public struct FKCartLineItemCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var variantTextStyle: UIFont.TextStyle
  public var priceTextStyle: UIFont.TextStyle
  public var originalPriceTextStyle: UIFont.TextStyle
  public var quantityTextStyle: UIFont.TextStyle
  public var thumbnailSide: CGFloat
  public var thumbnailCornerRadius: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    variantTextStyle: UIFont.TextStyle = .caption1,
    priceTextStyle: UIFont.TextStyle = .headline,
    originalPriceTextStyle: UIFont.TextStyle = .caption1,
    quantityTextStyle: UIFont.TextStyle = .caption1,
    thumbnailSide: CGFloat = 72,
    thumbnailCornerRadius: CGFloat = 8
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.variantTextStyle = variantTextStyle
    self.priceTextStyle = priceTextStyle
    self.originalPriceTextStyle = originalPriceTextStyle
    self.quantityTextStyle = quantityTextStyle
    self.thumbnailSide = thumbnailSide
    self.thumbnailCornerRadius = thumbnailCornerRadius
  }
}

/// Combined configuration for ``FKCartQuantityCell``.
public struct FKCartQuantityCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var variantTextStyle: UIFont.TextStyle
  public var priceTextStyle: UIFont.TextStyle
  public var thumbnailSide: CGFloat
  public var thumbnailCornerRadius: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    variantTextStyle: UIFont.TextStyle = .caption1,
    priceTextStyle: UIFont.TextStyle = .headline,
    thumbnailSide: CGFloat = 72,
    thumbnailCornerRadius: CGFloat = 8
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.variantTextStyle = variantTextStyle
    self.priceTextStyle = priceTextStyle
    self.thumbnailSide = thumbnailSide
    self.thumbnailCornerRadius = thumbnailCornerRadius
  }
}

/// Combined configuration for ``FKUserSelectCell``.
public struct FKUserSelectCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var leading: FKUserListLeadingConfiguration
  public var selectionSymbolSide: CGFloat
  public var unselectedSymbolName: String
  public var selectedSymbolName: String
  public var unselectedTintColor: UIColor
  public var selectionTintColor: UIColor

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    leading: FKUserListLeadingConfiguration = .init(),
    selectionSymbolSide: CGFloat = 22,
    unselectedSymbolName: String = "circle",
    selectedSymbolName: String = "checkmark.circle.fill",
    unselectedTintColor: UIColor = .tertiaryLabel,
    selectionTintColor: UIColor = .systemBlue
  ) {
    self.table = table
    self.leading = leading
    self.selectionSymbolSide = selectionSymbolSide
    self.unselectedSymbolName = unselectedSymbolName
    self.selectedSymbolName = selectedSymbolName
    self.unselectedTintColor = unselectedTintColor
    self.selectionTintColor = selectionTintColor
  }
}

/// Combined configuration for ``FKInlineToggleCell``.
public struct FKInlineToggleCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var leadingSymbolSide: CGFloat

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline,
    leadingSymbolSide: CGFloat = FKIconViewSize.l.side
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.leadingSymbolSide = leadingSymbolSide
  }
}

/// Combined configuration for ``FKTagPickerCell``.
public struct FKTagPickerCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var sectionSpacing: CGFloat
  public var chipGroup: FKChipGroupConfiguration

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .subheadline,
    sectionSpacing: CGFloat = 8,
    chipGroup: FKChipGroupConfiguration = .init()
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.sectionSpacing = sectionSpacing
    self.chipGroup = chipGroup
  }
}

/// Combined configuration for ``FKRatingInputCell``.
public struct FKRatingInputCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
  }
}

/// Combined configuration for ``FKInviteCodeCell``.
public struct FKInviteCodeCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var shareSymbolName: String
  public var shareSymbolSide: CGFloat
  public var shareTintColor: UIColor

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline,
    shareSymbolName: String = "square.and.arrow.up",
    shareSymbolSide: CGFloat = 22,
    shareTintColor: UIColor = .systemBlue
  ) {
    self.table = table
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.shareSymbolName = shareSymbolName
    self.shareSymbolSide = shareSymbolSide
    self.shareTintColor = shareTintColor
  }
}
