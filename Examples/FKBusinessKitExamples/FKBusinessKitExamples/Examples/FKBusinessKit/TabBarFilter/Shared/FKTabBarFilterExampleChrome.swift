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
    topConstant: CGFloat = 0,
    overlayHost: UIView,
    logSelection: Bool
  ) -> UIView? {
    embedStrip(
      filterHost: filterHost,
      in: parent,
      verticalAnchor: .below(topAnchor, constant: topConstant),
      overlayHost: overlayHost,
      logSelection: logSelection
    )
  }

  @MainActor
  @discardableResult
  static func embedStripAtBottom(
    filterHost: FKTabBarFilterController<String>,
    in parent: UIViewController,
    bottomAnchor: NSLayoutYAxisAnchor,
    overlayHost: UIView,
    logSelection: Bool,
    extendsIntoBottomSafeArea: Bool = false
  ) -> UIView? {
    embedStrip(
      filterHost: filterHost,
      in: parent,
      verticalAnchor: .above(bottomAnchor, extendsIntoBottomSafeArea: extendsIntoBottomSafeArea),
      overlayHost: overlayHost,
      logSelection: logSelection
    )
  }

  private enum StripVerticalAnchor {
    case below(NSLayoutYAxisAnchor, constant: CGFloat)
    case above(NSLayoutYAxisAnchor, extendsIntoBottomSafeArea: Bool)
  }

  @MainActor
  @discardableResult
  private static func embedStrip(
    filterHost: FKTabBarFilterController<String>,
    in parent: UIViewController,
    verticalAnchor: StripVerticalAnchor,
    overlayHost: UIView,
    logSelection: Bool
  ) -> UIView? {
    parent.addChild(filterHost)
    filterHost.loadViewIfNeeded()
    guard let stripView = filterHost.view else { return nil }
    stripView.translatesAutoresizingMaskIntoConstraints = false
    parent.view.addSubview(stripView)

    switch verticalAnchor {
    case .below(let top, let constant):
      NSLayoutConstraint.activate([
        stripView.topAnchor.constraint(equalTo: top, constant: constant),
        stripView.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
        stripView.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        stripView.heightAnchor.constraint(equalToConstant: FKTabBarFilterExampleAppearance.filterStripChromeHeight),
      ])
    case .above(let bottom, let extendsIntoBottomSafeArea):
      if extendsIntoBottomSafeArea {
        NSLayoutConstraint.activate([
          stripView.bottomAnchor.constraint(equalTo: bottom),
          stripView.topAnchor.constraint(
            equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor,
            constant: -FKTabBarFilterExampleAppearance.filterStripChromeHeight
          ),
          stripView.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
          stripView.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        ])
      } else {
        NSLayoutConstraint.activate([
          stripView.bottomAnchor.constraint(equalTo: bottom),
          stripView.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
          stripView.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
          stripView.heightAnchor.constraint(equalToConstant: FKTabBarFilterExampleAppearance.filterStripChromeHeight),
        ])
      }
    }

    filterHost.didMove(toParent: parent)
    FKTabBarFilterHosting.applyCompactTabButtonInsets(
      to: filterHost.dropdownController.tabBar,
      horizontalInset: 4,
      verticalInset: 6
    )
    filterHost.pinAnchoredPresentationOverlay(to: overlayHost)
    if logSelection {
      filterHost.onSelection = { debugPrintSelection($0) }
    }
    return stripView
  }

  @MainActor
  static func installBodyPlaceholder(below stripBottom: NSLayoutYAxisAnchor, in parent: UIViewController) -> UIView {
    let filler = UIView()
    filler.backgroundColor = .systemBackground
    filler.translatesAutoresizingMaskIntoConstraints = false
    parent.view.addSubview(filler)
    NSLayoutConstraint.activate([
      filler.topAnchor.constraint(equalTo: stripBottom),
      filler.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
      filler.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
      filler.bottomAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor),
    ])
    return filler
  }
}
