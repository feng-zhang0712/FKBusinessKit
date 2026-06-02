import UIKit
import FKUIKit
import FKBusinessKit

/// TabBarFilter example entry — ``FKTabBarFilterController``, anchoring, and panel components.
final class FKTabBarFilterExamplesHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "TabBarFilter", sections: FKTabBarFilterExampleCatalog.rootSections)
  }
}
