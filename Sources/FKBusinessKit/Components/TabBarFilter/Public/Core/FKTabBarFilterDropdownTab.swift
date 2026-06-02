import UIKit
import FKUIKit

/// A tab descriptor for `FKTabBarFilterDropdownController`.
public struct FKTabBarFilterDropdownTab<TabID: Hashable> {
  /// Snapshot used when building tab UI and content.
  public struct StateSnapshot: Equatable {
    /// Currently expanded tab (if any).
    public var expandedTab: TabID?

    public init(expandedTab: TabID?) {
      self.expandedTab = expandedTab
    }
  }

  /// Content descriptor.
  public enum Content {
    /// Provide a view controller directly.
    case viewController(() -> UIViewController)
    /// Provide a view and wrap it in a lightweight hosting controller.
    case view(() -> UIView)
  }

  /// Unique identifier for this tab.
  public let id: TabID
  /// Builds the `FKTabBarItem` used by `FKTabBar`.
  ///
  /// - Important: You are expected to reflect `snapshot.expandedTab` in title emphasis when using
  ///   ``chevronTitle``; chevron rotation is applied by ``FKTabBarFilterDropdownController`` via
  ///   ``FKTabBar/visibleItemAccessoryView(at:)``.
  public var makeTabBarItem: (_ snapshot: StateSnapshot) -> FKTabBarItem
  /// Provides the dropdown content for this tab.
  public var content: Content

  public init(
    id: TabID,
    makeTabBarItem: @escaping (_ snapshot: StateSnapshot) -> FKTabBarItem,
    content: Content
  ) {
    self.id = id
    self.makeTabBarItem = makeTabBarItem
    self.content = content
  }
}

public extension FKTabBarFilterDropdownTab {
  /// A lightweight default tab builder using a title + trailing `chevron.down` accessory.
  ///
  /// ``FKTabBarFilterDropdownController`` rotates the accessory 180° while the tab is expanded (filter-strip preset behavior).
  ///
  /// When ``normalChevronColor`` / ``expandedChevronColor`` match the corresponding title colors (defaults),
  /// the chevron tint follows ``FKTabBar`` title emphasis at layout time.
  static func chevronTitle(
    id: TabID,
    itemID: String? = nil,
    title: @escaping () -> String,
    subtitle: (() -> String?)? = nil,
    normalTitleColor: UIColor = .label,
    expandedTitleColor: UIColor = .tintColor,
    normalChevronColor: UIColor = .label,
    expandedChevronColor: UIColor = .tintColor,
    titleFont: UIFont = .preferredFont(forTextStyle: .subheadline),
    subtitleFont: UIFont = .preferredFont(forTextStyle: .caption2),
    chevronSize: CGSize = .init(width: 14, height: 14),
    chevronSpacing: CGFloat = 4,
    titleSubtitleSpacing: CGFloat = 2,
    content: Content
  ) -> Self {
    FKTabBarFilterDropdownTab(
      id: id,
      makeTabBarItem: { snapshot in
        let isExpanded = snapshot.expandedTab == id
        let titleText = title()
        let subtitleText = subtitle?()

        var titleConfig = FKTabBarTextConfiguration(
          normal: .init(
            text: titleText,
            style: FKTabBarTextStyle(font: titleFont, color: isExpanded ? expandedTitleColor : normalTitleColor)
          ),
          selected: .init(
            text: titleText,
            style: FKTabBarTextStyle(font: titleFont, color: isExpanded ? expandedTitleColor : normalTitleColor)
          )
        )
        titleConfig.spacingToNextText = max(0, titleSubtitleSpacing)

        let subtitleConfig: FKTabBarTextConfiguration? = subtitleText.map { value in
          FKTabBarTextConfiguration(
            normal: .init(
              text: value,
              style: FKTabBarTextStyle(font: subtitleFont, color: isExpanded ? expandedTitleColor : normalTitleColor)
            ),
            selected: .init(
              text: value,
              style: FKTabBarTextStyle(font: subtitleFont, color: isExpanded ? expandedTitleColor : normalTitleColor)
            )
          )
        }

        let accessoryIcon = Self.makeChevronAccessoryIcon(
          isExpanded: isExpanded,
          chevronSize: chevronSize,
          chevronSpacing: chevronSpacing,
          normalTitleColor: normalTitleColor,
          expandedTitleColor: expandedTitleColor,
          normalChevronColor: normalChevronColor,
          expandedChevronColor: expandedChevronColor
        )

        return FKTabBarItem(
          id: itemID ?? String(describing: id),
          title: titleConfig,
          subtitle: subtitleConfig,
          accessoryIcon: accessoryIcon,
          isEnabled: true,
          isHidden: false
        )
      },
      content: content
    )
  }

  /// Chevron tint follows the tab title color when chevron/title colors match; otherwise uses an explicit accessory tint.
  private static func makeChevronAccessoryIcon(
    isExpanded: Bool,
    chevronSize: CGSize,
    chevronSpacing: CGFloat,
    normalTitleColor: UIColor,
    expandedTitleColor: UIColor,
    normalChevronColor: UIColor,
    expandedChevronColor: UIColor
  ) -> FKTabBarAccessoryIconConfiguration {
    let titleColor = isExpanded ? expandedTitleColor : normalTitleColor
    let chevronColor = isExpanded ? expandedChevronColor : normalChevronColor
    let accessoryStyle = FKTabBarAccessoryIconStyle(
      pointSize: max(chevronSize.width, chevronSize.height),
      tintColor: chevronColor.isEqual(titleColor) ? nil : chevronColor,
      fixedSize: chevronSize,
      spacingToTitle: max(0, chevronSpacing)
    )
    let state = FKTabBarAccessoryIconConfiguration.State(
      source: .systemSymbol(name: "chevron.down"),
      style: accessoryStyle
    )
    return FKTabBarAccessoryIconConfiguration(normal: state, selected: state)
  }
}
