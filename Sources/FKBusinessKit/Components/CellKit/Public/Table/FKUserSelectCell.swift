import UIKit
import FKUIKit

/// Multi-select user row with leading selection affordance and ``FKUserListLeadingView`` content.
@MainActor
public final class FKUserSelectCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKUserSelectItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for user selection lists.
  public static let preferredRowHeight: CGFloat = FKCellKitLayoutMetrics.minimumTableRowHeight()

  /// Row-specific configuration.
  public var userSelectConfiguration: FKUserSelectCellConfiguration = FKCellKitDefaults.userSelectCell {
    didSet { applyUserSelectConfiguration() }
  }

  private let selectionImageView = UIImageView()
  private let leadingView = FKUserListLeadingView()
  private let rowStack = UIStackView()
  private var selectionWidthConstraint: NSLayoutConstraint?
  private var isRowSelected = false

  /// Binds a user selection item to the row UI.
  public func configure(with item: FKUserSelectItem) {
    isRowSelected = item.isSelected
    applySelectionAppearance(isSelected: isRowSelected)

    leadingView.apply(
      FKUserListLeadingDisplayModel(
        displayName: item.displayName,
        subtitle: item.subtitle,
        avatarURL: item.avatarURL,
        presenceState: item.presenceState,
        isVerified: item.isVerified
      )
    )

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    selectionImageView.contentMode = .scaleAspectFit
    selectionImageView.translatesAutoresizingMaskIntoConstraints = false

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(selectionImageView)
    rowStack.addArrangedSubview(leadingView)

    containerView.addSubview(rowStack)

    selectionWidthConstraint = selectionImageView.widthAnchor.constraint(
      equalToConstant: userSelectConfiguration.selectionSymbolSide
    )

    NSLayoutConstraint.activate([
      selectionWidthConstraint!,
      selectionImageView.heightAnchor.constraint(equalTo: selectionImageView.widthAnchor),
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: rowStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyUserSelectConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    selectionImageView.image = nil
    isRowSelected = false
    leadingView.prepareForReuse()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyUserSelectConfiguration()
  }

  private func applyUserSelectConfiguration() {
    cellConfiguration = userSelectConfiguration.table
    leadingView.configuration = userSelectConfiguration.leading
    selectionWidthConstraint?.constant = userSelectConfiguration.selectionSymbolSide
    applySelectionAppearance(isSelected: isRowSelected)
    applyCellConfiguration()
  }

  private func applySelectionAppearance(isSelected: Bool) {
    let config = userSelectConfiguration
    let symbolName = isSelected ? config.selectedSymbolName : config.unselectedSymbolName
    selectionImageView.image = UIImage(systemName: symbolName)
    selectionImageView.tintColor = isSelected ? config.selectionTintColor : config.unselectedTintColor
  }

  private func updateAccessibility(for item: FKUserSelectItem) {
    var components = [item.displayName]
    if let subtitle = item.subtitle, !subtitle.isEmpty { components.append(subtitle) }
    components.append(item.isSelected ? "Selected" : "Not selected")
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKUserSelectCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {}
}
