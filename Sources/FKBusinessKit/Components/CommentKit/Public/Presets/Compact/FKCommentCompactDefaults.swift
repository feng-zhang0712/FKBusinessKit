import UIKit
import FKUIKit

/// Default tokens for ``FKCommentLayoutPreset/compact``.
public enum FKCommentCompactDefaults {
  /// Builds a full kit configuration for the compact layout skeleton.
  public static func makeConfiguration() -> FKCommentKitConfiguration {
    FKCommentKitConfiguration(
      layoutPreset: .compact,
      strings: makeStrings(),
      showsLikeAction: true,
      showsReplyAction: true,
      showsMoreAction: true,
      showsReportAction: true,
      showsCopyAction: true,
      showsComposer: true,
      beginsReplyOnRowTap: true,
      isPullToRefreshEnabled: true,
      isLoadMoreEnabled: true,
      maxExpandedReplies: 50,
      expandAffordanceMinimumReplyCount: 1,
      row: makeRowConfiguration(),
      actionBar: makeActionBarConfiguration(),
      composer: makeComposerConfiguration()
    )
  }

  public static func makeStrings() -> FKCommentKitStrings {
    FKCommentKitStrings(
      like: "Like",
      unlike: "Unlike",
      reply: "Reply",
      more: "More",
      copy: "Copy",
      delete: "Delete",
      report: "Report",
      send: "Send",
      composerPlaceholder: "Say something nice…",
      replyToFormat: "%@",
      viewRepliesFormat: "Expand %d replies",
      hideReplies: "Collapse",
      loadingReplies: "Loading…",
      cancelReply: "Cancel",
      cancel: "Cancel",
      expandMore: "Expand more",
      expandBody: "Read more",
      collapseBody: "Show less"
    )
  }

  public static func makeRowConfiguration() -> FKCommentRowCellConfiguration {
    FKCommentRowCellConfiguration(
      table: FKCellKitTableCellConfiguration(
        contentInsets: UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
      ),
      avatarSize: .s,
      indentWidth: 42,
      maxDepth: 1,
      // Match ``standard`` Dynamic Type styles for author / time / body / reply-to / expand.
      authorTextStyle: .subheadline,
      timestampTextStyle: .caption2,
      bodyTextStyle: .body,
      replyToTextStyle: .caption1,
      expandTextStyle: .footnote,
      bodyMaxLines: 8,
      usesExpandableBody: true,
      sectionSpacing: 4,
      contentRowSpacing: 10,
      headerInlineSpacing: 4,
      metaInlineSpacing: 8,
      expandRowSpacing: 6,
      threadLineColor: .clear,
      replyAvatarSize: nil,
      authorTextColor: .secondaryLabel,
      metaTextColor: .secondaryLabel,
      bodyTextColor: .label,
      expandTextColor: .systemBlue,
      expandableBodyActionColor: .systemBlue,
      expandableBodyActionSpacing: 6,
      showsThreadLine: false,
      showsMetaStripe: true,
      showsTimestamp: true,
      showsMetaReplyButton: true
    )
  }

  public static func makeActionBarConfiguration() -> FKCommentActionBarConfiguration {
    FKCommentActionBarConfiguration(
      spacing: 12,
      buttonTintColor: UIColor(white: 0.55, alpha: 1),
      likedTintColor: .systemRed,
      likeIcon: .heartOutline,
      likedIcon: .heartFill,
      replyIcon: .chat,
      moreIcon: .moreHorizontal,
      contentTextStyle: .footnote,
      iconPointSize: 18,
      minimumHeight: 24,
      iconTitleSpacing: 4,
      showsLikeCount: true,
      showsReplyTitle: true
    )
  }

  public static func makeComposerConfiguration() -> FKCommentComposerConfiguration {
    FKCommentComposerConfiguration(
      maxCharacterCount: 2000,
      maxContentHeight: 100,
      minimumHeight: 56,
      horizontalInset: 12,
      verticalInset: 8,
      textViewTextStyle: .body,
      sendButtonTextStyle: .headline,
      bannerTextStyle: .caption1,
      backgroundColor: .systemBackground,
      separatorColor: UIColor(white: 0.9, alpha: 1),
      usesCapsuleInput: true,
      capsuleBackgroundColor: UIColor(white: 0.96, alpha: 1),
      capsuleCornerRadius: 18,
      showsSendButton: true,
      showsReplyTargetBanner: true
    )
  }
}
