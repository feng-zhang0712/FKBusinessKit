import UIKit
import FKUIKit
import FKBusinessKit

/// Unified catalog for isolated panel view controller examples.
final class FKTabBarFilterPanelsExampleHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "Panel components", sections: FKTabBarFilterPanelsCatalog.hubSections)
  }
}
