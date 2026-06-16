import UIKit
import FKUIKit

/// Payment method selection row with icon, title, subtitle, and trailing checkmark.
@MainActor
public final class FKPaymentMethodCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKPaymentMethodItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for payment method lists.
  public static let preferredRowHeight: CGFloat = 64

  /// Row-specific configuration.
  public var paymentMethodConfiguration: FKPaymentMethodCellConfiguration = FKCellKitDefaults.paymentMethodCell {
    didSet { applyPaymentMethodConfiguration() }
  }

  private var leadingIcon: FKCellKitLeadingSymbolView?
  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private var selectionImageView: UIImageView?
  private let textStack = UIStackView()
  private var leadingWidthConstraint: NSLayoutConstraint?
  private var selectionWidthConstraint: NSLayoutConstraint?
  private var textStackLeadingToContainer: NSLayoutConstraint?
  private var textStackLeadingToIcon: NSLayoutConstraint?
  private var textStackTrailingToContainer: NSLayoutConstraint?
  private var selectionConstraints: [NSLayoutConstraint] = []

  /// Binds a payment method item to the row UI.
  public func configure(with item: FKPaymentMethodItem) {
    if let symbolName = item.symbolName, !symbolName.isEmpty {
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

    if item.isSelected {
      ensureSelectionImageView()
    } else {
      releaseSelectionImageView()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.addArrangedSubview(titleLabel)

    containerView.addSubview(textStack)

    textStackLeadingToContainer = textStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    textStackTrailingToContainer = textStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

    NSLayoutConstraint.activate([
      textStackLeadingToContainer!,
      textStackTrailingToContainer!,
      textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      textStack.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
      textStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: containerView.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyPaymentMethodConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    releaseLeadingIcon()
    titleLabel.text = nil
    releaseSubtitleLabel()
    releaseSelectionImageView()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyPaymentMethodConfiguration()
  }

  private func applyPaymentMethodConfiguration() {
    cellConfiguration = paymentMethodConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: paymentMethodConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: paymentMethodConfiguration.subtitleTextStyle)
    leadingWidthConstraint?.constant = paymentMethodConfiguration.leadingSymbolSide
    leadingIcon?.symbolSide = paymentMethodConfiguration.leadingSymbolSide
    selectionWidthConstraint?.constant = paymentMethodConfiguration.selectionSymbolSide
    selectionImageView?.tintColor = paymentMethodConfiguration.selectionTintColor
    selectionImageView?.image = UIImage(systemName: paymentMethodConfiguration.selectionSymbolName)
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureLeadingIcon() -> FKCellKitLeadingSymbolView {
    if let leadingIcon { return leadingIcon }

    let icon = FKCellKitLeadingSymbolView()
    icon.symbolSide = paymentMethodConfiguration.leadingSymbolSide
    icon.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(icon)
    leadingIcon = icon

    leadingWidthConstraint = icon.widthAnchor.constraint(
      equalToConstant: paymentMethodConfiguration.leadingSymbolSide
    )

    textStackLeadingToContainer?.isActive = false
    textStackLeadingToIcon = textStack.leadingAnchor.constraint(
      equalTo: icon.trailingAnchor,
      constant: FKCellKitLayoutMetrics.interPartSpacing
    )

    NSLayoutConstraint.activate([
      icon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      icon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      leadingWidthConstraint!,
      icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
      textStackLeadingToIcon!,
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

    textStackLeadingToIcon?.isActive = false
    textStackLeadingToIcon = nil
    textStackLeadingToContainer?.isActive = true
  }

  @discardableResult
  private func ensureSubtitleLabel() -> UILabel {
    if let subtitleLabel { return subtitleLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: paymentMethodConfiguration.subtitleTextStyle)
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

  private func ensureSelectionImageView() {
    guard selectionImageView == nil else { return }

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = paymentMethodConfiguration.selectionTintColor
    imageView.image = UIImage(systemName: paymentMethodConfiguration.selectionSymbolName)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(imageView)
    selectionImageView = imageView

    selectionWidthConstraint = imageView.widthAnchor.constraint(
      equalToConstant: paymentMethodConfiguration.selectionSymbolSide
    )
    selectionConstraints = [
      imageView.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),
      imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      selectionWidthConstraint!,
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
    ]
    textStackTrailingToContainer?.isActive = false
    NSLayoutConstraint.activate(selectionConstraints)
  }

  private func releaseSelectionImageView() {
    guard let selectionImageView else { return }
    NSLayoutConstraint.deactivate(selectionConstraints)
    selectionConstraints = []
    selectionWidthConstraint = nil
    selectionImageView.removeFromSuperview()
    self.selectionImageView = nil
    textStackTrailingToContainer?.isActive = true
  }

  private func updateAccessibility(for item: FKPaymentMethodItem) {
    var components = [item.title]
    if let subtitle = item.subtitle, !subtitle.isEmpty {
      components.append(subtitle)
    }
    if item.isSelected {
      components.append("Selected")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
