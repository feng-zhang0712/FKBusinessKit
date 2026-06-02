import UIKit
import FKUIKit

/// Chevron tab strip typography, spacing, and title/chevron colors for ``FKTabBarFilterTab`` / ``FKTabBarFilterController``.
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

/// Configuration for ``FKTabBarFilterController``: ``FKTabBar`` strip, anchored presentation, strip defaults, and lifecycle hooks.
///
/// Panel **content** for factory-backed tabs belongs on ``FKTabBarFilterPanelFactory`` and per-panel `Configuration` types.
public struct FKTabBarFilterConfiguration<TabID: Hashable> {
  /// Policy for retaining built ``UIViewController`` instances per tab.
  public enum ContentCachingPolicy: Equatable, Sendable {
    case recreate
    case cachePerTab
  }

  /// Lifecycle hooks (optional). Prefer this over subclassing.
  public struct Events {
    public var onStateChange: (@MainActor (_ state: FKTabBarFilterController<TabID>.State) -> Void)?
    public var onExpandedTabChange: (@MainActor (_ expandedTab: TabID?) -> Void)?
    public var onWillExpand: (@MainActor (_ tab: TabID) -> Void)?
    public var onDidExpand: (@MainActor (_ tab: TabID) -> Void)?
    public var onWillCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterController<TabID>.DismissReason) -> Void)?
    public var onDidCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterController<TabID>.DismissReason) -> Void)?
    public var onWillSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)?
    public var onDidSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)?

    public init(
      onStateChange: (@MainActor (_ state: FKTabBarFilterController<TabID>.State) -> Void)? = nil,
      onExpandedTabChange: (@MainActor (_ expandedTab: TabID?) -> Void)? = nil,
      onWillExpand: (@MainActor (_ tab: TabID) -> Void)? = nil,
      onDidExpand: (@MainActor (_ tab: TabID) -> Void)? = nil,
      onWillCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterController<TabID>.DismissReason) -> Void)? = nil,
      onDidCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterController<TabID>.DismissReason) -> Void)? = nil,
      onWillSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)? = nil,
      onDidSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)? = nil
    ) {
      self.onStateChange = onStateChange
      self.onExpandedTabChange = onExpandedTabChange
      self.onWillExpand = onWillExpand
      self.onDidExpand = onDidExpand
      self.onWillCollapse = onWillCollapse
      self.onDidCollapse = onDidCollapse
      self.onWillSwitchTab = onWillSwitchTab
      self.onDidSwitchTab = onDidSwitchTab
    }
  }

  public var tabBarConfiguration: FKTabBarConfiguration
  /// Dismiss behavior, backdrop, keyboard, and other presentation options. Layout is always anchor; the host overwrites `layout` when presenting.
  public var presentationConfiguration: FKSheetPresentationConfiguration
  /// How anchor-hosted panel content is replaced when switching tabs while expanded (see ``FKSheetPresentationAnchorReplacementPolicy``).
  public var anchorReplacementPolicy: FKSheetPresentationAnchorReplacementPolicy
  public var contentCachingPolicy: ContentCachingPolicy
  /// Optional custom anchor; when `nil`, the tab bar is the source and the tab bar host view is the overlay container.
  public var anchorPlacement: FKTabBarFilterAnchorPlacement?

  public var events: Events

  /// Used when ``FKTabBarFilterTab/tabStrip`` is `nil`.
  public var defaultTabStrip: FKTabBarFilterTabStripConfiguration

  public init(
    tabBarConfiguration: FKTabBarConfiguration,
    presentationConfiguration: FKSheetPresentationConfiguration,
    anchorReplacementPolicy: FKSheetPresentationAnchorReplacementPolicy = .replaceInPlace(),
    contentCachingPolicy: ContentCachingPolicy = .cachePerTab,
    anchorPlacement: FKTabBarFilterAnchorPlacement? = nil,
    events: Events = .init(),
    defaultTabStrip: FKTabBarFilterTabStripConfiguration = .init()
  ) {
    self.tabBarConfiguration = tabBarConfiguration
    self.presentationConfiguration = presentationConfiguration
    self.anchorReplacementPolicy = anchorReplacementPolicy
    self.contentCachingPolicy = contentCachingPolicy
    self.anchorPlacement = anchorPlacement
    self.events = events
    self.defaultTabStrip = defaultTabStrip
  }

  /// Creates filter settings with tuned anchored-dropdown defaults.
  @MainActor
  public init() {
    self.init(
      tabBarConfiguration: Self.defaultTabBarConfiguration,
      presentationConfiguration: Self.defaultPresentationConfiguration,
      anchorReplacementPolicy: .replaceInPlace(contentTransition: .crossfade(duration: 0.18))
    )
  }
}

extension FKTabBarFilterConfiguration {
  @MainActor
  static var defaultTabBarConfiguration: FKTabBarConfiguration {
    var tab = FKTabBarConfiguration()
    tab.layout.isScrollable = true
    tab.layout.widthMode = .intrinsic
    tab.layout.itemSpacing = 8
    tab.layout.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
    tab.layout.contentAlignment = .leading
    tab.appearance.backgroundStyle = .solid(.systemBackground)
    tab.appearance.indicatorStyle = .none
    tab.appearance.showsDivider = true
    tab.appearance.dividerPosition = .bottom
    return tab
  }

  @MainActor
  static var defaultPresentationConfiguration: FKSheetPresentationConfiguration {
    var presentation = FKSheetPresentationConfiguration.default
    presentation.cornerRadius = 10
    presentation.backdropStyle = .dim(alpha: 0.25)
    presentation.dismissBehavior = .init(allowsTapOutside: true, allowsSwipe: true, allowsBackdropTap: true)
    presentation.keyboardAvoidance = .init(
      isEnabled: true,
      strategy: .interactive,
      additionalBottomInset: 8,
      targetScrollView: nil
    )
    presentation.safeAreaPolicy = .contentRespectsSafeArea
    presentation.rotationHandling = .relayoutAnimated
    return presentation
  }
}
