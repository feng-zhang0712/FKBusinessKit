#if canImport(SwiftUI)
import FKBusinessKit
import FKUIKit
import SwiftUI
import UIKit

/// Hosts ``FKCellKitDiffableTableViewRepresentable`` inside UIKit navigation.
final class FKCellKitSwiftUIHostExampleViewController: UIHostingController<FKCellKitSwiftUIDemoRootView> {
  init() {
    super.init(rootView: FKCellKitSwiftUIDemoRootView())
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "SwiftUI Bridge"
  }
}

/// SwiftUI root embedding a CellKit-enabled diffable table controller.
struct FKCellKitSwiftUIDemoRootView: View {
  var body: some View {
    FKCellKitDiffableTableViewRepresentable(
      configuration: FKListDefaults.feedConfiguration,
      makeViewController: { configuration, style in
        FKCellKitSwiftUIDemoTableController(configuration: configuration, style: style)
      }
    )
    .ignoresSafeArea(edges: .bottom)
  }
}

/// Loads ``FKUserListCell`` rows for the SwiftUI bridge demo.
final class FKCellKitSwiftUIDemoTableController: FKCellKitDiffableTableViewController {
  override func viewDidLoad() {
    registersAllCellKitTableCells = false
    FKCellKitListRegistration.registerUserListCell(on: self)
    let users = FKCellKitExampleSampleData.users
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    super.viewDidLoad()
    tableView.rowHeight = FKUserListCell.preferredRowHeight
    applySnapshot(
      FKCellKitExampleSampleData.makeUserListSnapshot(users),
      animatingDifferences: false
    )
  }
}
#endif
