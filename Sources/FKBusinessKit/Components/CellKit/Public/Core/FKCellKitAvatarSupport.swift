import FKUIKit

/// Shared ``FKAvatar`` configuration for CellKit list rows with an adjacent title column.
enum FKCellKitAvatarSupport {
  /// Applies lean list-row chrome: no hit-area expansion, no press highlight, and no skeleton overlay.
  @MainActor
  static func applyListRowChrome(
    to avatar: FKAvatar,
    size: FKAvatarSize,
    isVerified: Bool = false,
    presenceState: FKPresenceState? = nil,
    showsPresenceIndicator: Bool = false
  ) {
    avatar.isUserInteractionEnabled = false

    var configuration = avatar.configuration
    configuration.layout.size = size
    configuration.appearance.showsVerifiedBadge = isVerified
    configuration.appearance.prefersSkeletonLoadingIndicator = false
    configuration.interaction.expandsHitAreaToMinimumSize = false
    configuration.interaction.highlightsOnPress = false

    let resolvedShowsPresence = showsPresenceIndicator
      && presenceState != nil
      && !isVerified
    configuration.showsPresenceIndicator = resolvedShowsPresence
    configuration.presenceState = resolvedShowsPresence ? presenceState : nil
    avatar.configuration = configuration
  }
}
