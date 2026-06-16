import UIKit
import FKUIKit

/// Search result row with optional query-hit emphasis and category tag.
@MainActor
public final class FKSearchResultCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKSearchResultItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for search results.
  public static let preferredRowHeight: CGFloat = 56

  /// Row-specific configuration.
  public var searchResultConfiguration: FKSearchResultCellConfiguration = FKCellKitDefaults.searchResultCell {
    didSet { applySearchResultConfiguration() }
  }

  private let titleLabel = UILabel()
  private var breadcrumbLabel: UILabel?
  private var categoryTag: FKTag?
  private let textStack = UIStackView()
  private let rowStack = UIStackView()
  private var boundTitleSegments: [FKSearchHighlightSegment]?

  /// Binds a search result item to the row UI.
  public func configure(with item: FKSearchResultItem) {
    boundTitleSegments = item.titleSegments
    refreshTitleLabel()

    if let breadcrumb = item.breadcrumbText, !breadcrumb.isEmpty {
      ensureBreadcrumbLabel().text = breadcrumb
    } else {
      releaseBreadcrumbLabel()
    }

    if let tagTitle = item.categoryTagTitle, !tagTitle.isEmpty {
      let tag = ensureCategoryTag()
      tag.title = tagTitle
      tag.variant = searchResultConfiguration.categoryTagVariant
    } else {
      releaseCategoryTag()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(textStack)

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
    applySearchResultConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    boundTitleSegments = nil
    titleLabel.attributedText = nil
    releaseBreadcrumbLabel()
    releaseCategoryTag()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applySearchResultConfiguration()
  }

  private func applySearchResultConfiguration() {
    cellConfiguration = searchResultConfiguration.table
    breadcrumbLabel?.font = UIFont.preferredFont(forTextStyle: searchResultConfiguration.breadcrumbTextStyle)
    refreshTitleLabel()
    applyCellConfiguration()
  }

  private func refreshTitleLabel() {
    guard let boundTitleSegments else {
      titleLabel.attributedText = nil
      return
    }
    titleLabel.attributedText = attributedTitle(from: boundTitleSegments)
  }

  private func attributedTitle(from segments: [FKSearchHighlightSegment]) -> NSAttributedString {
    let result = NSMutableAttributedString()
    let baseFont = UIFont.preferredFont(forTextStyle: searchResultConfiguration.titleTextStyle)
    let highlightFont: UIFont = {
      guard let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) else {
        return baseFont
      }
      return UIFont(descriptor: descriptor, size: baseFont.pointSize)
    }()
    for segment in segments {
      let color: UIColor = segment.isHighlighted
        ? searchResultConfiguration.highlightColor
        : .label
      let attributes: [NSAttributedString.Key: Any] = [
        .font: segment.isHighlighted ? highlightFont : baseFont,
        .foregroundColor: color,
      ]
      result.append(NSAttributedString(string: segment.text, attributes: attributes))
    }
    return result
  }

  @discardableResult
  private func ensureBreadcrumbLabel() -> UILabel {
    if let breadcrumbLabel { return breadcrumbLabel }
    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: searchResultConfiguration.breadcrumbTextStyle)
    breadcrumbLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseBreadcrumbLabel() {
    guard let breadcrumbLabel else { return }
    breadcrumbLabel.text = nil
    textStack.removeArrangedSubview(breadcrumbLabel)
    breadcrumbLabel.removeFromSuperview()
    self.breadcrumbLabel = nil
  }

  @discardableResult
  private func ensureCategoryTag() -> FKTag {
    if let categoryTag { return categoryTag }

    let tag = FKTag()
    tag.setContentHuggingPriority(.required, for: .horizontal)
    tag.setContentCompressionResistancePriority(.required, for: .horizontal)
    categoryTag = tag
    rowStack.addArrangedSubview(tag)
    return tag
  }

  private func releaseCategoryTag() {
    guard let categoryTag else { return }
    categoryTag.title = ""
    rowStack.removeArrangedSubview(categoryTag)
    categoryTag.removeFromSuperview()
    self.categoryTag = nil
  }

  private func updateAccessibility(for item: FKSearchResultItem) {
    var components = [item.titleSegments.map(\.text).joined()]
    if let breadcrumb = item.breadcrumbText, !breadcrumb.isEmpty { components.append(breadcrumb) }
    if let tag = item.categoryTagTitle, !tag.isEmpty { components.append(tag) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
