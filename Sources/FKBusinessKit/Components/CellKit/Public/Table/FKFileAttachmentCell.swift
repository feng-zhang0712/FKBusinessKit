import UIKit
import FKUIKit

/// File attachment row with icon, metadata, and optional status pill.
@MainActor
public final class FKFileAttachmentCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKFileAttachmentItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for attachment rows.
  public static let preferredRowHeight: CGFloat = 64

  /// Row-specific configuration.
  public var fileAttachmentConfiguration: FKFileAttachmentCellConfiguration = FKCellKitDefaults.fileAttachmentCell {
    didSet { applyFileAttachmentConfiguration() }
  }

  private let leadingIcon = FKCellKitLeadingSymbolView()
  private let fileNameLabel = UILabel()
  private var fileSizeLabel: UILabel?
  private var statusPill: FKStatusPill?
  private let textStack = UIStackView()
  private let rowStack = UIStackView()
  private var leadingWidthConstraint: NSLayoutConstraint?

  /// Binds a file attachment item to the row UI.
  public func configure(with item: FKFileAttachmentItem) {
    leadingIcon.symbolName = item.symbolName ?? fileAttachmentConfiguration.defaultSymbolName
    fileNameLabel.text = item.fileName

    if let sizeText = item.fileSizeText, !sizeText.isEmpty {
      ensureFileSizeLabel().text = sizeText
    } else {
      releaseFileSizeLabel()
    }

    if let pill = item.statusPill {
      let view = ensureStatusPill()
      view.title = pill.title
      view.style = pill.style
      view.showsDot = pill.showsDot
    } else if let pill = defaultStatusPill(for: item.state) {
      let view = ensureStatusPill()
      view.title = pill.title
      view.style = pill.style
      view.showsDot = pill.showsDot
    } else {
      releaseStatusPill()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    fileNameLabel.numberOfLines = 1
    fileNameLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(fileNameLabel)

    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.addArrangedSubview(leadingIcon)
    rowStack.addArrangedSubview(textStack)

    containerView.addSubview(rowStack)

    leadingWidthConstraint = leadingIcon.widthAnchor.constraint(
      equalToConstant: fileAttachmentConfiguration.leadingSymbolSide
    )
    leadingIcon.symbolSide = fileAttachmentConfiguration.leadingSymbolSide

    NSLayoutConstraint.activate([
      leadingWidthConstraint!,
      leadingIcon.heightAnchor.constraint(equalTo: leadingIcon.widthAnchor),
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: rowStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyFileAttachmentConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    fileNameLabel.text = nil
    releaseFileSizeLabel()
    releaseStatusPill()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyFileAttachmentConfiguration()
  }

  private func applyFileAttachmentConfiguration() {
    cellConfiguration = fileAttachmentConfiguration.table
    fileNameLabel.font = UIFont.preferredFont(forTextStyle: fileAttachmentConfiguration.titleTextStyle)
    fileSizeLabel?.font = UIFont.preferredFont(forTextStyle: fileAttachmentConfiguration.subtitleTextStyle)
    leadingWidthConstraint?.constant = fileAttachmentConfiguration.leadingSymbolSide
    leadingIcon.symbolSide = fileAttachmentConfiguration.leadingSymbolSide
    applyCellConfiguration()
  }

  private func defaultStatusPill(for state: FKFileAttachmentState) -> FKStatusPillDisplayModel? {
    switch state {
    case .idle:
      return nil
    case .downloading:
      return FKStatusPillDisplayModel(title: "Downloading", style: .info, showsDot: true)
    case .uploaded:
      return FKStatusPillDisplayModel(title: "Ready", style: .success, showsDot: false)
    case .failed:
      return FKStatusPillDisplayModel(title: "Failed", style: .error, showsDot: false)
    }
  }

  @discardableResult
  private func ensureFileSizeLabel() -> UILabel {
    if let fileSizeLabel { return fileSizeLabel }
    let label = UILabel()
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: fileAttachmentConfiguration.subtitleTextStyle)
    fileSizeLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseFileSizeLabel() {
    guard let fileSizeLabel else { return }
    fileSizeLabel.text = nil
    textStack.removeArrangedSubview(fileSizeLabel)
    fileSizeLabel.removeFromSuperview()
    self.fileSizeLabel = nil
  }

  @discardableResult
  private func ensureStatusPill() -> FKStatusPill {
    if let statusPill { return statusPill }
    let pill = FKStatusPill()
    pill.setContentHuggingPriority(.required, for: .horizontal)
    statusPill = pill
    rowStack.addArrangedSubview(pill)
    return pill
  }

  private func releaseStatusPill() {
    guard let statusPill else { return }
    statusPill.title = ""
    statusPill.showsDot = false
    rowStack.removeArrangedSubview(statusPill)
    statusPill.removeFromSuperview()
    self.statusPill = nil
  }

  private func updateAccessibility(for item: FKFileAttachmentItem) {
    var components = [item.fileName]
    if let size = item.fileSizeText { components.append(size) }
    if let pill = item.statusPill?.title { components.append(pill) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
