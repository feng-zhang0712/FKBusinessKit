import UIKit
import FKUIKit

/// Order / ticket list row with optional leading icon, copy chip, and status pill.
@MainActor
public final class FKOrderListCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKOrderListItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for order lists.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var orderListConfiguration: FKOrderListCellConfiguration = FKCellKitDefaults.orderListCell {
    didSet { applyOrderListConfiguration() }
  }

  private var leadingIcon: FKCellKitLeadingSymbolView?
  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private let textStack = UIStackView()
  private let metaRow = FKOrderMetaRowView()
  private let contentStack = UIStackView()
  private var leadingWidthConstraint: NSLayoutConstraint?
  private var contentStackLeadingToContainer: NSLayoutConstraint?
  private var contentStackLeadingToIcon: NSLayoutConstraint?

  /// Binds an order list item to the row UI.
  public func configure(with item: FKOrderListItem) {
    if let symbolName = item.leadingSymbolName, !symbolName.isEmpty {
      ensureLeadingIcon().symbolName = symbolName
    } else {
      releaseLeadingIcon()
    }

    titleLabel.text = item.title
    if let subtitle = item.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    metaRow.apply(
      displayOrderNumber: item.displayOrderNumber,
      fullOrderNumber: item.fullOrderNumber,
      statusPill: item.statusPill,
      showsCopyChip: item.showsCopyChip
    )

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    contentStack.axis = .vertical
    contentStack.alignment = .fill
    contentStack.spacing = orderListConfiguration.metaSpacing
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(textStack)
    contentStack.addArrangedSubview(metaRow)

    containerView.addSubview(contentStack)

    contentStackLeadingToContainer = contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)

    NSLayoutConstraint.activate([
      contentStackLeadingToContainer!,
      contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: contentStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyOrderListConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    releaseLeadingIcon()
    titleLabel.text = nil
    releaseSubtitleLabel()
    metaRow.prepareForReuse()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyOrderListConfiguration()
  }

  private func applyOrderListConfiguration() {
    cellConfiguration = orderListConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: orderListConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: orderListConfiguration.subtitleTextStyle)
    leadingWidthConstraint?.constant = orderListConfiguration.leadingSymbolSide
    leadingIcon?.symbolSide = orderListConfiguration.leadingSymbolSide
    contentStack.spacing = orderListConfiguration.metaSpacing
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureLeadingIcon() -> FKCellKitLeadingSymbolView {
    if let leadingIcon { return leadingIcon }

    let icon = FKCellKitLeadingSymbolView()
    icon.symbolSide = orderListConfiguration.leadingSymbolSide
    icon.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(icon)
    leadingIcon = icon

    leadingWidthConstraint = icon.widthAnchor.constraint(
      equalToConstant: orderListConfiguration.leadingSymbolSide
    )

    contentStackLeadingToContainer?.isActive = false
    contentStackLeadingToIcon?.isActive = false
    contentStackLeadingToIcon = contentStack.leadingAnchor.constraint(
      equalTo: icon.trailingAnchor,
      constant: FKCellKitLayoutMetrics.interPartSpacing
    )

    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      icon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      leadingWidthConstraint!,
      icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
      contentStackLeadingToIcon!,
    ])
    return icon
  }

  private func releaseLeadingIcon() {
    guard let leadingIcon else { return }
    leadingIcon.symbolName = nil
    leadingIcon.prepareForReuse()
    leadingIcon.removeFromSuperview()
    self.leadingIcon = nil
    leadingWidthConstraint = nil

    contentStackLeadingToIcon?.isActive = false
    contentStackLeadingToIcon = nil
    contentStackLeadingToContainer?.isActive = true
  }

  @discardableResult
  private func ensureSubtitleLabel() -> UILabel {
    if let subtitleLabel { return subtitleLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: orderListConfiguration.subtitleTextStyle)
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

  private func updateAccessibility(for item: FKOrderListItem) {
    var components = [item.title, item.statusPill.title]
    if let subtitle = item.subtitle, !subtitle.isEmpty {
      components.insert(subtitle, at: 1)
    }
    if item.showsCopyChip {
      components.append("Order \(item.displayOrderNumber)")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
