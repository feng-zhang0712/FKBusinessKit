import UIKit
import FKUIKit

/// Business row with optional leading icon and trailing switch.
@MainActor
public final class FKInlineToggleCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKInlineToggleItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for inline toggle rows.
  public static let preferredRowHeight: CGFloat = 64

  /// Row-specific configuration.
  public var inlineToggleConfiguration: FKInlineToggleCellConfiguration = FKCellKitDefaults.inlineToggleCell {
    didSet { applyInlineToggleConfiguration() }
  }

  private var leadingIcon: FKCellKitLeadingSymbolView?
  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private let toggleSwitch = UISwitch()
  private let textStack = UIStackView()
  private let rowStack = UIStackView()
  private var leadingWidthConstraint: NSLayoutConstraint?
  private var boundItemID: String?
  private var boundHandlerID: String?
  private var isApplyingSwitchState = false

  /// Binds an inline toggle item to the row UI.
  public func configure(with item: FKInlineToggleItem) {
    boundItemID = item.id
    boundHandlerID = item.switchHandlerID

    if let symbol = item.leadingSymbolName, !symbol.isEmpty {
      ensureLeadingIcon().symbolName = symbol
    } else {
      releaseLeadingIcon()
    }

    titleLabel.text = item.title
    if let subtitle = item.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    isApplyingSwitchState = true
    toggleSwitch.isOn = item.isOn
    toggleSwitch.isEnabled = item.isEnabled
    isApplyingSwitchState = false

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(textStack)
    rowStack.addArrangedSubview(toggleSwitch)

    containerView.addSubview(rowStack)

    NSLayoutConstraint.activate([
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: rowStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyInlineToggleConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    releaseLeadingIcon()
    titleLabel.text = nil
    releaseSubtitleLabel()
    isApplyingSwitchState = true
    toggleSwitch.isOn = false
    toggleSwitch.isEnabled = true
    isApplyingSwitchState = false
    boundItemID = nil
    boundHandlerID = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyInlineToggleConfiguration()
  }

  @objc private func switchValueChanged() {
    guard !isApplyingSwitchState,
          let boundItemID,
          let boundHandlerID,
          let controller = FKCellKitResponderLookup.diffableTableController(from: self),
          let handler = controller.switchHandlerRegistry.handler(for: boundHandlerID) else {
      return
    }
    handler(FKListItemID(boundItemID), toggleSwitch.isOn)
  }

  private func applyInlineToggleConfiguration() {
    cellConfiguration = inlineToggleConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: inlineToggleConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: inlineToggleConfiguration.subtitleTextStyle)
    leadingWidthConstraint?.constant = inlineToggleConfiguration.leadingSymbolSide
    leadingIcon?.symbolSide = inlineToggleConfiguration.leadingSymbolSide
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureLeadingIcon() -> FKCellKitLeadingSymbolView {
    if let leadingIcon { return leadingIcon }

    let icon = FKCellKitLeadingSymbolView()
    icon.symbolSide = inlineToggleConfiguration.leadingSymbolSide
    icon.translatesAutoresizingMaskIntoConstraints = false
    leadingIcon = icon
    rowStack.insertArrangedSubview(icon, at: 0)

    leadingWidthConstraint = icon.widthAnchor.constraint(
      equalToConstant: inlineToggleConfiguration.leadingSymbolSide
    )

    NSLayoutConstraint.activate([
      leadingWidthConstraint!,
      icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
    ])
    return icon
  }

  private func releaseLeadingIcon() {
    guard let leadingIcon else { return }
    leadingIcon.symbolName = nil
    leadingIcon.prepareForReuse()
    rowStack.removeArrangedSubview(leadingIcon)
    leadingIcon.removeFromSuperview()
    self.leadingIcon = nil
    leadingWidthConstraint = nil
  }

  @discardableResult
  private func ensureSubtitleLabel() -> UILabel {
    if let subtitleLabel { return subtitleLabel }
    let label = UILabel()
    label.numberOfLines = 2
    label.textColor = .secondaryLabel
    subtitleLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseSubtitleLabel() {
    guard let subtitleLabel else { return }
    subtitleLabel.text = nil
    textStack.removeArrangedSubview(subtitleLabel)
    subtitleLabel.removeFromSuperview()
    self.subtitleLabel = nil
  }

  private func updateAccessibility(for item: FKInlineToggleItem) {
    var components = [item.title, item.isOn ? "On" : "Off"]
    if let subtitle = item.subtitle, !subtitle.isEmpty { components.insert(subtitle, at: 1) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
