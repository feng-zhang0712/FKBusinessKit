import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKUserListCell`` and ListKit custom rows.
public struct FKUserListItem: Equatable, Sendable {
  /// Stable row identity (also used as ``FKListItemID`` raw value).
  public var id: String
  /// Primary title (display name).
  public var displayName: String
  /// Optional secondary line.
  public var subtitle: String?
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Optional presence indicator state.
  public var presenceState: FKPresenceState?
  /// Unread count rendered as a numeric badge on the avatar when greater than zero.
  public var unreadCount: Int
  /// Optional role or category tag in the trailing column.
  public var roleTag: FKTagDisplayModel?
  /// Relative or absolute time string in the trailing column.
  public var timestampText: String?
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a user list row item.
  public init(
    id: String,
    displayName: String,
    subtitle: String? = nil,
    avatarURL: URL? = nil,
    presenceState: FKPresenceState? = nil,
    unreadCount: Int = 0,
    roleTag: FKTagDisplayModel? = nil,
    timestampText: String? = nil,
    isVerified: Bool = false
  ) {
    self.id = id
    self.displayName = displayName
    self.subtitle = subtitle
    self.avatarURL = avatarURL
    self.presenceState = presenceState
    self.unreadCount = unreadCount
    self.roleTag = roleTag
    self.timestampText = timestampText
    self.isVerified = isVerified
  }
}

extension FKUserListItem: FKListImagePrefetchProviding {
  /// Avatar warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let avatarURL else { return [] }
    let side = FKAvatarSize.s.diameter * 2
    return [
      FKListImagePrefetchRequest(
        url: avatarURL,
        targetSize: CGSize(width: side, height: side)
      ),
    ]
  }
}
