import UIKit
import FKUIKit
import FKBusinessKit

/// Example-only helpers on top of ``FKTabBarFilterHosting`` (debug logging).
enum FKTabBarFilterExampleChrome {
  /// Optional console trace for ``FKTabBarFilterController/onSelection``.
  @MainActor
  static func debugPrintSelection(_ ctx: FKTabBarFilterSelectionContext<String>) {
    let section = ctx.sectionID.map(\.rawValue) ?? "—"
    print(
      "[FilterExample] onSelection tab=\(ctx.tabID) panel=\(ctx.panelKind.rawValue) section=\(section) title=\(ctx.item.title) id=\(ctx.item.id.rawValue) mode=\(ctx.effectiveSelectionMode)"
    )
  }

  @MainActor
  @discardableResult
  static func embed(
    filterHost: FKTabBarFilterController<String>,
    in parent: UIViewController,
    topAnchor: NSLayoutYAxisAnchor,
    overlayHost: UIView,
    logSelection: Bool
  ) -> UIView? {
    let strip = FKTabBarFilterHosting.embedStrip(
      filterHost,
      in: parent,
      topAnchor: topAnchor,
      fixedStripHeight: FKTabBarFilterExampleAppearance.filterStripChromeHeight,
      overlayHost: overlayHost,
      useCompactTabButtonInsets: true
    )
    if logSelection {
      filterHost.onSelection = { Self.debugPrintSelection($0) }
    }
    return strip
  }

  @MainActor
  static func installBodyPlaceholder(below stripBottom: NSLayoutYAxisAnchor, in parent: UIViewController) {
    FKTabBarFilterHosting.installContentBackgroundBelowStrip(in: parent, stripBottom: stripBottom)
  }
}
