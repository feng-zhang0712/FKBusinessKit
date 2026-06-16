import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKPaymentMethodCell`` icon rows and trailing selection state.
final class FKCellKitPaymentMethodExampleViewController: FKDiffableTableViewController {
  private var methods = FKCellKitExampleSampleData.paymentMethods

  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Payment Methods"
    FKCellKitListRegistration.registerPaymentMethodCell(on: self)
    didSelectItem = { [weak self] id in
      self?.selectPaymentMethod(id: id)
    }
    super.viewDidLoad()
    tableView.rowHeight = FKPaymentMethodCell.preferredRowHeight
    applyMethods(animated: false)
  }

  private func selectPaymentMethod(id: FKListItemID) {
    methods = methods.map { item in
      var copy = item
      copy.isSelected = item.id == id.rawValue
      return copy
    }
    FKCellKitListItemFactory.storePaymentMethodPayloads(methods, on: self)
    applyMutation(.reconfigureItems(methods.map { .init($0.id) }), animatingDifferences: false)
  }

  private func applyMethods(animated: Bool) {
    FKCellKitListItemFactory.storePaymentMethodPayloads(methods, on: self)
    applySnapshot(
      FKListSnapshot(items: methods.map(FKCellKitListItemFactory.paymentMethod)),
      animatingDifferences: animated
    )
  }
}
