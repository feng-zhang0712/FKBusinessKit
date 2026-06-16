import UIKit
import FKUIKit

/// Read-only shopping cart line item with thumbnail, variant text, and price stack.
@MainActor
public final class FKCartLineItemCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKCartLineItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for cart line items.
  public static let preferredRowHeight: CGFloat = 88

  /// Row-specific configuration.
  public var cartLineItemConfiguration: FKCartLineItemCellConfiguration = FKCellKitDefaults.cartLineItemCell {
    didSet { applyCartLineItemConfiguration() }
  }

  private let coverImageView = FKImageView()
  private let titleLabel = UILabel()
  private var variantLabel: UILabel?
  private var quantityLabel: UILabel?
  private let priceLabel = UILabel()
  private var originalPriceLabel: UILabel?
  private let priceRowStack = UIStackView()
  private let textStack = UIStackView()
  private let trailingStack = UIStackView()
  private let rowStack = UIStackView()

  /// Binds a cart line item to the row UI.
  public func configure(with item: FKCartLineItem) {
    coverImageView.load(url: item.imageURL)
    titleLabel.text = item.title

    if let variant = item.variantText, !variant.isEmpty {
      ensureVariantLabel().text = variant
    } else {
      releaseVariantLabel()
    }

    applyPrice(
      priceText: item.priceText,
      originalPriceText: item.originalPriceText
    )

    if let quantity = item.quantityText, !quantity.isEmpty {
      ensureQuantityLabel().text = quantity
    } else {
      releaseQuantityLabel()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    coverImageView.clipsToBounds = true
    coverImageView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    priceLabel.textColor = .label
    priceLabel.numberOfLines = 1

    priceRowStack.axis = .horizontal
    priceRowStack.alignment = .firstBaseline
    priceRowStack.spacing = 6
    priceRowStack.addArrangedSubview(priceLabel)

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    trailingStack.axis = .vertical
    trailingStack.alignment = .trailing
    trailingStack.spacing = 4
    trailingStack.addArrangedSubview(priceRowStack)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(coverImageView)
    rowStack.addArrangedSubview(textStack)
    rowStack.addArrangedSubview(trailingStack)

    containerView.addSubview(rowStack)

    NSLayoutConstraint.activate([
      coverImageView.widthAnchor.constraint(equalToConstant: cartLineItemConfiguration.thumbnailSide),
      coverImageView.heightAnchor.constraint(equalToConstant: cartLineItemConfiguration.thumbnailSide),
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      containerView.heightAnchor.constraint(equalToConstant: Self.preferredRowHeight),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyCartLineItemConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    coverImageView.cancelLoad()
    titleLabel.text = nil
    releaseVariantLabel()
    releaseQuantityLabel()
    priceLabel.text = nil
    releaseOriginalPriceLabel()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyCartLineItemConfiguration()
  }

  private func applyCartLineItemConfiguration() {
    cellConfiguration = cartLineItemConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: cartLineItemConfiguration.titleTextStyle)
    variantLabel?.font = UIFont.preferredFont(forTextStyle: cartLineItemConfiguration.variantTextStyle)
    quantityLabel?.font = UIFont.preferredFont(forTextStyle: cartLineItemConfiguration.quantityTextStyle)
    coverImageView.layer.cornerRadius = cartLineItemConfiguration.thumbnailCornerRadius
    applyCellConfiguration()
  }

  private func applyPrice(priceText: String, originalPriceText: String?) {
    priceLabel.text = priceText
    priceLabel.font = UIFont.preferredFont(forTextStyle: cartLineItemConfiguration.priceTextStyle)

    if let originalPriceText, !originalPriceText.isEmpty {
      let label = ensureOriginalPriceLabel()
      label.font = UIFont.preferredFont(forTextStyle: cartLineItemConfiguration.originalPriceTextStyle)
      let attributes: [NSAttributedString.Key: Any] = [
        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
        .foregroundColor: UIColor.secondaryLabel,
      ]
      label.attributedText = NSAttributedString(string: originalPriceText, attributes: attributes)
    } else {
      releaseOriginalPriceLabel()
    }
  }

  @discardableResult
  private func ensureOriginalPriceLabel() -> UILabel {
    if let originalPriceLabel { return originalPriceLabel }

    let label = UILabel()
    label.numberOfLines = 1
    originalPriceLabel = label
    priceRowStack.addArrangedSubview(label)
    return label
  }

  private func releaseOriginalPriceLabel() {
    guard let originalPriceLabel else { return }
    originalPriceLabel.text = nil
    originalPriceLabel.attributedText = nil
    priceRowStack.removeArrangedSubview(originalPriceLabel)
    originalPriceLabel.removeFromSuperview()
    self.originalPriceLabel = nil
  }

  @discardableResult
  private func ensureVariantLabel() -> UILabel {
    if let variantLabel { return variantLabel }
    let label = UILabel()
    label.textColor = .secondaryLabel
    label.numberOfLines = 1
    variantLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseVariantLabel() {
    guard let variantLabel else { return }
    variantLabel.text = nil
    textStack.removeArrangedSubview(variantLabel)
    variantLabel.removeFromSuperview()
    self.variantLabel = nil
  }

  @discardableResult
  private func ensureQuantityLabel() -> UILabel {
    if let quantityLabel { return quantityLabel }
    let label = UILabel()
    label.textColor = .secondaryLabel
    quantityLabel = label
    trailingStack.insertArrangedSubview(label, at: 0)
    return label
  }

  private func releaseQuantityLabel() {
    guard let quantityLabel else { return }
    quantityLabel.text = nil
    trailingStack.removeArrangedSubview(quantityLabel)
    quantityLabel.removeFromSuperview()
    self.quantityLabel = nil
  }

  private func updateAccessibility(for item: FKCartLineItem) {
    var components = [item.title, item.priceText]
    if let variant = item.variantText { components.insert(variant, at: 1) }
    if let quantity = item.quantityText { components.append(quantity) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKCartLineItemCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    coverImageView.cancelLoad()
  }
}
