import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates interactive CellKit rows: select, toggle, tag picker, rating input, and invite code.
final class FKCellKitInteractiveRowsExampleViewController: FKDiffableTableViewController {
  private var userSelectItems = FKCellKitExampleSampleData.userSelectItems
  private var inlineToggleItems = FKCellKitExampleSampleData.inlineToggleItems
  private var tagPickerItems = FKCellKitExampleSampleData.tagPickerItems
  private var ratingInputItems = FKCellKitExampleSampleData.ratingInputItems

  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Interactive Rows"
    FKCellKitListRegistration.registerUserSelectCell(on: self)
    FKCellKitListRegistration.registerInlineToggleCell(on: self)
    FKCellKitListRegistration.registerTagPickerCell(on: self)
    FKCellKitListRegistration.registerRatingInputCell(on: self)
    FKCellKitListRegistration.registerInviteCodeCell(on: self)

    didSelectItem = { [weak self] id in
      self?.toggleUserSelection(id: id)
    }

    switchHandlerRegistry.register(id: "cellkit.toggle.mute") { [weak self] itemID, isOn in
      self?.updateToggle(id: itemID, isOn: isOn)
    }
    switchHandlerRegistry.register(id: "cellkit.toggle.pin") { [weak self] itemID, isOn in
      self?.updateToggle(id: itemID, isOn: isOn)
    }

    cellKitValueHandlers.registerChipSelection(id: "cellkit.picker.size") { [weak self] itemID, selected in
      self?.updateChipSelection(id: itemID, selected: selected)
    }
    cellKitValueHandlers.registerRating(id: "cellkit.rating.product") { [weak self] itemID, rating in
      self?.updateRating(id: itemID, rating: rating)
    }
    cellKitValueHandlers.registerShare(id: "cellkit.invite.share") { _ in
      // Host app would present UIActivityViewController or deep-link share sheet.
    }

    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = FKUserSelectCell.preferredRowHeight
    applyContent(animated: false)
  }

  private func toggleUserSelection(id: FKListItemID) {
    userSelectItems = userSelectItems.map { item in
      guard item.id == id.rawValue else { return item }
      var copy = item
      copy.isSelected.toggle()
      return copy
    }
    FKCellKitListItemFactory.storeUserSelectPayloads(userSelectItems, on: self)
    applyMutation(.reconfigureItems([id]), animatingDifferences: false)
  }

  private func updateToggle(id: FKListItemID, isOn: Bool) {
    inlineToggleItems = inlineToggleItems.map { item in
      guard item.id == id.rawValue else { return item }
      var copy = item
      copy.isOn = isOn
      return copy
    }
    FKCellKitListItemFactory.storeInlineTogglePayloads(inlineToggleItems, on: self)
    applyMutation(.reconfigureItems([id]), animatingDifferences: false)
  }

  private func updateChipSelection(id: FKListItemID, selected: Set<String>) {
    tagPickerItems = tagPickerItems.map { item in
      guard item.id == id.rawValue else { return item }
      var copy = item
      copy.selectedChipIDs = Array(selected)
      return copy
    }
    FKCellKitListItemFactory.storeTagPickerPayloads(tagPickerItems, on: self)
    applyMutation(.reconfigureItems([id]), animatingDifferences: false)
  }

  private func updateRating(id: FKListItemID, rating: Double) {
    ratingInputItems = ratingInputItems.map { item in
      guard item.id == id.rawValue else { return item }
      var copy = item
      copy.rating = rating
      return copy
    }
    FKCellKitListItemFactory.storeRatingInputPayloads(ratingInputItems, on: self)
    applyMutation(.reconfigureItems([id]), animatingDifferences: false)
  }

  private func applyContent(animated: Bool) {
    let invites = FKCellKitExampleSampleData.inviteCodeItems
    FKCellKitListItemFactory.storeUserSelectPayloads(userSelectItems, on: self)
    FKCellKitListItemFactory.storeInlineTogglePayloads(inlineToggleItems, on: self)
    FKCellKitListItemFactory.storeTagPickerPayloads(tagPickerItems, on: self)
    FKCellKitListItemFactory.storeRatingInputPayloads(ratingInputItems, on: self)
    FKCellKitListItemFactory.storeInviteCodePayloads(invites, on: self)

    applySnapshot(
      FKListSnapshot(sections: [
        FKListSection(
          id: "select",
          items: userSelectItems.map(FKCellKitListItemFactory.userSelect),
          header: .title("Multi-select users")
        ),
        FKListSection(
          id: "toggle",
          items: inlineToggleItems.map(FKCellKitListItemFactory.inlineToggle),
          header: .title("Inline toggles")
        ),
        FKListSection(
          id: "picker",
          items: tagPickerItems.map(FKCellKitListItemFactory.tagPicker),
          header: .title("Tag picker")
        ),
        FKListSection(
          id: "rating",
          items: ratingInputItems.map(FKCellKitListItemFactory.ratingInput),
          header: .title("Rating input")
        ),
        FKListSection(
          id: "invite",
          items: invites.map(FKCellKitListItemFactory.inviteCode),
          header: .title("Invite code")
        ),
      ]),
      animatingDifferences: animated
    )
  }
}

extension FKCellKitInteractiveRowsExampleViewController: FKListDelegate {
  func list(_ list: FKDiffableTableViewController, willDisplay item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityWillDisplay(at: indexPath)
  }

  func list(_ list: FKDiffableTableViewController, didEndDisplaying item: FKListItemID, at indexPath: IndexPath) {
    forwardCellKitVisibilityDidEndDisplaying(at: indexPath)
  }
}
