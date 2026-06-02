import UIKit
import FKUIKit

/// Anchor source, overlay host, and host strategy applied via ``FKTabBarFilterController/applyAnchorInstallation(_:)``.
public struct FKTabBarFilterAnchorInstallation {
  public let sourceView: UIView
  public let overlayHost: UIView
  public let hostStrategy: FKAnchorConfiguration.HostStrategy

  public init(
    sourceView: UIView,
    overlayHost: UIView,
    hostStrategy: FKAnchorConfiguration.HostStrategy
  ) {
    self.sourceView = sourceView
    self.overlayHost = overlayHost
    self.hostStrategy = hostStrategy
  }
}
