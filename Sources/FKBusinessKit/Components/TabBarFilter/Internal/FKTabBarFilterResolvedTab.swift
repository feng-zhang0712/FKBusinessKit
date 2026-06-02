import UIKit
import FKUIKit

/// Internal tab descriptor used to build ``FKTabBar`` items and panel content.
struct FKTabBarFilterResolvedTab<TabID: Hashable> {
  struct StateSnapshot: Equatable {
    var expandedTab: TabID?

    init(expandedTab: TabID?) {
      self.expandedTab = expandedTab
    }
  }

  enum PanelContent {
    case viewController(() -> UIViewController)
    case view(() -> UIView)
  }

  let id: TabID
  var makeTabBarItem: (_ snapshot: StateSnapshot) -> FKTabBarItem
  var content: PanelContent
}

extension FKTabBarFilterResolvedTab {
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
    content: PanelContent
  ) -> Self {
    FKTabBarFilterResolvedTab(
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
