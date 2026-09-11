import UIKit
import FKUIKit

/// English default copy for CommentKit chrome. Replace via ``FKCommentKitConfiguration/strings`` for localization.
public struct FKCommentKitStrings: Equatable, Sendable {
  public var like: String
  public var unlike: String
  public var reply: String
  public var more: String
  public var copy: String
  public var delete: String
  public var report: String
  public var send: String
  public var composerPlaceholder: String
  public var replyToFormat: String
  public var viewRepliesFormat: String
  public var hideReplies: String
  /// Shown in place of ``viewRepliesFormat`` while nested replies load.
  public var loadingReplies: String
  public var cancelReply: String
  /// Cancel title for action sheets (more menu).
  public var cancel: String
  /// Compact expand label used by ``FKCommentLayoutPreset/compact`` when more replies remain.
  public var expandMore: String
  /// In-body “read more” affordance when ``FKCommentRowCellConfiguration/usesExpandableBody`` is `true`.
  public var expandBody: String
  /// In-body “show less” affordance when the body is expanded.
  public var collapseBody: String

  /// Creates string tokens. Defaults are English.
  public init(
    like: String = "Like",
    unlike: String = "Unlike",
    reply: String = "Reply",
    more: String = "More",
    copy: String = "Copy",
    delete: String = "Delete",
    report: String = "Report",
    send: String = "Send",
    composerPlaceholder: String = "Add a comment…",
    replyToFormat: String = "Replying to %@",
    viewRepliesFormat: String = "View %d replies",
    hideReplies: String = "Hide replies",
    loadingReplies: String = "Loading…",
    cancelReply: String = "Cancel",
    cancel: String = "Cancel",
    expandMore: String = "Expand more",
    expandBody: String = "Read more",
    collapseBody: String = "Show less"
  ) {
    self.like = like
    self.unlike = unlike
    self.reply = reply
    self.more = more
    self.copy = copy
    self.delete = delete
    self.report = report
    self.send = send
    self.composerPlaceholder = composerPlaceholder
    self.replyToFormat = replyToFormat
    self.viewRepliesFormat = viewRepliesFormat
    self.hideReplies = hideReplies
    self.loadingReplies = loadingReplies
    self.cancelReply = cancelReply
    self.cancel = cancel
    self.expandMore = expandMore
    self.expandBody = expandBody
    self.collapseBody = collapseBody
  }

  /// Formats ``viewRepliesFormat`` with a reply count.
  public func viewRepliesText(count: Int) -> String {
    String(format: viewRepliesFormat, locale: Locale.current, count)
  }

  /// Formats ``replyToFormat`` with an author display name.
  public func replyToText(displayName: String) -> String {
    String(format: replyToFormat, locale: Locale.current, displayName)
  }
}

/// Feature flags and shared tokens for ``FKCommentListViewController``.
public struct FKCommentKitConfiguration: Equatable {
  /// Row / list layout skeleton. Defaults to ``FKCommentLayoutPreset/standard``.
  public var layoutPreset: FKCommentLayoutPreset
  public var strings: FKCommentKitStrings
  public var showsLikeAction: Bool
  public var showsReplyAction: Bool
  public var showsMoreAction: Bool
  public var showsReportAction: Bool
  public var showsCopyAction: Bool
  /// When `true` (default), tapping More presents the built-in action sheet. When `false`, the kit only calls ``FKCommentListDelegate/commentList(_:didTapMore:sourceView:)``.
  public var presentsDefaultMoreMenu: Bool
  /// Extra actions appended to the built-in more sheet (ignored when ``presentsDefaultMoreMenu`` is `false`).
  public var additionalMoreActions: [FKCommentCustomMoreAction]
  /// When `false`, hides the bottom composer (read-only comment lists).
  public var showsComposer: Bool
  /// When `true`, tapping a comment row (outside like / reply / more / author / expand controls) begins a reply.
  public var beginsReplyOnRowTap: Bool
  public var isPullToRefreshEnabled: Bool
  public var isLoadMoreEnabled: Bool
  /// Maximum reply rows kept under a parent when expanding (App may still return fewer).
  public var maxExpandedReplies: Int
  /// Minimum `replyCount` before the expand affordance appears.
  public var expandAffordanceMinimumReplyCount: Int
  public var row: FKCommentRowCellConfiguration
  public var actionBar: FKCommentActionBarConfiguration
  public var composer: FKCommentComposerConfiguration

  /// Creates a kit configuration.
  public init(
    layoutPreset: FKCommentLayoutPreset = .standard,
    strings: FKCommentKitStrings = .init(),
    showsLikeAction: Bool = true,
    showsReplyAction: Bool = true,
    showsMoreAction: Bool = true,
    showsReportAction: Bool = true,
    showsCopyAction: Bool = true,
    presentsDefaultMoreMenu: Bool = true,
    additionalMoreActions: [FKCommentCustomMoreAction] = [],
    showsComposer: Bool = true,
    beginsReplyOnRowTap: Bool = true,
    isPullToRefreshEnabled: Bool = true,
    isLoadMoreEnabled: Bool = true,
    maxExpandedReplies: Int = 50,
    expandAffordanceMinimumReplyCount: Int = 1,
    row: FKCommentRowCellConfiguration = .init(),
    actionBar: FKCommentActionBarConfiguration = .init(),
    composer: FKCommentComposerConfiguration = .init()
  ) {
    self.layoutPreset = layoutPreset
    self.strings = strings
    self.showsLikeAction = showsLikeAction
    self.showsReplyAction = showsReplyAction
    self.showsMoreAction = showsMoreAction
    self.showsReportAction = showsReportAction
    self.showsCopyAction = showsCopyAction
    self.presentsDefaultMoreMenu = presentsDefaultMoreMenu
    self.additionalMoreActions = additionalMoreActions
    self.showsComposer = showsComposer
    self.beginsReplyOnRowTap = beginsReplyOnRowTap
    self.isPullToRefreshEnabled = isPullToRefreshEnabled
    self.isLoadMoreEnabled = isLoadMoreEnabled
    self.maxExpandedReplies = max(1, maxExpandedReplies)
    self.expandAffordanceMinimumReplyCount = max(0, expandAffordanceMinimumReplyCount)
    self.row = row
    self.actionBar = actionBar
    self.composer = composer
  }
}

/// Appearance for comment row cells (``standard`` and ``compact`` share these tokens).
public struct FKCommentRowCellConfiguration: Equatable {
  public var table: FKCellKitTableCellConfiguration
  public var avatarSize: FKAvatarSize
  /// Avatar size for indented reply rows; `nil` uses ``avatarSize``.
  public var replyAvatarSize: FKAvatarSize?
  public var indentWidth: CGFloat
  public var maxDepth: Int
  public var authorTextStyle: UIFont.TextStyle
  public var timestampTextStyle: UIFont.TextStyle
  public var bodyTextStyle: UIFont.TextStyle
  public var replyToTextStyle: UIFont.TextStyle
  public var expandTextStyle: UIFont.TextStyle
  /// Optional weight override for author (Dynamic Type size still follows ``authorTextStyle``).
  public var authorFontWeight: UIFont.Weight?
  /// Optional weight override for timestamp / compact meta time.
  public var timestampFontWeight: UIFont.Weight?
  /// Optional weight override for the comment body.
  public var bodyFontWeight: UIFont.Weight?
  /// Optional weight override for reply-to labels.
  public var replyToFontWeight: UIFont.Weight?
  /// Optional weight override for expand / collapse replies.
  public var expandFontWeight: UIFont.Weight?
  public var bodyMaxLines: Int?
  /// When `true` and ``bodyMaxLines`` is set, body uses ``FKExpandableText`` instead of hard truncation.
  public var usesExpandableBody: Bool
  /// Vertical gap between stacked row sections (author / body / meta / actions / expand).
  public var sectionSpacing: CGFloat
  /// Horizontal gap between avatar and the text column.
  public var contentRowSpacing: CGFloat
  /// Gap inside the author header / author▷reply-to row.
  public var headerInlineSpacing: CGFloat
  /// Gap inside the compact meta row (time · Reply).
  public var metaInlineSpacing: CGFloat
  /// Gap between expand spinner slot and Expand title.
  public var expandRowSpacing: CGFloat
  public var threadLineColor: UIColor
  /// When `false`, nested rows skip the vertical thread line (typical for ``compact``).
  public var showsThreadLine: Bool
  public var authorTextColor: UIColor
  public var metaTextColor: UIColor
  /// Comment body text color.
  public var bodyTextColor: UIColor
  /// Expand / collapse replies control color (defaults to system blue).
  public var expandTextColor: UIColor
  /// Color for in-body “more / less” affordances when ``usesExpandableBody`` is `true`.
  public var expandableBodyActionColor: UIColor
  /// Vertical gap above / below the in-body expand / collapse action line (paragraph spacing).
  public var expandableBodyActionSpacing: CGFloat
  /// Chevron between author and reply-to (compact nested rows).
  public var replyToChevronIcon: FKBusinessKitIcon
  /// Chevron shown while replies are collapsed.
  public var expandMoreIcon: FKBusinessKitIcon
  /// Chevron shown while replies are expanded.
  public var expandLessIcon: FKBusinessKitIcon
  /// Point size for ``replyToChevronIcon`` / expand chevrons.
  public var chevronIconPointSize: CGFloat
  /// When `true` (default), compact rows show the meta stripe (like · reply · more · timestamp).
  public var showsMetaStripe: Bool
  /// When `true` (default), compact meta rows show the timestamp (also requires ``showsMetaStripe``).
  public var showsTimestamp: Bool
  /// When `true` (default), compact meta rows show the Reply control (also requires ``FKCommentKitConfiguration/showsReplyAction``).
  public var showsMetaReplyButton: Bool

  public init(
    table: FKCellKitTableCellConfiguration = .flatRow,
    avatarSize: FKAvatarSize = .s,
    indentWidth: CGFloat = 24,
    maxDepth: Int = 1,
    authorTextStyle: UIFont.TextStyle = .subheadline,
    timestampTextStyle: UIFont.TextStyle = .caption2,
    bodyTextStyle: UIFont.TextStyle = .body,
    replyToTextStyle: UIFont.TextStyle = .caption1,
    expandTextStyle: UIFont.TextStyle = .footnote,
    authorFontWeight: UIFont.Weight? = nil,
    timestampFontWeight: UIFont.Weight? = nil,
    bodyFontWeight: UIFont.Weight? = nil,
    replyToFontWeight: UIFont.Weight? = nil,
    expandFontWeight: UIFont.Weight? = nil,
    bodyMaxLines: Int? = 6,
    usesExpandableBody: Bool = true,
    sectionSpacing: CGFloat = 4,
    contentRowSpacing: CGFloat = 10,
    headerInlineSpacing: CGFloat = 8,
    metaInlineSpacing: CGFloat = 8,
    expandRowSpacing: CGFloat = 6,
    threadLineColor: UIColor = .separator,
    replyAvatarSize: FKAvatarSize? = nil,
    authorTextColor: UIColor = .label,
    metaTextColor: UIColor = .secondaryLabel,
    bodyTextColor: UIColor = .label,
    expandTextColor: UIColor = .systemBlue,
    expandableBodyActionColor: UIColor = .systemBlue,
    expandableBodyActionSpacing: CGFloat = 6,
    replyToChevronIcon: FKBusinessKitIcon = .chevronRight,
    expandMoreIcon: FKBusinessKitIcon = .chevronDown,
    expandLessIcon: FKBusinessKitIcon = .chevronUp,
    chevronIconPointSize: CGFloat = 10,
    showsThreadLine: Bool = true,
    showsMetaStripe: Bool = true,
    showsTimestamp: Bool = true,
    showsMetaReplyButton: Bool = true
  ) {
    self.table = table
    self.avatarSize = avatarSize
    self.replyAvatarSize = replyAvatarSize
    self.indentWidth = indentWidth
    self.maxDepth = max(0, maxDepth)
    self.authorTextStyle = authorTextStyle
    self.timestampTextStyle = timestampTextStyle
    self.bodyTextStyle = bodyTextStyle
    self.replyToTextStyle = replyToTextStyle
    self.expandTextStyle = expandTextStyle
    self.authorFontWeight = authorFontWeight
    self.timestampFontWeight = timestampFontWeight
    self.bodyFontWeight = bodyFontWeight
    self.replyToFontWeight = replyToFontWeight
    self.expandFontWeight = expandFontWeight
    self.bodyMaxLines = bodyMaxLines
    self.usesExpandableBody = usesExpandableBody
    self.sectionSpacing = sectionSpacing
    self.contentRowSpacing = max(0, contentRowSpacing)
    self.headerInlineSpacing = max(0, headerInlineSpacing)
    self.metaInlineSpacing = max(0, metaInlineSpacing)
    self.expandRowSpacing = max(0, expandRowSpacing)
    self.threadLineColor = threadLineColor
    self.showsThreadLine = showsThreadLine
    self.authorTextColor = authorTextColor
    self.metaTextColor = metaTextColor
    self.bodyTextColor = bodyTextColor
    self.expandTextColor = expandTextColor
    self.expandableBodyActionColor = expandableBodyActionColor
    self.expandableBodyActionSpacing = max(0, expandableBodyActionSpacing)
    self.replyToChevronIcon = replyToChevronIcon
    self.expandMoreIcon = expandMoreIcon
    self.expandLessIcon = expandLessIcon
    self.chevronIconPointSize = max(6, chevronIconPointSize)
    self.showsMetaStripe = showsMetaStripe
    self.showsTimestamp = showsTimestamp
    self.showsMetaReplyButton = showsMetaReplyButton
  }

  /// Dynamic Type font for the author label.
  public func resolvedAuthorFont() -> UIFont {
    FKCommentTypography.font(for: authorTextStyle, weight: authorFontWeight)
  }

  /// Dynamic Type font for timestamp / compact meta time.
  public func resolvedTimestampFont() -> UIFont {
    FKCommentTypography.font(for: timestampTextStyle, weight: timestampFontWeight)
  }

  /// Dynamic Type font for the comment body.
  public func resolvedBodyFont() -> UIFont {
    FKCommentTypography.font(for: bodyTextStyle, weight: bodyFontWeight)
  }

  /// Dynamic Type font for reply-to labels.
  public func resolvedReplyToFont() -> UIFont {
    FKCommentTypography.font(for: replyToTextStyle, weight: replyToFontWeight)
  }

  /// Dynamic Type font for expand / collapse replies.
  public func resolvedExpandFont() -> UIFont {
    FKCommentTypography.font(for: expandTextStyle, weight: expandFontWeight)
  }

  /// Dynamic Type font for in-body expand / collapse action text.
  public func resolvedExpandableBodyActionFont() -> UIFont {
    FKCommentTypography.font(for: expandTextStyle, weight: expandFontWeight)
  }
}

/// Appearance and icons for ``FKCommentActionBarView`` / compact action rail.
public struct FKCommentActionBarConfiguration: Equatable {
  public var spacing: CGFloat
  public var buttonTintColor: UIColor
  public var likedTintColor: UIColor
  /// Unliked state icon (defaults to ``FKBusinessKitIcon/heartOutline``).
  public var likeIcon: FKBusinessKitIcon
  /// Liked state icon (defaults to ``FKBusinessKitIcon/heartFill``).
  public var likedIcon: FKBusinessKitIcon
  /// Reply icon (defaults to ``FKBusinessKitIcon/chat``).
  public var replyIcon: FKBusinessKitIcon
  /// More icon (defaults to ``FKBusinessKitIcon/moreHorizontal``).
  public var moreIcon: FKBusinessKitIcon
  /// Optional app-provided like icon (SVG/PNG/`UIImage`); overrides ``likeIcon`` when non-`nil`.
  public var likeImage: UIImage?
  /// Optional app-provided liked icon; overrides ``likedIcon`` when non-`nil`.
  public var likedImage: UIImage?
  /// Optional app-provided reply icon; overrides ``replyIcon`` when non-`nil`.
  public var replyImage: UIImage?
  /// Optional app-provided more icon; overrides ``moreIcon`` when non-`nil`.
  public var moreImage: UIImage?
  public var contentTextStyle: UIFont.TextStyle
  /// Optional weight override for like count / reply title.
  public var contentFontWeight: UIFont.Weight?
  /// Drawn icon side length in points.
  public var iconPointSize: CGFloat
  /// Compact strip height when any action is visible.
  public var minimumHeight: CGFloat
  /// When `true` (default), shows the like count beside the like icon when count &gt; 0 (or ``FKCommentItem/likeCountText`` is set).
  public var showsLikeCount: Bool
  /// When `true`, the reply control shows ``FKCommentKitStrings/reply`` beside the icon.
  public var showsReplyTitle: Bool

  /// Gap between icon and title inside like / reply controls.
  public var iconTitleSpacing: CGFloat

  public init(
    spacing: CGFloat = 16,
    buttonTintColor: UIColor = .secondaryLabel,
    likedTintColor: UIColor = .systemRed,
    likeIcon: FKBusinessKitIcon = .heartOutline,
    likedIcon: FKBusinessKitIcon = .heartFill,
    replyIcon: FKBusinessKitIcon = .chat,
    moreIcon: FKBusinessKitIcon = .moreHorizontal,
    likeImage: UIImage? = nil,
    likedImage: UIImage? = nil,
    replyImage: UIImage? = nil,
    moreImage: UIImage? = nil,
    contentTextStyle: UIFont.TextStyle = .footnote,
    contentFontWeight: UIFont.Weight? = nil,
    iconPointSize: CGFloat = 18,
    minimumHeight: CGFloat = 30,
    iconTitleSpacing: CGFloat = 6,
    showsLikeCount: Bool = true,
    showsReplyTitle: Bool = true
  ) {
    self.spacing = spacing
    self.buttonTintColor = buttonTintColor
    self.likedTintColor = likedTintColor
    self.likeIcon = likeIcon
    self.likedIcon = likedIcon
    self.replyIcon = replyIcon
    self.moreIcon = moreIcon
    self.likeImage = likeImage
    self.likedImage = likedImage
    self.replyImage = replyImage
    self.moreImage = moreImage
    self.contentTextStyle = contentTextStyle
    self.contentFontWeight = contentFontWeight
    self.iconPointSize = max(8, iconPointSize)
    self.minimumHeight = max(16, minimumHeight)
    self.iconTitleSpacing = max(0, iconTitleSpacing)
    self.showsLikeCount = showsLikeCount
    self.showsReplyTitle = showsReplyTitle
  }

  public static func == (lhs: FKCommentActionBarConfiguration, rhs: FKCommentActionBarConfiguration) -> Bool {
    lhs.spacing == rhs.spacing
      && lhs.buttonTintColor == rhs.buttonTintColor
      && lhs.likedTintColor == rhs.likedTintColor
      && lhs.likeIcon == rhs.likeIcon
      && lhs.likedIcon == rhs.likedIcon
      && lhs.replyIcon == rhs.replyIcon
      && lhs.moreIcon == rhs.moreIcon
      && lhs.likeImage === rhs.likeImage
      && lhs.likedImage === rhs.likedImage
      && lhs.replyImage === rhs.replyImage
      && lhs.moreImage === rhs.moreImage
      && lhs.contentTextStyle == rhs.contentTextStyle
      && lhs.contentFontWeight == rhs.contentFontWeight
      && lhs.iconPointSize == rhs.iconPointSize
      && lhs.minimumHeight == rhs.minimumHeight
      && lhs.iconTitleSpacing == rhs.iconTitleSpacing
      && lhs.showsLikeCount == rhs.showsLikeCount
      && lhs.showsReplyTitle == rhs.showsReplyTitle
  }

  /// Dynamic Type font for action titles / counts.
  public func resolvedContentFont() -> UIFont {
    FKCommentTypography.font(for: contentTextStyle, weight: contentFontWeight)
  }

  /// Resolves the like glyph for the current liked state (custom image or catalog icon).
  @MainActor
  public func resolvedLikeImage(isLiked: Bool) -> UIImage? {
    if isLiked {
      return Self.templateImage(likedImage, fallback: likedIcon, pointSize: iconPointSize)
    }
    return Self.templateImage(likeImage, fallback: likeIcon, pointSize: iconPointSize)
  }

  /// Resolves the reply glyph (custom image or catalog icon).
  @MainActor
  public func resolvedReplyImage() -> UIImage? {
    Self.templateImage(replyImage, fallback: replyIcon, pointSize: iconPointSize)
  }

  /// Resolves the more glyph (custom image or catalog icon).
  @MainActor
  public func resolvedMoreImage() -> UIImage? {
    Self.templateImage(moreImage, fallback: moreIcon, pointSize: iconPointSize)
  }

  @MainActor
  private static func templateImage(
    _ custom: UIImage?,
    fallback: FKBusinessKitIcon,
    pointSize: CGFloat
  ) -> UIImage? {
    if let custom {
      return custom.withRenderingMode(.alwaysTemplate)
    }
    return FKBusinessKitIcons.image(fallback, pointSize: pointSize)
  }
}

/// Appearance for ``FKCommentComposerView``.
public struct FKCommentComposerConfiguration: Equatable {
  public var maxCharacterCount: Int?
  /// Soft cap for composer growth; beyond this the text view scrolls.
  public var maxContentHeight: CGFloat
  public var minimumHeight: CGFloat
  public var horizontalInset: CGFloat
  public var verticalInset: CGFloat
  public var textViewTextStyle: UIFont.TextStyle
  public var sendButtonTextStyle: UIFont.TextStyle
  public var bannerTextStyle: UIFont.TextStyle
  public var textViewFontWeight: UIFont.Weight?
  public var sendButtonFontWeight: UIFont.Weight?
  public var bannerFontWeight: UIFont.Weight?
  public var backgroundColor: UIColor
  public var separatorColor: UIColor
  public var textColor: UIColor
  public var placeholderColor: UIColor
  public var bannerTextColor: UIColor
  public var sendButtonColor: UIColor
  public var cancelReplyButtonColor: UIColor
  /// Vertical gap between reply banner and input row.
  public var stackSpacing: CGFloat
  /// Gap inside the reply banner (label · Cancel).
  public var bannerSpacing: CGFloat
  /// Gap between capsule input and Send.
  public var inputRowSpacing: CGFloat
  /// Rounded capsule behind the text field (``compact`` defaults).
  public var usesCapsuleInput: Bool
  /// Fill for the capsule input well.
  public var capsuleBackgroundColor: UIColor
  /// Corner radius for the capsule input well.
  public var capsuleCornerRadius: CGFloat
  /// When `false`, hides the Send control.
  public var showsSendButton: Bool
  /// When `true` (default), shows the reply-target stripe (author name + Cancel) above the input.
  public var showsReplyTargetBanner: Bool

  public init(
    maxCharacterCount: Int? = 2000,
    maxContentHeight: CGFloat = 120,
    minimumHeight: CGFloat = 52,
    horizontalInset: CGFloat = 12,
    verticalInset: CGFloat = 8,
    textViewTextStyle: UIFont.TextStyle = .body,
    sendButtonTextStyle: UIFont.TextStyle = .headline,
    bannerTextStyle: UIFont.TextStyle = .caption1,
    textViewFontWeight: UIFont.Weight? = nil,
    sendButtonFontWeight: UIFont.Weight? = nil,
    bannerFontWeight: UIFont.Weight? = nil,
    backgroundColor: UIColor = .secondarySystemBackground,
    separatorColor: UIColor = .separator,
    textColor: UIColor = .label,
    placeholderColor: UIColor = .placeholderText,
    bannerTextColor: UIColor = .secondaryLabel,
    sendButtonColor: UIColor = .systemBlue,
    cancelReplyButtonColor: UIColor = .systemBlue,
    stackSpacing: CGFloat = 6,
    bannerSpacing: CGFloat = 8,
    inputRowSpacing: CGFloat = 10,
    usesCapsuleInput: Bool = false,
    capsuleBackgroundColor: UIColor = UIColor(white: 0.96, alpha: 1),
    capsuleCornerRadius: CGFloat = 18,
    showsSendButton: Bool = true,
    showsReplyTargetBanner: Bool = true
  ) {
    self.maxCharacterCount = maxCharacterCount.map { max(1, $0) }
    self.maxContentHeight = max(36, maxContentHeight)
    self.minimumHeight = minimumHeight
    self.horizontalInset = horizontalInset
    self.verticalInset = verticalInset
    self.textViewTextStyle = textViewTextStyle
    self.sendButtonTextStyle = sendButtonTextStyle
    self.bannerTextStyle = bannerTextStyle
    self.textViewFontWeight = textViewFontWeight
    self.sendButtonFontWeight = sendButtonFontWeight
    self.bannerFontWeight = bannerFontWeight
    self.backgroundColor = backgroundColor
    self.separatorColor = separatorColor
    self.textColor = textColor
    self.placeholderColor = placeholderColor
    self.bannerTextColor = bannerTextColor
    self.sendButtonColor = sendButtonColor
    self.cancelReplyButtonColor = cancelReplyButtonColor
    self.stackSpacing = max(0, stackSpacing)
    self.bannerSpacing = max(0, bannerSpacing)
    self.inputRowSpacing = max(0, inputRowSpacing)
    self.usesCapsuleInput = usesCapsuleInput
    self.capsuleBackgroundColor = capsuleBackgroundColor
    self.capsuleCornerRadius = max(0, capsuleCornerRadius)
    self.showsSendButton = showsSendButton
    self.showsReplyTargetBanner = showsReplyTargetBanner
  }

  /// Dynamic Type font for the text view / placeholder.
  public func resolvedTextViewFont() -> UIFont {
    FKCommentTypography.font(for: textViewTextStyle, weight: textViewFontWeight)
  }

  /// Dynamic Type font for Send.
  public func resolvedSendButtonFont() -> UIFont {
    FKCommentTypography.font(for: sendButtonTextStyle, weight: sendButtonFontWeight)
  }

  /// Dynamic Type font for the reply banner / Cancel.
  public func resolvedBannerFont() -> UIFont {
    FKCommentTypography.font(for: bannerTextStyle, weight: bannerFontWeight)
  }
}
