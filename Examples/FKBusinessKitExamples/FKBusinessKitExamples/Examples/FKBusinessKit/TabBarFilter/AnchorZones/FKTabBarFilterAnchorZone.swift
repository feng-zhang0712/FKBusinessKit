import UIKit
import FKUIKit
import FKBusinessKit

/// Vertical anchor zones supported by ``FKTabBarFilterAnchorPlacement`` / ``FKAnchor`` (top or bottom attachment edge only).
enum FKTabBarFilterAnchorZone: String, CaseIterable {
  case navigationBar
  case screenTop
  case screenBottom

  var menuTitle: String {
    switch self {
    case .navigationBar: return "Navigation bar"
    case .screenTop: return "Screen top"
    case .screenBottom: return "Screen bottom"
    }
  }

  var installerKind: FKTabBarFilterAnchorZoneInstaller.Kind {
    switch self {
    case .navigationBar: return .navigationBar
    case .screenTop: return .screenTop
    case .screenBottom: return .screenBottom
    }
  }

  /// ``FKTabBarFilterController/updateAnchorPlacement`` values for this zone.
  var anchorGeometry: FKTabBarFilterAnchorZone.Geometry {
    switch self {
    case .navigationBar, .screenTop:
      return FKTabBarFilterAnchorZone.Geometry(
        attachmentEdge: .bottom,
        expansionDirection: .down,
        horizontalAlignment: .fill,
        widthPolicy: .matchContainer
      )
    case .screenBottom:
      return FKTabBarFilterAnchorZone.Geometry(
        attachmentEdge: .top,
        expansionDirection: .up,
        horizontalAlignment: .fill,
        widthPolicy: .matchContainer
      )
    }
  }

  /// Uses the system navigation bar chrome (pushed on a ``UINavigationController`` stack).
  var usesNavigationBarChrome: Bool {
    self == .navigationBar || self == .screenTop || self == .screenBottom
  }

  struct Geometry {
    let attachmentEdge: FKAnchor.Edge
    let expansionDirection: FKAnchor.Direction
    let horizontalAlignment: FKAnchor.Alignment
    let widthPolicy: FKAnchor.WidthPolicy
  }

  func applyAnchorGeometry<TabID: Hashable>(to filter: FKTabBarFilterController<TabID>) {
    let geometry = anchorGeometry
    filter.updateAnchorPlacement(
      attachmentEdge: geometry.attachmentEdge,
      expansionDirection: geometry.expansionDirection,
      horizontalAlignment: geometry.horizontalAlignment,
      widthPolicy: geometry.widthPolicy
    )
  }

  /// Shell extends to the physical edge; panel content is inset for the window safe area. No container blur.
  func applyZonePresentationConfiguration<TabID: Hashable>(
    to filter: FKTabBarFilterController<TabID>,
    in viewController: UIViewController
  ) {
    guard let window = FKTabBarFilterAnchorZoneInstaller.presentationWindow(for: viewController) else { return }
    let safe = window.safeAreaInsets

    var config = filter.configuration
    config.presentationConfiguration.containerBlur = .init()
    config.presentationConfiguration.safeAreaPolicy = .contentRespectsSafeArea

    var contentInsets = config.presentationConfiguration.contentInsets
    switch self {
    case .navigationBar:
      break
    case .screenTop:
      contentInsets.top = max(contentInsets.top, safe.top)
    case .screenBottom:
      contentInsets.bottom = max(contentInsets.bottom, safe.bottom)
    }
    config.presentationConfiguration.contentInsets = contentInsets
    filter.configuration = config
  }

  var filterHint: String {
    switch self {
    case .navigationBar:
      return "Filter strip on the bottom edge. Panels attach to the navigation bar and expand downward."
    case .screenTop:
      return "Filter strip on the bottom edge (white chrome fills the home-indicator region). Panels attach to the physical top edge and expand downward."
    case .screenBottom:
      return "Filter strip below the navigation bar. Panels attach to the physical bottom edge and expand upward."
    }
  }

  var customHint: String {
    switch self {
    case .navigationBar:
      return "The panel attaches to the navigation bar and expands downward. Use Open / Close in the navigation bar."
    case .screenTop:
      return "The panel is hosted at window level on the physical top edge. White chrome fills the status-bar region; list content stays in the safe area."
    case .screenBottom:
      return "The panel is hosted at window level on the physical bottom edge. White chrome fills the home-indicator region."
    }
  }

  static let hubSections: [FKTabBarFilterExampleListSection] = [
    FKTabBarFilterExampleListSection(
      title: "Anchor zones",
      rows: [
        FKTabBarFilterExampleListRow(
          title: "Anchor zones playground",
          subtitle: "Navigation bar, screen top, and screen bottom — filter strip or custom anchor on one screen."
        ) {
          FKTabBarFilterAnchorZonesPlaygroundViewController()
        },
        FKTabBarFilterExampleListRow(
          title: "Horizontal edge trays",
          subtitle: "TabBarFilter uses ``FKAnchor`` (top/bottom edges only). Left/right trays need ``FKSheetPresentationConfiguration/Layout/edge(_:)`` directly — not exposed on TabBarFilter."
        ) {
          FKTabBarFilterHorizontalEdgeNoteViewController()
        },
      ]
    ),
  ]
}
