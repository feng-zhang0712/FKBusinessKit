import UIKit
import FKUIKit

/// Chevron tab strip typography, spacing, and title/chevron colors for ``FKTabBarFilterTab`` / ``FKTabBarFilterController``.
///
/// Maps to ``FKTabBarFilterDropdownTab/chevronTitle(id:itemID:title:subtitle:normalTitleColor:expandedTitleColor:normalChevronColor:expandedChevronColor:titleFont:subtitleFont:chevronSize:chevronSpacing:titleSubtitleSpacing:content:)``.
///
/// Per-tab overrides live on ``FKTabBarFilterTab/tabStrip``; when `nil`, ``FKTabBarFilterConfiguration/defaultTabStrip`` is used.
public struct FKTabBarFilterTabStripConfiguration: Sendable {
  public var titleTextStyle: UIFont.TextStyle
  public var subtitleTextStyle: UIFont.TextStyle
  public var chevronSize: CGSize
  public var chevronSpacing: CGFloat
  public var titleSubtitleSpacing: CGFloat
  public var normalTitleColor: UIColor
  public var expandedTitleColor: UIColor
  /// When equal to ``normalTitleColor`` (default), chevron tint follows the tab bar title color at layout time.
  public var normalChevronColor: UIColor
  public var expandedChevronColor: UIColor

  public init(
    titleTextStyle: UIFont.TextStyle = .subheadline,
    subtitleTextStyle: UIFont.TextStyle = .caption2,
    chevronSize: CGSize = CGSize(width: 14, height: 14),
    chevronSpacing: CGFloat = 4,
    titleSubtitleSpacing: CGFloat = 2,
    normalTitleColor: UIColor = .label,
    expandedTitleColor: UIColor = .tintColor,
    normalChevronColor: UIColor = .label,
    expandedChevronColor: UIColor = .tintColor
  ) {
    self.titleTextStyle = titleTextStyle
    self.subtitleTextStyle = subtitleTextStyle
    self.chevronSize = chevronSize
    self.chevronSpacing = chevronSpacing
    self.titleSubtitleSpacing = titleSubtitleSpacing
    self.normalTitleColor = normalTitleColor
    self.expandedTitleColor = expandedTitleColor
    self.normalChevronColor = normalChevronColor
    self.expandedChevronColor = expandedChevronColor
  }
}

/// Top-level settings for ``FKTabBarFilterController``: anchored dropdown shell, strip defaults, and lifecycle hooks.
///
/// Panel **content** (models, chips, list styles, loading title, hairline wrapper, etc.) belongs on ``FKTabBarFilterPanelFactory``
/// and per-panel `Configuration` types.
public struct FKTabBarFilterConfiguration<TabID: Hashable> {
  /// Dropdown + tab bar behavior (backdrop, anchor replacement, caching, anchor placement, …).
  public var dropdownConfiguration: FKTabBarFilterDropdownConfiguration

  /// Optional transitions and state hooks on the anchored dropdown.
  public var dropdownEvents: FKTabBarFilterDropdownConfiguration.Events<TabID>

  /// Used when ``FKTabBarFilterTab/tabStrip`` is `nil`.
  public var defaultTabStrip: FKTabBarFilterTabStripConfiguration

  public init(
    dropdownConfiguration: FKTabBarFilterDropdownConfiguration,
    dropdownEvents: FKTabBarFilterDropdownConfiguration.Events<TabID> = .init(),
    defaultTabStrip: FKTabBarFilterTabStripConfiguration = .init()
  ) {
    self.dropdownConfiguration = dropdownConfiguration
    self.dropdownEvents = dropdownEvents
    self.defaultTabStrip = defaultTabStrip
  }

  /// Creates filter settings with tuned anchored-dropdown defaults.
  @MainActor
  public init() {
    self.init(dropdownConfiguration: FKTabBarFilterDropdownConfiguration())
  }
}
