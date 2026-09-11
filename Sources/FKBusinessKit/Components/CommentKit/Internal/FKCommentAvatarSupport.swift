import FKUIKit
import UIKit

/// Applies lean ``FKAvatar`` chrome for CommentKit rows (no CellKit dependency).
enum FKCommentAvatarSupport {
  @MainActor
  static func applyListRowChrome(
    to avatar: FKAvatar,
    size: FKAvatarSize,
    isVerified: Bool
  ) {
    avatar.isUserInteractionEnabled = false

    var configuration = avatar.configuration
    configuration.layout.size = size
    configuration.appearance.showsVerifiedBadge = isVerified
    configuration.appearance.prefersSkeletonLoadingIndicator = false
    configuration.interaction.expandsHitAreaToMinimumSize = false
    configuration.interaction.highlightsOnPress = false
    configuration.showsPresenceIndicator = false
    configuration.presenceState = nil
    avatar.configuration = configuration
  }
}
