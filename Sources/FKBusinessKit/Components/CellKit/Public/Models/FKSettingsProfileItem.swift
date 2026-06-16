import CoreGraphics
import Foundation
import FKUIKit

/// View model for ``FKSettingsProfileCell`` (settings account header row).
public struct FKSettingsProfileItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Profile display name.
  public var displayName: String
  /// Secondary account line (phone, email, handle).
  public var accountText: String?
  /// Remote avatar URL.
  public var avatarURL: URL?
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a settings profile row item.
  public init(
    id: String,
    displayName: String,
    accountText: String? = nil,
    avatarURL: URL? = nil,
    isVerified: Bool = false
  ) {
    self.id = id
    self.displayName = displayName
    self.accountText = accountText
    self.avatarURL = avatarURL
    self.isVerified = isVerified
  }
}

extension FKSettingsProfileItem: FKListImagePrefetchProviding {
  /// Avatar warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let avatarURL else { return [] }
    let side = FKAvatarSize.l.diameter * 2
    return [
      FKListImagePrefetchRequest(
        url: avatarURL,
        targetSize: CGSize(width: side, height: side)
      ),
    ]
  }
}
