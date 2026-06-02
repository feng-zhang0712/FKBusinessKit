import UIKit
import FKUIKit
import FKBusinessKit

/// Example-only helpers on top of ``FKTabBarFilterHosting`` (debug logging).
enum FKTabBarFilterExampleChrome {
  /// Optional console trace for ``FKTabBarFilterController/onSelection``.
  /// Raises FKUIKit anchor presentation views above playground chrome (settings scroll view, placeholders).
  @MainActor
  static func bringAnchoredPresentationToFront(in rootView: UIView) {
    var anchorHosts: [UIView] = []
    collectAnchorHostViews(in: rootView, into: &anchorHosts)
    anchorHosts.forEach { rootView.bringSubviewToFront($0) }
  }

  @MainActor
  private static func collectAnchorHostViews(in view: UIView, into result: inout [UIView]) {
    let typeName = String(describing: type(of: view))
    if typeName.contains("FKAnchorHostView") {
      result.append(view)
    }
    view.subviews.forEach { collectAnchorHostViews(in: $0, into: &result) }
  }

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
      to: filterHost.tabBar,
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
  @discardableResult
  static func installBodyPlaceholder(
    below stripBottom: NSLayoutYAxisAnchor,
    in parent: UIViewController,
    minimumHeight: CGFloat = 120,
    placeholder: (title: String, subtitle: String)? = nil
  ) -> UIView {
    let filler = UIView()
    filler.backgroundColor = .secondarySystemGroupedBackground
    filler.translatesAutoresizingMaskIntoConstraints = false
    parent.view.addSubview(filler)

    var constraints: [NSLayoutConstraint] = [
      filler.topAnchor.constraint(equalTo: stripBottom),
      filler.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
      filler.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
      filler.bottomAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor),
      filler.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight),
    ]

    if let placeholder {
      let titleLabel = UILabel()
      titleLabel.text = placeholder.title
      titleLabel.font = .preferredFont(forTextStyle: .headline)
      titleLabel.textColor = .secondaryLabel
      titleLabel.textAlignment = .center
      titleLabel.numberOfLines = 0

      let subtitleLabel = UILabel()
      subtitleLabel.text = placeholder.subtitle
      subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
      subtitleLabel.textColor = .tertiaryLabel
      subtitleLabel.textAlignment = .center
      subtitleLabel.numberOfLines = 0

      let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
      labels.axis = .vertical
      labels.spacing = 6
      labels.alignment = .center
      labels.translatesAutoresizingMaskIntoConstraints = false
      filler.addSubview(labels)
      constraints += [
        labels.centerXAnchor.constraint(equalTo: filler.centerXAnchor),
        labels.centerYAnchor.constraint(equalTo: filler.centerYAnchor),
        labels.leadingAnchor.constraint(greaterThanOrEqualTo: filler.leadingAnchor, constant: 24),
        labels.trailingAnchor.constraint(lessThanOrEqualTo: filler.trailingAnchor, constant: -24),
      ]
    }

    NSLayoutConstraint.activate(constraints)
    return filler
  }
}
