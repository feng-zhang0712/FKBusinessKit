import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKTabBarFilterController`` chrome above a CellKit ``FKUserListCell`` list.
final class FKCellKitTabBarFilterUserListExampleViewController: UIViewController {
  private enum FilterTab: String, Hashable {
    case all
    case unread
  }

  private let filterHost = FKTabBarFilterTabBarHostView()
  private let listController = FKCellKitTabBarFilterUserListContentViewController()
  private lazy var filterController = makeFilterController()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Filter + User List"
    view.backgroundColor = .systemBackground

    filterController.embed(in: self)

    addChild(listController)
    listController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(listController.view)
    NSLayoutConstraint.activate([
      listController.view.topAnchor.constraint(equalTo: filterController.view.bottomAnchor),
      listController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      listController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      listController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    listController.didMove(toParent: self)
  }

  private func makeFilterController() -> FKTabBarFilterController<FilterTab> {
    let tabs: [FKTabBarFilterTab<FilterTab>] = [
      FKTabBarFilterTab(
        id: .all,
        title: { "All contacts" },
        panelContent: .view {
          Self.makeHintLabel("Showing every contact in the CellKit list below.")
        }
      ),
      FKTabBarFilterTab(
        id: .unread,
        title: { "Unread" },
        subtitle: { "2+" },
        panelContent: .view {
          Self.makeHintLabel("Only rows with unread badges remain visible.")
        }
      ),
    ]

    var configuration = FKTabBarFilterConfiguration<FilterTab>()
    configuration.applyTintOnlyChevronTabTypography()
    configuration.events = FKTabBarFilterConfiguration.Events(
      onDidSwitchTab: { [weak self] _, to in
        self?.listController.applyFilter(to == .unread ? .unreadOnly : .all)
      }
    )

    let controller = FKTabBarFilterController(
      tabs: tabs,
      configuration: configuration,
      tabBarHost: filterHost
    )
    controller.selectTab(.all, animated: false)
    return controller
  }

  private static func makeHintLabel(_ text: String) -> UIView {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false

    let container = UIView()
    container.backgroundColor = .clear
    container.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
      label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
    ])
    return container
  }
}

/// List child filtered by the TabBarFilter strip selection.
final class FKCellKitTabBarFilterUserListContentViewController: FKDiffableTableViewController {
  private var activeFilter: FKCellKitExampleUserFilter = .all

  init() {
    var configuration = FKListDefaults.defaultConfiguration
    configuration.loading.usesSkeletonForInitialLoad = false
    super.init(configuration: configuration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    FKCellKitListRegistration.registerUserListCell(on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKUserListCell.preferredRowHeight
    applyFilter(.all)
  }

  func applyFilter(_ filter: FKCellKitExampleUserFilter) {
    activeFilter = filter
    let users = FKCellKitExampleSampleData.users(matching: filter)
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    applySnapshot(
      FKCellKitExampleSampleData.makeUserListSnapshot(users),
      animatingDifferences: true
    )
  }
}
