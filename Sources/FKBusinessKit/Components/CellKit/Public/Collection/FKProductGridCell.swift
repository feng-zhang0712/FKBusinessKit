import UIKit
import FKUIKit

/// Product grid collection cell with remote image, title, price, and optional tags.
@MainActor
public final class FKProductGridCell: FKCellKitCollectionCell, FKListCollectionCellConfigurable {
  public typealias Item = FKProductListItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended collection item size for two-column grids.
  public static var preferredItemSize: CGSize { FKProductGridCellConfiguration.defaultItemSize }

  /// Item-specific configuration.
  public var productGridConfiguration: FKProductGridCellConfiguration = FKCellKitDefaults.productGridCell {
    didSet { applyProductGridConfiguration() }
  }

  private let coverImageView = FKImageView()
  private let titleLabel = UILabel()
  private let priceLabel = UILabel()
  private let tagRow = FKTagRowView()
  private let contentStack = UIStackView()
  private var imageHeightConstraint: NSLayoutConstraint?

  /// Binds a product list item to the grid cell UI.
  public func configure(with item: FKProductListItem) {
    coverImageView.load(url: item.imageURL)
    titleLabel.text = item.title
    priceLabel.text = item.priceText
    syncTagRow(with: item.tags)
    updateAccessibility(for: item)
  }

  public override func setupUI() {
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    coverImageView.clipsToBounds = true

    titleLabel.numberOfLines = productGridConfiguration.titleNumberOfLines
    titleLabel.lineBreakMode = .byTruncatingTail
    priceLabel.numberOfLines = 1

    contentStack.axis = .vertical
    contentStack.alignment = .fill
    contentStack.spacing = productGridConfiguration.verticalSpacing
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(coverImageView)
    contentStack.addArrangedSubview(titleLabel)
    contentStack.addArrangedSubview(priceLabel)

    containerView.addSubview(contentStack)

    imageHeightConstraint = coverImageView.heightAnchor.constraint(equalTo: coverImageView.widthAnchor)

    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      imageHeightConstraint!,
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyProductGridConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    coverImageView.resetForReuse()
    titleLabel.text = nil
    priceLabel.text = nil
    releaseTagRow()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyProductGridConfiguration()
  }

  private func applyProductGridConfiguration() {
    containerInsets = productGridConfiguration.contentInsets
    cornerRadius = productGridConfiguration.cornerRadius
    containerBackgroundColor = .secondarySystemBackground
    coverImageView.layer.cornerRadius = productGridConfiguration.imageCornerRadius
    titleLabel.font = UIFont.preferredFont(forTextStyle: productGridConfiguration.titleTextStyle)
    priceLabel.font = UIFont.preferredFont(forTextStyle: productGridConfiguration.priceTextStyle)
    titleLabel.numberOfLines = productGridConfiguration.titleNumberOfLines
    contentStack.spacing = productGridConfiguration.verticalSpacing
    tagRow.spacing = productGridConfiguration.tagSpacing
    applyCellConfiguration()
  }

  private func syncTagRow(with tags: [FKTagDisplayModel]) {
    if tags.isEmpty {
      releaseTagRow()
    } else {
      if tagRow.superview == nil {
        contentStack.addArrangedSubview(tagRow)
      }
      tagRow.apply(tags)
    }
  }

  private func releaseTagRow() {
    tagRow.prepareForReuse()
    guard tagRow.superview != nil else { return }
    contentStack.removeArrangedSubview(tagRow)
    tagRow.removeFromSuperview()
  }

  private func updateAccessibility(for item: FKProductListItem) {
    var components = [item.title, item.priceText]
    if !item.tags.isEmpty {
      components.append(item.tags.map(\.title).joined(separator: ", "))
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKProductGridCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    coverImageView.resetForReuse()
  }
}
