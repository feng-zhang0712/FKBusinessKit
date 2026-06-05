import UIKit

/// Secondary hub for ``FKBaseCollectionViewController`` basics and list presentation scenarios.
final class FKBaseCollectionExamplesHubViewController: UITableViewController {

  private enum Section: Int, CaseIterable {
    case basics
    case scenarios
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "FKBaseCollectionViewController"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section)! {
    case .basics: return "Basics"
    case .scenarios: return "List presentation scenarios"
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .basics: return 1
    case .scenarios: return FKBaseListDemoScenario.allCases.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var content = cell.defaultContentConfiguration()
    switch Section(rawValue: indexPath.section)! {
    case .basics:
      content.text = "Refresh & load-more"
      content.secondaryText = "Two-column flow layout with refresh footer."
    case .scenarios:
      let scenario = FKBaseListDemoScenario.allCases[indexPath.row]
      content.text = scenario.title
      content.secondaryText = scenario.subtitle
    }
    content.secondaryTextProperties.color = .secondaryLabel
    cell.contentConfiguration = content
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let destination: UIViewController
    switch Section(rawValue: indexPath.section)! {
    case .basics:
      destination = FKBaseCollectionBasicsExampleViewController()
    case .scenarios:
      destination = FKBaseCollectionListScenarioExampleViewController(
        scenario: FKBaseListDemoScenario.allCases[indexPath.row]
      )
    }
    navigationController?.pushViewController(destination, animated: true)
  }
}
