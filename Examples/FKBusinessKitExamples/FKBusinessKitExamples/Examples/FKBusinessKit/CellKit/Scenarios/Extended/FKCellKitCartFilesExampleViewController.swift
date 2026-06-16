import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKCartLineItemCell``, ``FKCartQuantityCell``, and ``FKFileAttachmentCell``.
final class FKCellKitCartFilesExampleViewController: FKDiffableTableViewController {
  private var cartQuantityItems = FKCellKitExampleSampleData.cartQuantityItems

  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Cart & Attachments"
    FKCellKitListRegistration.registerCartLineItemCell(on: self)
    FKCellKitListRegistration.registerCartQuantityCell(on: self)
    FKCellKitListRegistration.registerFileAttachmentCell(on: self)

    cellKitValueHandlers.registerQuantity(id: "cellkit.cart.quantity") { [weak self] itemID, quantity in
      self?.updateQuantity(id: itemID, quantity: quantity)
    }

    super.viewDidLoad()
    tableView.rowHeight = FKCartQuantityCell.preferredRowHeight
    tableView.estimatedRowHeight = FKCartQuantityCell.preferredRowHeight
    applyContent(animated: false)
  }

  private func updateQuantity(id: FKListItemID, quantity: Int) {
    cartQuantityItems = cartQuantityItems.map { item in
      guard item.id == id.rawValue else { return item }
      var copy = item
      copy.quantity = quantity
      return copy
    }
    FKCellKitListItemFactory.storeCartQuantityPayloads(cartQuantityItems, on: self)
    applyMutation(.reconfigureItems(cartQuantityItems.map { .init($0.id) }), animatingDifferences: false)
  }

  private func applyContent(animated: Bool) {
    let lines = FKCellKitExampleSampleData.cartLineItems
    let files = FKCellKitExampleSampleData.fileAttachments
    FKCellKitListItemFactory.storeCartLineItemPayloads(lines, on: self)
    FKCellKitListItemFactory.storeCartQuantityPayloads(cartQuantityItems, on: self)
    FKCellKitListItemFactory.storeFileAttachmentPayloads(files, on: self)

    applySnapshot(
      FKListSnapshot(sections: [
        FKListSection(
          id: "cart-readonly",
          items: lines.map(FKCellKitListItemFactory.cartLineItem),
          header: .title("Cart summary")
        ),
        FKListSection(
          id: "cart-qty",
          items: cartQuantityItems.map(FKCellKitListItemFactory.cartQuantity),
          header: .title("Editable quantities")
        ),
        FKListSection(
          id: "files",
          items: files.map(FKCellKitListItemFactory.fileAttachment),
          header: .title("Attachments")
        ),
      ]),
      animatingDifferences: animated
    )
  }
}

extension FKCellKitCartFilesExampleViewController: FKListDelegate {
  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
  }
}
