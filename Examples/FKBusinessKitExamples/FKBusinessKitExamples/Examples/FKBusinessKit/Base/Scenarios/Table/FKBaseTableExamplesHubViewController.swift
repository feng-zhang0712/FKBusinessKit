import UIKit

/// Secondary hub for ``FKBaseTableViewController`` basics and list presentation scenarios.
final class FKBaseTableExamplesHubViewController: UITableViewController {

  private enum Section: Int, CaseIterable {
    case basics
    case keyboard
    case scenarios
  }

  init() {
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "FKBaseTableViewController"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.cellLayoutMarginsFollowReadableWidth = true
    tableView.estimatedRowHeight = 88
    tableView.rowHeight = UITableView.automaticDimension
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section)! {
    case .basics: return "Basics"
    case .keyboard: return "Keyboard"
    case .scenarios: return "List presentation scenarios"
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .basics: return 1
    case .keyboard: return 1
    case .scenarios: return FKBaseListDemoScenario.allCases.count
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var content = cell.defaultContentConfiguration()
    switch Section(rawValue: indexPath.section)! {
    case .basics:
      content.text = "Refresh & load-more"
      content.secondaryText = "Pull-to-refresh, pagination footer, prefetch hook."
    case .keyboard:
      content.text = "Keyboard avoidance"
      content.secondaryText = "Bottom UITextField + UITextView rows — scroll down to test."
    case .scenarios:
      let scenario = FKBaseListDemoScenario.allCases[indexPath.row]
      content.text = scenario.title
      content.secondaryText = scenario.subtitle
    }
    content.secondaryTextProperties.color = .secondaryLabel
    content.secondaryTextProperties.numberOfLines = 0
    cell.contentConfiguration = content
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let destination: UIViewController
    switch Section(rawValue: indexPath.section)! {
    case .basics:
      destination = FKBaseTableBasicsExampleViewController()
    case .keyboard:
      destination = FKBaseTableKeyboardExampleViewController()
    case .scenarios:
      destination = FKBaseTableListScenarioExampleViewController(
        scenario: FKBaseListDemoScenario.allCases[indexPath.row]
      )
    }
    navigationController?.pushViewController(destination, animated: true)
  }
}
