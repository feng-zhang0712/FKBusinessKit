import UIKit
import FKUIKit

/// Shipping address row with recipient details, formatted address, and default/selection trailing state.
@MainActor
public final class FKAddressListCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKAddressListItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for address lists.
  public static let preferredRowHeight: CGFloat = 96

  /// Row-specific configuration.
  public var addressListConfiguration: FKAddressListCellConfiguration = FKCellKitDefaults.addressListCell {
    didSet { applyAddressListConfiguration() }
  }

  private let leadingIcon = FKCellKitLeadingSymbolView()
  private let recipientLabel = UILabel()
  private let phoneLabel = UILabel()
  private let addressLabel = UILabel()
  private var defaultTag: FKTag?
  private var selectionImageView: UIImageView?
  private var selectionWidthConstraint: NSLayoutConstraint?
  private var selectionHeightConstraint: NSLayoutConstraint?
  private var textStackTrailingToContainer: NSLayoutConstraint?
  private var textStackTrailingSpacingConstraint: NSLayoutConstraint?
  private let namePhoneStack = UIStackView()
  private let textStack = UIStackView()
  private var trailingStack: UIStackView?
  private var trailingStackConstraints: [NSLayoutConstraint] = []
  private var leadingWidthConstraint: NSLayoutConstraint?

  /// Binds an address list item to the row UI.
  public func configure(with item: FKAddressListItem) {
    leadingIcon.symbolName = item.leadingSymbolName ?? addressListConfiguration.defaultLeadingSymbolName
    recipientLabel.text = item.recipientName
    phoneLabel.text = item.phone
    addressLabel.text = item.address

    if item.isDefault {
      let tag = ensureDefaultTag()
      tag.title = addressListConfiguration.defaultTagTitle
      tag.variant = addressListConfiguration.defaultTagVariant
    } else {
      releaseDefaultTag()
    }

    if item.isSelected {
      ensureSelectionImageView()
    } else {
      releaseSelectionImageView()
    }
    syncTrailingVisibility()
    updateAccessibility(for: item)
  }

  public override func setupUI() {
    recipientLabel.numberOfLines = 1
    recipientLabel.lineBreakMode = .byTruncatingTail

    phoneLabel.numberOfLines = 1
    phoneLabel.textColor = .secondaryLabel

    addressLabel.numberOfLines = 0
    addressLabel.lineBreakMode = .byWordWrapping
    addressLabel.textColor = .secondaryLabel

    namePhoneStack.axis = .horizontal
    namePhoneStack.alignment = .firstBaseline
    namePhoneStack.spacing = 8
    namePhoneStack.addArrangedSubview(recipientLabel)
    namePhoneStack.addArrangedSubview(phoneLabel)
    recipientLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    recipientLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    phoneLabel.setContentHuggingPriority(.required, for: .horizontal)
    phoneLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(namePhoneStack)
    textStack.addArrangedSubview(addressLabel)

    leadingIcon.translatesAutoresizingMaskIntoConstraints = false
    textStack.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(leadingIcon)
    containerView.addSubview(textStack)

    leadingWidthConstraint = leadingIcon.widthAnchor.constraint(
      equalToConstant: addressListConfiguration.leadingSymbolSide
    )
    leadingIcon.symbolSide = addressListConfiguration.leadingSymbolSide
    textStackTrailingToContainer = textStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

    NSLayoutConstraint.activate([
      leadingIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      leadingIcon.topAnchor.constraint(equalTo: containerView.topAnchor),
      leadingWidthConstraint!,
      leadingIcon.heightAnchor.constraint(equalTo: leadingIcon.widthAnchor),

      textStack.leadingAnchor.constraint(
        equalTo: leadingIcon.trailingAnchor,
        constant: FKCellKitLayoutMetrics.interPartSpacing
      ),
      textStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      textStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: containerView.heightAnchor),
      textStackTrailingToContainer!,
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyAddressListConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    leadingIcon.symbolName = nil
    leadingIcon.prepareForReuse()
    recipientLabel.text = nil
    phoneLabel.text = nil
    addressLabel.text = nil
    releaseDefaultTag()
    releaseSelectionImageView()
    syncTrailingVisibility()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyAddressListConfiguration()
  }

  private func applyAddressListConfiguration() {
    cellConfiguration = addressListConfiguration.table
    recipientLabel.font = UIFont.preferredFont(forTextStyle: addressListConfiguration.recipientTextStyle)
    phoneLabel.font = UIFont.preferredFont(forTextStyle: addressListConfiguration.phoneTextStyle)
    addressLabel.font = UIFont.preferredFont(forTextStyle: addressListConfiguration.addressTextStyle)
    leadingWidthConstraint?.constant = addressListConfiguration.leadingSymbolSide
    leadingIcon.symbolSide = addressListConfiguration.leadingSymbolSide
    selectionImageView?.tintColor = addressListConfiguration.selectionTintColor
    selectionImageView?.image = UIImage(systemName: addressListConfiguration.selectionSymbolName)
    applyCellConfiguration()
  }

  private func updateAccessibility(for item: FKAddressListItem) {
    var components = [item.recipientName, item.phone, item.address]
    if item.isDefault {
      components.append(addressListConfiguration.defaultTagTitle)
    }
    if item.isSelected {
      components.append("Selected")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }

  @discardableResult
  private func ensureDefaultTag() -> FKTag {
    if let defaultTag { return defaultTag }

    let tag = FKTag()
    defaultTag = tag
    ensureTrailingStack().insertArrangedSubview(tag, at: 0)
    return tag
  }

  private func releaseDefaultTag() {
    guard let defaultTag else { return }
    defaultTag.title = ""
    trailingStack?.removeArrangedSubview(defaultTag)
    defaultTag.removeFromSuperview()
    self.defaultTag = nil
    syncTrailingVisibility()
  }

  private func ensureSelectionImageView() {
    guard selectionImageView == nil else { return }

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = addressListConfiguration.selectionTintColor
    imageView.image = UIImage(systemName: addressListConfiguration.selectionSymbolName)
    selectionImageView = imageView
    ensureTrailingStack().addArrangedSubview(imageView)

    selectionWidthConstraint = imageView.widthAnchor.constraint(
      equalToConstant: addressListConfiguration.selectionSymbolSide
    )
    selectionHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
    NSLayoutConstraint.activate([selectionWidthConstraint!, selectionHeightConstraint!])
    syncTrailingVisibility()
  }

  private func releaseSelectionImageView() {
    guard let selectionImageView else { return }
    NSLayoutConstraint.deactivate([selectionWidthConstraint, selectionHeightConstraint].compactMap { $0 })
    selectionWidthConstraint = nil
    selectionHeightConstraint = nil
    trailingStack?.removeArrangedSubview(selectionImageView)
    selectionImageView.removeFromSuperview()
    self.selectionImageView = nil
    syncTrailingVisibility()
  }

  @discardableResult
  private func ensureTrailingStack() -> UIStackView {
    if let trailingStack { return trailingStack }

    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .trailing
    stack.spacing = FKCellKitLayoutMetrics.trailingStackSpacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(stack)
    trailingStack = stack

    textStackTrailingSpacingConstraint = stack.leadingAnchor.constraint(
      greaterThanOrEqualTo: textStack.trailingAnchor,
      constant: 8
    )
    trailingStackConstraints = [
      stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
    ]
    textStackTrailingToContainer?.isActive = false
    NSLayoutConstraint.activate(trailingStackConstraints + [textStackTrailingSpacingConstraint].compactMap { $0 })
    return stack
  }

  private func releaseTrailingStack() {
    guard let trailingStack else { return }
    NSLayoutConstraint.deactivate(trailingStackConstraints + [textStackTrailingSpacingConstraint].compactMap { $0 })
    trailingStackConstraints = []
    textStackTrailingSpacingConstraint = nil
    trailingStack.removeFromSuperview()
    self.trailingStack = nil
    textStackTrailingToContainer?.isActive = true
  }

  private func syncTrailingVisibility() {
    if defaultTag == nil && selectionImageView == nil {
      releaseTrailingStack()
    }
  }
}
