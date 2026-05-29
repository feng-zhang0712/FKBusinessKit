import UIKit
import FKUIKit
import FKBusinessKit

/// Resolves anchor source, overlay host, and ``FKAnchorConfiguration/HostStrategy`` for anchor-zone demos.
enum FKTabBarFilterAnchorZoneInstaller {
  enum Kind {
    case navigationBar
    case screenTop
    case screenBottom
  }

  struct Installation {
    let sourceView: UIView
    let overlayHost: UIView
    let hostStrategy: FKAnchorConfiguration.HostStrategy
    /// Ephemeral geometry helper pinned to a screen edge; `nil` when `sourceView` is the anchor (navigation bar).
    let edgeMarker: UIView?
  }

  private static let thickness: CGFloat = 1

  @MainActor
  static func install(
    _ kind: Kind,
    in viewController: UIViewController
  ) -> Installation? {
    switch kind {
    case .navigationBar:
      guard let navigationController = viewController.navigationController else { return nil }
      let host = navigationController.view!
      host.layoutIfNeeded()
      return Installation(
        sourceView: navigationController.navigationBar,
        overlayHost: host,
        hostStrategy: .inProvidedContainer(FKWeakReference(host)),
        edgeMarker: nil
      )

    case .screenTop:
      guard let window = presentationWindow(for: viewController) else { return nil }
      window.layoutIfNeeded()
      let marker = makeEdgeMarker()
      window.addSubview(marker)
      NSLayoutConstraint.activate([
        marker.topAnchor.constraint(equalTo: window.topAnchor),
        marker.leadingAnchor.constraint(equalTo: window.leadingAnchor),
        marker.trailingAnchor.constraint(equalTo: window.trailingAnchor),
        marker.heightAnchor.constraint(equalToConstant: thickness),
      ])
      return Installation(
        sourceView: marker,
        overlayHost: window,
        hostStrategy: .inWindowLevel,
        edgeMarker: marker
      )

    case .screenBottom:
      guard let window = presentationWindow(for: viewController) else { return nil }
      window.layoutIfNeeded()
      let marker = makeEdgeMarker()
      window.addSubview(marker)
      NSLayoutConstraint.activate([
        marker.bottomAnchor.constraint(equalTo: window.bottomAnchor),
        marker.leadingAnchor.constraint(equalTo: window.leadingAnchor),
        marker.trailingAnchor.constraint(equalTo: window.trailingAnchor),
        marker.heightAnchor.constraint(equalToConstant: thickness),
      ])
      return Installation(
        sourceView: marker,
        overlayHost: window,
        hostStrategy: .inWindowLevel,
        edgeMarker: marker
      )
    }
  }

  @MainActor
  static func remove(_ installation: Installation?) {
    installation?.edgeMarker?.removeFromSuperview()
  }

  @MainActor
  static func presentationWindow(for viewController: UIViewController) -> UIWindow? {
    viewController.view.window
      ?? viewController.navigationController?.view.window
      ?? UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)
  }

  @MainActor
  private static func makeEdgeMarker() -> UIView {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.isAccessibilityElement = false
    view.backgroundColor = .clear
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
}

extension FKTabBarFilterDropdownController {
  /// Applies a zone installer result to this controller's anchor placement.
  func applyZoneInstallation(_ installation: FKTabBarFilterAnchorZoneInstaller.Installation) {
    setAnchor(source: installation.sourceView, overlayHost: installation.overlayHost)
    configuration.anchorPlacement?.hostStrategy = installation.hostStrategy
  }
}
