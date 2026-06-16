import UIKit
import FKUIKit

/// Row with title and embedded ``FKChipGroup`` for inline tag selection.
@MainActor
public final class FKTagPickerCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKTagPickerItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended minimum row height for tag picker rows.
  public static let preferredRowHeight: CGFloat = 96

  /// Row-specific configuration.
  public var tagPickerConfiguration: FKTagPickerCellConfiguration = FKCellKitDefaults.tagPickerCell {
    didSet { applyTagPickerConfiguration() }
  }

  private let titleLabel = UILabel()
  private let chipGroup = FKChipGroup()
  private let contentStack = UIStackView()
  private var boundItemID: String?
  private var boundHandlerID: String?
  private var isApplyingSelection = false

  /// Binds a tag picker item to the row UI.
  public func configure(with item: FKTagPickerItem) {
    boundItemID = item.id
    boundHandlerID = item.chipHandlerID
    titleLabel.text = item.title

    isApplyingSelection = true
    chipGroup.selectionMode = item.selectionMode
    chipGroup.chips = item.chips
    chipGroup.setSelectedIDs(Set(item.selectedChipIDs), animated: false)
    isApplyingSelection = false

    chipGroup.onSelectionChange = { [weak self] selected in
      self?.forwardSelectionChange(selected)
    }

    chipGroup.isUserInteractionEnabled = item.isEnabled
    chipGroup.alpha = item.isEnabled ? 1 : 0.45

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 1

    contentStack.axis = .vertical
    contentStack.alignment = .fill
    contentStack.spacing = tagPickerConfiguration.sectionSpacing
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(titleLabel)
    contentStack.addArrangedSubview(chipGroup)

    containerView.addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyTagPickerConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    titleLabel.text = nil
    chipGroup.chips = []
    chipGroup.onSelectionChange = nil
    chipGroup.isUserInteractionEnabled = true
    chipGroup.alpha = 1
    boundItemID = nil
    boundHandlerID = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyTagPickerConfiguration()
  }

  private func applyTagPickerConfiguration() {
    cellConfiguration = tagPickerConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: tagPickerConfiguration.titleTextStyle)
    chipGroup.configuration = tagPickerConfiguration.chipGroup
    contentStack.spacing = tagPickerConfiguration.sectionSpacing
    applyCellConfiguration()
  }

  private func forwardSelectionChange(_ selected: Set<String>) {
    guard !isApplyingSelection,
          let boundItemID,
          let boundHandlerID,
          let controller = FKCellKitResponderLookup.diffableTableController(from: self),
          let handler = controller.cellKitValueHandlers.chipSelectionHandler(for: boundHandlerID) else {
      return
    }
    handler(FKListItemID(boundItemID), selected)
  }

  private func updateAccessibility(for item: FKTagPickerItem) {
    let selectedTitles = item.chips
      .filter { item.selectedChipIDs.contains($0.id) }
      .map(\.title)
    accessibilityLabel = ([item.title] + selectedTitles).joined(separator: ", ")
  }
}
