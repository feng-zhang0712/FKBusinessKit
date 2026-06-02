import UIKit
import FKUIKit
import FKBusinessKit

/// Shared tab bar + chevron metrics for Filter examples.
enum FKTabBarFilterExampleAppearance {
  /// Total height for the embedded ``FKTabBarFilterController`` chrome row (was 56; −4pt).
  static let filterStripChromeHeight: CGFloat = 52

  static let panelLoadingTitle = "Loading…"

  /// Selected chip / grid label color in filter panels (`FKTabBarFilterPillStyle` default); strip expanded tab uses the same.
  private static let filterSelectionAccentColor = UIColor.systemRed

  static let panelPillStyle = FKTabBarFilterPillStyle(
    cornerRadius: 6,
    contentInsets: .init(top: 6, left: 8, bottom: 6, right: 8),
    selectedTextColor: filterSelectionAccentColor,
    selectedBackgroundColor: filterSelectionAccentColor.withAlphaComponent(0.10),
    selectedBorderColor: filterSelectionAccentColor.withAlphaComponent(0.55)
  )

  /// Right column / single-column list rows (white background).
  static let panelListCellStyle = FKTabBarFilterListCellStyle()

  /// Left sidebar in two-column panels; matches ``FKTabBarFilterTwoColumnGridViewController`` default sidebar coloring.
  static let panelSidebarListCellStyle = FKTabBarFilterListCellStyle(
    rowBackgroundColor: UIColor.systemGray6.withAlphaComponent(0.6),
    selectedRowBackgroundColor: .systemBackground
  )

  static let titleStyle: UIFont.TextStyle = .subheadline
  static let subtitleStyle: UIFont.TextStyle = .caption2
  static let chevronSize = CGSize(width: 14, height: 14)
  static let chevronSpacing: CGFloat = 4
  static let titleSubtitleSpacing: CGFloat = 2

  static var filterTabStrip: FKTabBarFilterTabStripConfiguration {
    FKTabBarFilterTabStripConfiguration(
      titleTextStyle: titleStyle,
      subtitleTextStyle: subtitleStyle,
      chevronSize: chevronSize,
      chevronSpacing: chevronSpacing,
      titleSubtitleSpacing: titleSubtitleSpacing,
      expandedTitleColor: filterSelectionAccentColor,
      expandedChevronColor: filterSelectionAccentColor
    )
  }

  /// ``FKTabBarFilterController`` defaults for the six-tab hub example.
  static func makeHubFilterConfiguration() -> FKTabBarFilterConfiguration<String> {
    var cfg = hubAnchoredBase()
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  /// ``FKTabBarFilterController`` defaults for equal-width tab examples.
  static func makeEqualThreeFilterConfiguration() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  /// Six-tab hub: intrinsic tab widths (horizontal scroll), so long titles are not clipped.
  private static func hubAnchoredBase() -> FKTabBarFilterConfiguration<String> {
    var cfg = FKTabBarFilterConfiguration<String>()
    cfg.tabBarConfiguration.layout.isScrollable = true
    cfg.tabBarConfiguration.layout.widthMode = .intrinsic
    cfg.tabBarConfiguration.layout.itemSpacing = 4
    cfg.tabBarConfiguration.layout.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
    cfg.tabBarConfiguration.layout.contentAlignment = .leading
    cfg.applyTintOnlyChevronTabTypography(textStyle: .subheadline)
    return cfg
  }

  /// Three tabs: equal width, no horizontal scroll.
  private static func equalThreeAnchoredBase() -> FKTabBarFilterConfiguration<String> {
    var cfg = FKTabBarFilterConfiguration<String>()
    cfg.tabBarConfiguration.layout.isScrollable = false
    cfg.tabBarConfiguration.layout.widthMode = .fillEqually
    cfg.tabBarConfiguration.layout.itemSpacing = 0
    cfg.tabBarConfiguration.layout.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
    cfg.applyTintOnlyChevronTabTypography(textStyle: .subheadline)
    return cfg
  }

  static func makeFilterConfiguration(anchored: FKTabBarFilterConfiguration<String>) -> FKTabBarFilterConfiguration<String> {
    var cfg = anchored
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeDismissThenPresent() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.anchorReplacementPolicy = .dismissThenPresent(dismissAnimated: true, presentAnimated: true)
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeSlideUpSwitch() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.anchorReplacementPolicy = .replaceInPlace(contentTransition: .slideVertical(direction: .up, duration: 0.22))
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeCachePerTab() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.contentCachingPolicy = .cachePerTab
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeSlideVerticalSwitch() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.anchorReplacementPolicy = .replaceInPlace(contentTransition: .slideVertical(direction: .down, duration: 0.22))
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeStrongBackdrop() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.presentationConfiguration.backdropStyle = .dim(alpha: 0.52)
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreePassthroughBackdrop() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.presentationConfiguration.backdropStyle = .dim(alpha: 0)
    cfg.presentationConfiguration.zeroDimBackdropBehavior = .passthrough
    cfg.presentationConfiguration.backgroundInteraction = .init(isEnabled: true, showsBackdropWhenEnabled: false)
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeRecreateContent() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.contentCachingPolicy = .recreate
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }

  static func equalThreeSlowLayoutAnimation() -> FKTabBarFilterConfiguration<String> {
    var cfg = equalThreeAnchoredBase()
    cfg.anchorReplacementPolicy = .replaceInPlace(
      contentTransition: .crossfade(duration: 0.18),
      animateLayout: true,
      layoutAnimationDuration: 0.42
    )
    cfg.defaultTabStrip = filterTabStrip
    return cfg
  }
}
