import Foundation
import UIKit
import FKUIKit

/// Appearance tokens for ``FKUserListLeadingView``.
public struct FKUserListLeadingConfiguration: Equatable {
  /// Avatar diameter preset.
  public var avatarSize: FKAvatarSize
  /// Horizontal spacing between avatar and text stack.
  public var spacing: CGFloat
  /// When `true`, renders ``FKPresenceIndicator`` when a presence state is provided.
  public var showsPresenceIndicator: Bool
  /// Title text style.
  public var titleTextStyle: UIFont.TextStyle
  /// Subtitle text style.
  public var subtitleTextStyle: UIFont.TextStyle

  /// Creates leading layout configuration.
  public init(
    avatarSize: FKAvatarSize = .s,
    spacing: CGFloat = FKCellKitLayoutMetrics.interPartSpacing,
    showsPresenceIndicator: Bool = true,
    titleTextStyle: UIFont.TextStyle = .body,
    subtitleTextStyle: UIFont.TextStyle = .subheadline
  ) {
    self.avatarSize = avatarSize
    self.spacing = spacing
    self.showsPresenceIndicator = showsPresenceIndicator
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
  }
}

/// Display payload for ``FKUserListLeadingView/apply(_:)``.
public struct FKUserListLeadingDisplayModel: Equatable, Sendable {
  public var displayName: String
  public var subtitle: String?
  public var avatarURL: URL?
  public var presenceState: FKPresenceState?
  public var isVerified: Bool

  public init(
    displayName: String,
    subtitle: String? = nil,
    avatarURL: URL? = nil,
    presenceState: FKPresenceState? = nil,
    isVerified: Bool = false
  ) {
    self.displayName = displayName
    self.subtitle = subtitle
    self.avatarURL = avatarURL
    self.presenceState = presenceState
    self.isVerified = isVerified
  }
}
