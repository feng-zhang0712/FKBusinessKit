import UIKit
import FKUIKit

/// Configuration for ``FKTabBarFilterDropdownController``.
public struct FKTabBarFilterDropdownConfiguration {
  /// Policy for retaining built ``UIViewController`` instances per tab.
  public enum ContentCachingPolicy: Equatable, Sendable {
    case recreate
    case cachePerTab
  }

  /// Lifecycle hooks (optional). Prefer this over subclassing.
  public struct Events<TabID: Hashable> {
    public var onStateChange: (@MainActor (_ state: FKTabBarFilterDropdownController<TabID>.State) -> Void)?
    public var onExpandedTabChange: (@MainActor (_ expandedTab: TabID?) -> Void)?
    public var onWillExpand: (@MainActor (_ tab: TabID) -> Void)?
    public var onDidExpand: (@MainActor (_ tab: TabID) -> Void)?
    public var onWillCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterDropdownController<TabID>.DismissReason) -> Void)?
    public var onDidCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterDropdownController<TabID>.DismissReason) -> Void)?
    public var onWillSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)?
    public var onDidSwitchTab: (@MainActor (_ from: TabID, _ to: TabID) -> Void)?

    public init(
      onStateChange: (@MainActor (_ state: FKTabBarFilterDropdownController<TabID>.State) -> Void)? = nil,
      onExpandedTabChange: (@MainActor (_ expandedTab: TabID?) -> Void)? = nil,
      onWillExpand: (@MainActor (_ tab: TabID) -> Void)? = nil,
      onDidExpand: (@MainActor (_ tab: TabID) -> Void)? = nil,
      onWillCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterDropdownController<TabID>.DismissReason) -> Void)? = nil,
      onDidCollapse: (@MainActor (_ tab: TabID?, _ reason: FKTabBarFilterDropdownController<TabID>.DismissReason) -> Void)? = nil,
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

  public init(
    tabBarConfiguration: FKTabBarConfiguration,
    presentationConfiguration: FKSheetPresentationConfiguration,
    anchorReplacementPolicy: FKSheetPresentationAnchorReplacementPolicy = .replaceInPlace(),
    contentCachingPolicy: ContentCachingPolicy = .cachePerTab,
    anchorPlacement: FKTabBarFilterAnchorPlacement? = nil
  ) {
    self.tabBarConfiguration = tabBarConfiguration
    self.presentationConfiguration = presentationConfiguration
    self.anchorReplacementPolicy = anchorReplacementPolicy
    self.contentCachingPolicy = contentCachingPolicy
    self.anchorPlacement = anchorPlacement
  }

  /// Creates the tuned dropdown defaults (tab bar, presentation, keyboard, backdrop).
  @MainActor
  public init() {
    let defaults = FKTabBarFilterDropdownConfiguration.default
    self.init(
      tabBarConfiguration: defaults.tabBarConfiguration,
      presentationConfiguration: defaults.presentationConfiguration,
      anchorReplacementPolicy: defaults.anchorReplacementPolicy,
      contentCachingPolicy: defaults.contentCachingPolicy,
      anchorPlacement: defaults.anchorPlacement
    )
  }
}
