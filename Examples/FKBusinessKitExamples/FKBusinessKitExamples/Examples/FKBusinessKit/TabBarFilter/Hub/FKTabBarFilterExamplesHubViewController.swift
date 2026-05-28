import UIKit
import FKUIKit
import FKBusinessKit

/// Table entry list for TabBarFilter: anchored dropdown hosting, filter panels, and integration patterns.
final class FKTabBarFilterExamplesHubViewController: UITableViewController {

  private enum Row: Int, CaseIterable {
    case tabBarAnchor
    case customViewAnchor
    case dropdownFilterExamples
    case twoColumnListExamples
    case twoColumnGridExamples
    case chipsPanelExamples
    case singleListPanelExamples

    var title: String {
      switch self {
      case .tabBarAnchor:
        return "Tab bar anchor"
      case .customViewAnchor:
        return "Custom view anchor"
      case .dropdownFilterExamples:
        return "Dropdown filter examples"
      case .twoColumnListExamples:
        return "Two-column list examples"
      case .twoColumnGridExamples:
        return "Two-column grid examples"
      case .chipsPanelExamples:
        return "Chips panel examples"
      case .singleListPanelExamples:
        return "Single-list panel examples"
      }
    }

    var subtitle: String {
      switch self {
      case .tabBarAnchor:
        return "Default: panel attaches to FKTabBar. Tabs, switch animations, optional Events hooks."
      case .customViewAnchor:
        return "Custom UIView anchor + tap; hidden tab bar (programmatic expand/collapse)."
      case .dropdownFilterExamples:
        return "FKTabBarFilterController patterns: tab layout, transitions, backdrop, and panel caching."
      case .twoColumnListExamples:
        return "Isolated FKTabBarFilterTwoColumnListViewController configurations."
      case .twoColumnGridExamples:
        return "Isolated FKTabBarFilterTwoColumnGridViewController configurations."
      case .chipsPanelExamples:
        return "Isolated FKTabBarFilterChipsViewController configurations."
      case .singleListPanelExamples:
        return "Isolated FKTabBarFilterSingleListViewController configurations."
      }
    }

    func makeViewController() -> UIViewController {
      switch self {
      case .tabBarAnchor:
        return FKTabBarFilterTabBarAnchorExampleViewController()
      case .customViewAnchor:
        return FKTabBarFilterCustomAnchorExampleViewController()
      case .dropdownFilterExamples:
        return FKTabBarFilterDropdownExamplesHubViewController()
      case .twoColumnListExamples:
        return FKTabBarFilterTwoColumnListExampleHubViewController()
      case .twoColumnGridExamples:
        return FKTabBarFilterTwoColumnGridExampleHubViewController()
      case .chipsPanelExamples:
        return FKTabBarFilterChipsPanelExampleHubViewController()
      case .singleListPanelExamples:
        return FKTabBarFilterSingleListPanelExampleHubViewController()
      }
    }
  }

  convenience init() {
    self.init(style: .insetGrouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "TabBarFilter"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.cellLayoutMarginsFollowReadableWidth = true
    tableView.rowHeight = 76
  }

  override func numberOfSections(in tableView: UITableView) -> Int { 1 }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    Row.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = Row.allCases[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var config = UIListContentConfiguration.subtitleCell()
    config.text = row.title
    config.secondaryText = row.subtitle
    config.secondaryTextProperties.color = .secondaryLabel
    cell.contentConfiguration = config
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let vc = Row.allCases[indexPath.row].makeViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
}
