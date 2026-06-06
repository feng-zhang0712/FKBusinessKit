import UIKit

/// Entry list for FKUIKit Base demos (each row maps to one scenario file).
final class FKBaseExamplesHubViewController: UITableViewController {

  private enum Row: Int, CaseIterable {
    case viewController
    case scroll
    case table
    case collection
    case composition
    case search

    var title: String {
      switch self {
      case .viewController: return "FKBaseViewController"
      case .scroll: return "FKBaseScrollViewController"
      case .table: return "FKBaseTableViewController"
      case .collection: return "FKBaseCollectionViewController"
      case .composition: return "Composition (no base VC)"
      case .search: return "Search + FKBaseSearchIntegration"
      }
    }

    var subtitle: String {
      switch self {
      case .viewController:
        return "Lifecycle, overlays, toast, keyboard, nav chrome, loadInitialContent"
      case .scroll:
        return "UIScrollView + contentView, keyboard avoidance, pull-to-refresh"
      case .table:
        return "UITableView base, refresh/load-more, skeleton & empty-state scenarios"
      case .collection:
        return "UICollectionView base, refresh/load-more, skeleton & empty-state scenarios"
      case .composition:
        return "FKViewControllerComposite + build phases + lifecycle forwarding"
      case .search:
        return "UISearchController embedded via navigationItem"
      }
    }

    func makeDestination() -> UIViewController {
      switch self {
      case .viewController: return FKBaseViewControllerExampleViewController()
      case .scroll: return FKBaseScrollViewControllerExampleViewController()
      case .table: return FKBaseTableExamplesHubViewController()
      case .collection: return FKBaseCollectionExamplesHubViewController()
      case .composition: return FKBaseCompositionExampleViewController()
      case .search: return FKBaseSearchExampleViewController()
      }
    }
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
    title = "Base"
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.cellLayoutMarginsFollowReadableWidth = true
    tableView.estimatedRowHeight = 88
    tableView.rowHeight = UITableView.automaticDimension
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    Row.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let row = Row.allCases[indexPath.row]
    var content = cell.defaultContentConfiguration()
    content.text = row.title
    content.secondaryText = row.subtitle
    content.secondaryTextProperties.color = .secondaryLabel
    content.secondaryTextProperties.numberOfLines = 0
    cell.contentConfiguration = content
    cell.accessoryType = .disclosureIndicator
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    navigationController?.pushViewController(Row.allCases[indexPath.row].makeDestination(), animated: true)
  }
}
