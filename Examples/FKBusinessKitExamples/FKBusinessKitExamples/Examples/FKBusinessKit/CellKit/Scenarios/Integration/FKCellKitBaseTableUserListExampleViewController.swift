import FKBusinessKit
import UIKit

/// Demonstrates traditional ``FKBaseTableViewController`` dequeue of ``FKUserListCell``.
final class FKCellKitBaseTableUserListExampleViewController: FKBusinessKitBase.TableViewController, UITableViewDataSource {
  private let users = FKCellKitExampleSampleData.users

  init() {
    super.init(style: .plain)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Base Table · User List"
  }

  override func configureTableView(_ tableView: UITableView) {
    super.configureTableView(tableView)
    tableView.dataSource = self
    tableView.rowHeight = FKUserListCell.preferredRowHeight
    tableView.estimatedRowHeight = FKUserListCell.preferredRowHeight
    tableView.register(FKUserListCell.self, forCellReuseIdentifier: FKUserListCell.listKitCellTypeIdentifier)
  }

  override func loadInitialContent() {
    super.loadInitialContent()
    tableView.reloadData()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    users.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: FKUserListCell.listKitCellTypeIdentifier,
      for: indexPath
    ) as! FKUserListCell
    cell.configure(with: users[indexPath.row])
    return cell
  }
}
