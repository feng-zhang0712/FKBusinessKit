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
    normalChevronColor: UIColor = .secondaryLabel,
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

/// Top-level settings for ``FKTabBarFilterController``: anchored dropdown shell, strip defaults, panel chrome defaults, and lifecycle hooks.
///
/// Panel **content** (two-column models, chips, list styles, etc.) stays on ``FKTabBarFilterPanelFactory`` / per-panel `Configuration`
/// types so each panel kind can evolve independently.
public struct FKTabBarFilterConfiguration<TabID: Hashable> {
  /// Dropdown + tab bar behavior (backdrop, switch animation, caching, anchor placement, …).
  public var dropdownConfiguration: FKTabBarFilterDropdownConfiguration

  /// Optional transitions and state hooks on the anchored dropdown.
  public var dropdownEvents: FKTabBarFilterDropdownConfiguration.Events<TabID>

  /// Used when ``FKTabBarFilterTab/tabStrip`` is `nil`.
  public var defaultTabStrip: FKTabBarFilterTabStripConfiguration

  /// Passed to ``FKTabBarFilterPanelFactory/loadingTitle`` when you build the factory with these values.
  public var panelLoadingTitle: String

  /// Passed to ``FKTabBarFilterPanelFactory/wrapsPanelWithTopHairline`` when you build the factory with these values.
  public var wrapsPanelWithTopHairline: Bool

  public init(
    dropdownConfiguration: FKTabBarFilterDropdownConfiguration,
    dropdownEvents: FKTabBarFilterDropdownConfiguration.Events<TabID> = .init(),
    defaultTabStrip: FKTabBarFilterTabStripConfiguration = .init(),
    panelLoadingTitle: String = "Loading...",
    wrapsPanelWithTopHairline: Bool = true
  ) {
    self.dropdownConfiguration = dropdownConfiguration
    self.dropdownEvents = dropdownEvents
    self.defaultTabStrip = defaultTabStrip
    self.panelLoadingTitle = panelLoadingTitle
    self.wrapsPanelWithTopHairline = wrapsPanelWithTopHairline
  }

  /// Creates filter settings with tuned anchored-dropdown defaults.
  @MainActor
  public init() {
    self.init(dropdownConfiguration: FKTabBarFilterDropdownConfiguration())
  }
}
