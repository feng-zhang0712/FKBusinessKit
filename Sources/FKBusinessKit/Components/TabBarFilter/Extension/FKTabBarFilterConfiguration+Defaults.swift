import UIKit
import FKUIKit

public extension FKTabBarFilterConfiguration {
  /// Sets tab bar typography so normal and selected titles use the **same font weight**; selection reads mainly through **tint**
  /// (`label` / `secondaryLabel`). Typical for chevron-style filter tabs.
  mutating func applyTintOnlyChevronTabTypography(textStyle: UIFont.TextStyle = .subheadline) {
    let font = UIFont.preferredFont(forTextStyle: textStyle)
    tabBarConfiguration.appearance.typography.normalFont = font
    tabBarConfiguration.appearance.typography.selectedFont = font
    tabBarConfiguration.appearance.typography.adjustsForContentSizeCategory = true
    tabBarConfiguration.appearance.colors.normalText = .secondaryLabel
    tabBarConfiguration.appearance.colors.selectedText = .label
    tabBarConfiguration.appearance.colors.normalIcon = .secondaryLabel
    tabBarConfiguration.appearance.colors.selectedIcon = .label
  }
}
