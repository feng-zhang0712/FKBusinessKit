import UIKit
import FKUIKit
import FKBusinessKit

final class ExampleMenuViewController: UITableViewController {
  private enum Row: Int, CaseIterable {
    case base
    case tabBarFilter

    var title: String {
      switch self {
      case .base:
        return "Base"
      case .tabBarFilter:
        return "TabBarFilter"
      }
    }

    var subtitle: String {
      switch self {
      case .base:
        return "FKBaseViewController, table/collection bases, composition, and search integration."
      case .tabBarFilter:
        return "FKTabBarFilterController, anchoring, and panel component recipes."
      }
    }

    func makeViewController() -> UIViewController {
      switch self {
      case .base:
        return FKBaseExamplesHubViewController()
      case .tabBarFilter:
        return FKTabBarFilterExamplesHubViewController()
      }
    }
  }

  convenience init() {
    self.init(style: .insetGrouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "FKBusinessKit"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    Row.allCases.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let row = Row.allCases[indexPath.row]
    var config = UIListContentConfiguration.subtitleCell()
    config.text = row.title
    config.secondaryText = row.subtitle
    cell.contentConfiguration = config
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let row = Row.allCases[indexPath.row]
    navigationController?.pushViewController(row.makeViewController(), animated: true)
  }
}
