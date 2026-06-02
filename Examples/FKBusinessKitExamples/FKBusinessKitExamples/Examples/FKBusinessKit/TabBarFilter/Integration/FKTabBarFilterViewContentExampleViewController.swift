import UIKit
import FKUIKit
import FKBusinessKit

/// ``FKTabBarFilterTabPanelContent/view`` hosting (no dedicated child view controller per tab).
final class FKTabBarFilterViewContentExampleViewController: UIViewController {
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterTabBarHostView()
  private lazy var filter: FKTabBarFilterController<FKTabBarFilterExampleTabID> = {
    let tabs: [FKTabBarFilterTab<FKTabBarFilterExampleTabID>] = [
      FKTabBarFilterTab(
        id: .filters,
        title: { "UIView" },
        subtitle: { "Lightweight host" },
        panelContent: .view {
          let container = UIView()
          container.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.12)

          let label = UILabel()
          label.text = "Content from panelContent.view — FKTabBarFilterViewWrappingController"
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
      FKTabBarFilterTab(
        id: .sort,
        title: { "View controller" },
        panelContent: .viewController { FKTabBarFilterSortPanelExampleViewController() }
      ),
    ]

    var configuration = FKTabBarFilterConfiguration<FKTabBarFilterExampleTabID>()
    configuration.applyTintOnlyChevronTabTypography()
    configuration.events = FKTabBarFilterConfiguration.Events(
      onExpandedTabChange: { [weak self] expanded in
        self?.appendLog("expandedTab: \(expanded?.rawValue ?? "nil")")
      }
    )

    let factory = FKTabBarFilterPanelFactory(sourcesByPanelKind: [:], loadingTitle: FKTabBarFilterExampleAppearance.panelLoadingTitle)
    return FKTabBarFilterController(
      tabs: tabs,
      panelFactory: factory,
      configuration: configuration,
      tabBarHost: host
    )
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "UIView content"
    view.backgroundColor = .systemBackground
    filter.embed(in: self)
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: filter.view)
    appendLog("Compare panelContent.view vs panelContent.viewController on the same strip.")
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }
}
