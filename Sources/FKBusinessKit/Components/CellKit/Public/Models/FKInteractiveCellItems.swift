import Foundation
import FKUIKit

/// Multi-select user row payload for ``FKUserSelectCell``.
public struct FKUserSelectItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Primary title (display name).
  public var displayName: String
  /// Optional secondary line.
  public var subtitle: String?
  /// Remote avatar URL loaded by ``FKAvatar``.
  public var avatarURL: URL?
  /// Optional presence indicator state.
  public var presenceState: FKPresenceState?
  /// When `true`, shows the selected checkmark affordance.
  public var isSelected: Bool
  /// When `true`, shows the verified badge on the avatar.
  public var isVerified: Bool

  /// Creates a user selection row item.
  public init(
    id: String,
    displayName: String,
    subtitle: String? = nil,
    avatarURL: URL? = nil,
    presenceState: FKPresenceState? = nil,
    isSelected: Bool = false,
    isVerified: Bool = false
  ) {
    self.id = id
    self.displayName = displayName
    self.subtitle = subtitle
    self.avatarURL = avatarURL
    self.presenceState = presenceState
    self.isSelected = isSelected
    self.isVerified = isVerified
  }
}

extension FKUserSelectItem: FKListImagePrefetchProviding {
  /// Avatar warm-up targets for ``FKListImagePrefetchHelper``.
  public var listPrefetchImageRequests: [FKListImagePrefetchRequest] {
    guard let avatarURL else { return [] }
    let side = FKAvatarSize.s.diameter * 2
    return [FKListImagePrefetchRequest(url: avatarURL, targetSize: CGSize(width: side, height: side))]
  }
}

/// Business row with trailing switch for ``FKInlineToggleCell``.
public struct FKInlineToggleItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Primary title.
  public var title: String
  /// Optional subtitle.
  public var subtitle: String?
  /// Optional leading SF Symbol name.
  public var leadingSymbolName: String?
  /// Switch on-state mirrored from the view model.
  public var isOn: Bool
  /// Handler id registered in ``FKListSwitchHandlerRegistry``.
  public var switchHandlerID: String
  /// When `false`, disables user interaction on the switch.
  public var isEnabled: Bool

  /// Creates an inline toggle row item.
  public init(
    id: String,
    title: String,
    subtitle: String? = nil,
    leadingSymbolName: String? = nil,
    isOn: Bool,
    switchHandlerID: String,
    isEnabled: Bool = true
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.leadingSymbolName = leadingSymbolName
    self.isOn = isOn
    self.switchHandlerID = switchHandlerID
    self.isEnabled = isEnabled
  }
}

/// Chip picker row payload for ``FKTagPickerCell``.
public struct FKTagPickerItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Section label above the chip group.
  public var title: String
  /// Chip content; selection flags are derived from ``selectedChipIDs``.
  public var chips: [FKChipItem]
  /// Selected chip identifiers.
  public var selectedChipIDs: [String]
  /// Selection behavior forwarded to ``FKChipGroup``.
  public var selectionMode: FKChipGroupSelectionMode
  /// Handler id registered in ``FKCellKitValueHandlerRegistry``.
  public var chipHandlerID: String
  /// When `false`, disables chip interaction.
  public var isEnabled: Bool

  /// Creates a tag picker row item.
  public init(
    id: String,
    title: String,
    chips: [FKChipItem],
    selectedChipIDs: [String] = [],
    selectionMode: FKChipGroupSelectionMode = .single,
    chipHandlerID: String,
    isEnabled: Bool = true
  ) {
    self.id = id
    self.title = title
    self.chips = chips
    self.selectedChipIDs = selectedChipIDs
    self.selectionMode = selectionMode
    self.chipHandlerID = chipHandlerID
    self.isEnabled = isEnabled
  }
}

/// Star rating input row payload for ``FKRatingInputCell``.
public struct FKRatingInputItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Primary title.
  public var title: String
  /// Optional guidance subtitle.
  public var subtitle: String?
  /// Current rating value.
  public var rating: Double
  /// Maximum rating value (defaults to five stars).
  public var maxRating: Double
  /// Handler id registered in ``FKCellKitValueHandlerRegistry``.
  public var ratingHandlerID: String

  /// Creates a rating input row item.
  public init(
    id: String,
    title: String,
    subtitle: String? = nil,
    rating: Double = 0,
    maxRating: Double = 5,
    ratingHandlerID: String
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.rating = rating
    self.maxRating = maxRating
    self.ratingHandlerID = ratingHandlerID
  }
}

/// Invite code row payload for ``FKInviteCodeCell``.
public struct FKInviteCodeItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Primary title.
  public var title: String
  /// Invite code copied by ``FKCopyChip``.
  public var inviteCode: String
  /// Optional supporting text.
  public var subtitle: String?
  /// When `true`, shows a trailing share affordance icon.
  public var showsShareAffordance: Bool
  /// Optional handler id registered in ``FKCellKitValueHandlerRegistry`` for share taps.
  public var shareHandlerID: String?

  /// Creates an invite code row item.
  public init(
    id: String,
    title: String,
    inviteCode: String,
    subtitle: String? = nil,
    showsShareAffordance: Bool = true,
    shareHandlerID: String? = nil
  ) {
    self.id = id
    self.title = title
    self.inviteCode = inviteCode
    self.subtitle = subtitle
    self.showsShareAffordance = showsShareAffordance
    self.shareHandlerID = shareHandlerID
  }
}
