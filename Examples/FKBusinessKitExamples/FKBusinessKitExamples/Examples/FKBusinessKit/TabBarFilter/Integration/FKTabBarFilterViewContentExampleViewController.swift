import UIKit
import FKUIKit
import FKBusinessKit

/// ``FKTabBarFilterDropdownTab/Content/view`` hosting (no dedicated child view controller per tab).
final class FKTabBarFilterViewContentExampleViewController: UIViewController {
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterTabBarHostView()
  private lazy var dropdown: FKTabBarFilterDropdownController<FKTabBarFilterExampleTabID> = {
    let tabs: [FKTabBarFilterDropdownTab<FKTabBarFilterExampleTabID>] = [
      .chevronTitle(
        id: .filters,
        itemID: "filters",
        title: { "UIView" },
        subtitle: { "Lightweight host" },
        content: .view {
          let container = UIView()
          container.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.12)

          let label = UILabel()
          label.text = "Content from Content.view — FKTabBarFilterViewWrappingController"
          label.font = .preferredFont(forTextStyle: .body)
          label.textColor = .label
          label.numberOfLines = 0
          label.textAlignment = .center
          label.translatesAutoresizingMaskIntoConstraints = false
          container.addSubview(label)
          NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
          ])
          return container
        }
      ),
      .chevronTitle(
        id: .sort,
        itemID: "sort",
        title: { "View controller" },
        content: .viewController { FKTabBarFilterSortPanelExampleViewController() }
      ),
    ]

    var config = FKTabBarFilterDropdownConfiguration.default
    config.applyTintOnlyChevronTabTypography()

    return FKTabBarFilterDropdownController(
      tabs: tabs,
      tabBarHost: host,
      configuration: config,
      events: FKTabBarFilterDropdownConfiguration.Events(
        onExpandedTabChange: { [weak self] expanded in
          self?.appendLog("expandedTab: \(expanded?.rawValue ?? "nil")")
        }
      )
    )
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "UIView content"
    view.backgroundColor = .systemBackground
    dropdown.embed(in: self)
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: dropdown.view)
    appendLog("Compare Content.view vs Content.viewController on the same strip.")
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }
}
