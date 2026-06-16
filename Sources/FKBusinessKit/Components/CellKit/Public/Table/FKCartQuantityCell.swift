import UIKit
import FKUIKit

/// Shopping cart row with thumbnail, price, and embedded quantity stepper.
@MainActor
public final class FKCartQuantityCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKCartQuantityItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for cart quantity rows.
  public static let preferredRowHeight: CGFloat = 88

  /// Row-specific configuration.
  public var cartQuantityConfiguration: FKCartQuantityCellConfiguration = FKCellKitDefaults.cartQuantityCell {
    didSet { applyCartQuantityConfiguration() }
  }

  private let coverImageView = FKImageView()
  private let titleLabel = UILabel()
  private var variantLabel: UILabel?
  private let priceLabel = UILabel()
  private let stepperView = FKQuantityStepperView()
  private let textStack = UIStackView()
  private let trailingStack = UIStackView()
  private let rowStack = UIStackView()
  private var boundItemID: String?
  private var boundHandlerID: String?

  /// Binds a cart quantity item to the row UI.
  public func configure(with item: FKCartQuantityItem) {
    boundItemID = item.id
    boundHandlerID = item.quantityHandlerID

    coverImageView.load(url: item.imageURL)
    titleLabel.text = item.title

    if let variant = item.variantText, !variant.isEmpty {
      ensureVariantLabel().text = variant
    } else {
      releaseVariantLabel()
    }

    priceLabel.text = item.priceText
    stepperView.apply(value: item.quantity, minValue: item.minQuantity, maxValue: item.maxQuantity)
    stepperView.onValueChanged = { [weak self] value in
      self?.forwardQuantityChange(value)
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    coverImageView.clipsToBounds = true
    coverImageView.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    priceLabel.textColor = .label
    priceLabel.numberOfLines = 1

    trailingStack.axis = .vertical
    trailingStack.alignment = .trailing
    trailingStack.spacing = 4
    trailingStack.addArrangedSubview(priceLabel)
    trailingStack.addArrangedSubview(stepperView)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(coverImageView)
    rowStack.addArrangedSubview(textStack)
    rowStack.addArrangedSubview(trailingStack)

    containerView.addSubview(rowStack)

    NSLayoutConstraint.activate([
      coverImageView.widthAnchor.constraint(equalToConstant: cartQuantityConfiguration.thumbnailSide),
      coverImageView.heightAnchor.constraint(equalToConstant: cartQuantityConfiguration.thumbnailSide),
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      containerView.heightAnchor.constraint(equalToConstant: Self.preferredRowHeight),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyCartQuantityConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    coverImageView.cancelLoad()
    titleLabel.text = nil
    releaseVariantLabel()
    priceLabel.text = nil
    stepperView.prepareForReuse()
    boundItemID = nil
    boundHandlerID = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyCartQuantityConfiguration()
  }

  private func applyCartQuantityConfiguration() {
    cellConfiguration = cartQuantityConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: cartQuantityConfiguration.titleTextStyle)
    variantLabel?.font = UIFont.preferredFont(forTextStyle: cartQuantityConfiguration.variantTextStyle)
    priceLabel.font = UIFont.preferredFont(forTextStyle: cartQuantityConfiguration.priceTextStyle)
    coverImageView.layer.cornerRadius = cartQuantityConfiguration.thumbnailCornerRadius
    applyCellConfiguration()
  }

  private func forwardQuantityChange(_ value: Int) {
    guard let boundItemID, let boundHandlerID,
          let controller = FKCellKitResponderLookup.diffableTableController(from: self),
          let handler = controller.cellKitValueHandlers.quantityHandler(for: boundHandlerID) else {
      return
    }
    handler(FKListItemID(boundItemID), value)
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

  private func updateAccessibility(for item: FKCartQuantityItem) {
    var components = [item.title, item.priceText, "Quantity \(item.quantity)"]
    if let variant = item.variantText { components.insert(variant, at: 1) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKCartQuantityCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    coverImageView.cancelLoad()
  }
}
