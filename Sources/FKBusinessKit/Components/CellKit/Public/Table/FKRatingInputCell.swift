import UIKit
import FKUIKit

/// Row with title and interactive ``FKRatingControl`` for review submission flows.
@MainActor
public final class FKRatingInputCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKRatingInputItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for rating input rows.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var ratingInputConfiguration: FKRatingInputCellConfiguration = FKCellKitDefaults.ratingInputCell {
    didSet { applyRatingInputConfiguration() }
  }

  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private let ratingControl = FKRatingControl.interactiveStars()
  private let textStack = UIStackView()
  private let rowStack = UIStackView()
  private var boundItemID: String?
  private var boundHandlerID: String?
  private var isApplyingRating = false

  /// Binds a rating input item to the row UI.
  public func configure(with item: FKRatingInputItem) {
    boundItemID = item.id
    boundHandlerID = item.ratingHandlerID
    titleLabel.text = item.title

    if let subtitle = item.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    isApplyingRating = true
    ratingControl.maximumValue = item.maxRating
    ratingControl.setValue(item.rating, animated: false, sendsControlEvents: false)
    isApplyingRating = false

    ratingControl.onValueChanged = { [weak self] value in
      self?.forwardRatingChange(value)
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 1

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(textStack)
    rowStack.addArrangedSubview(ratingControl)

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
    applyRatingInputConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    titleLabel.text = nil
    releaseSubtitleLabel()
    isApplyingRating = true
    ratingControl.setValue(0, animated: false, sendsControlEvents: false)
    isApplyingRating = false
    ratingControl.onValueChanged = nil
    boundItemID = nil
    boundHandlerID = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyRatingInputConfiguration()
  }

  private func applyRatingInputConfiguration() {
    cellConfiguration = ratingInputConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: ratingInputConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: ratingInputConfiguration.subtitleTextStyle)
    applyCellConfiguration()
  }

  private func forwardRatingChange(_ value: Double) {
    guard !isApplyingRating,
          let boundItemID,
          let boundHandlerID,
          let controller = FKCellKitResponderLookup.diffableTableController(from: self),
          let handler = controller.cellKitValueHandlers.ratingHandler(for: boundHandlerID) else {
      return
    }
    handler(FKListItemID(boundItemID), value)
    updateAccessibilityValue(rating: value, maxRating: ratingControl.maximumValue)
  }

  private func updateAccessibilityValue(rating: Double, maxRating: Double) {
    var components = [titleLabel.text ?? "", "\(rating) of \(maxRating) stars"]
    if let subtitle = subtitleLabel?.text, !subtitle.isEmpty { components.insert(subtitle, at: 1) }
    accessibilityLabel = components.joined(separator: ", ")
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

  private func updateAccessibility(for item: FKRatingInputItem) {
    var components = [item.title, "\(item.rating) of \(item.maxRating) stars"]
    if let subtitle = item.subtitle, !subtitle.isEmpty { components.insert(subtitle, at: 1) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
