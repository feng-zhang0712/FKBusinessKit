import UIKit
import FKUIKit

/// Single timeline event row with connector column for logistics and audit feeds.
@MainActor
public final class FKTimelineEventCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKTimelineEventItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended minimum row height for timeline events.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var timelineEventConfiguration: FKTimelineEventCellConfiguration = FKCellKitDefaults.timelineEventCell {
    didSet { applyTimelineEventConfiguration() }
  }

  private let connectorView = FKTimelineConnectorView()
  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private var captionLabel: UILabel?
  private var timestampLabel: UILabel?
  private let textStack = UIStackView()
  private let rowStack = UIStackView()

  /// Binds a timeline event item to the row UI.
  public func configure(with item: FKTimelineEventItem) {
    let step = item.step
    titleLabel.text = step.title

    if let subtitle = step.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    if let caption = step.caption, !caption.isEmpty {
      ensureCaptionLabel().text = caption
    } else {
      releaseCaptionLabel()
    }

    let timestamp = step.formattedTimestamp ?? formattedTimestamp(from: step.timestamp)
    if let timestamp, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    let showsTop = item.connectorPosition != .first && item.connectorPosition != .only
    let showsBottom = item.connectorPosition != .last && item.connectorPosition != .only
    connectorView.apply(
      state: step.state,
      stepIndex: item.stepIndex,
      showsTopConnector: showsTop,
      showsBottomConnector: showsBottom,
      topConnectorCompleted: item.topConnectorCompleted,
      bottomConnectorCompleted: item.bottomConnectorCompleted
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

    rowStack.axis = .horizontal
    rowStack.alignment = .top
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    rowStack.clipsToBounds = false
    rowStack.addArrangedSubview(connectorView)
    rowStack.addArrangedSubview(textStack)

    containerView.addSubview(rowStack)

    NSLayoutConstraint.activate([
      connectorView.widthAnchor.constraint(equalToConstant: timelineEventConfiguration.connectorColumnWidth),
      connectorView.topAnchor.constraint(equalTo: rowStack.topAnchor),
      connectorView.bottomAnchor.constraint(equalTo: rowStack.bottomAnchor),
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: rowStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyTimelineEventConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    titleLabel.text = nil
    releaseSubtitleLabel()
    releaseCaptionLabel()
    releaseTimestampLabel()
    connectorView.prepareForReuse()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyTimelineEventConfiguration()
  }

  private func applyTimelineEventConfiguration() {
    cellConfiguration = timelineEventConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.subtitleTextStyle)
    captionLabel?.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.captionTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.timestampTextStyle)
    timestampLabel?.textColor = .tertiaryLabel
    connectorView.configuration = timelineEventConfiguration.connector
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureSubtitleLabel() -> UILabel {
    if let subtitleLabel { return subtitleLabel }
    let label = UILabel()
    label.numberOfLines = 2
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.subtitleTextStyle)
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

  @discardableResult
  private func ensureCaptionLabel() -> UILabel {
    if let captionLabel { return captionLabel }
    let label = UILabel()
    label.numberOfLines = 0
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.captionTextStyle)
    captionLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseCaptionLabel() {
    guard let captionLabel else { return }
    captionLabel.text = nil
    textStack.removeArrangedSubview(captionLabel)
    captionLabel.removeFromSuperview()
    self.captionLabel = nil
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }
    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .tertiaryLabel
    label.font = UIFont.preferredFont(forTextStyle: timelineEventConfiguration.timestampTextStyle)
    timestampLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseTimestampLabel() {
    guard let timestampLabel else { return }
    timestampLabel.text = nil
    textStack.removeArrangedSubview(timestampLabel)
    timestampLabel.removeFromSuperview()
    self.timestampLabel = nil
  }

  private func formattedTimestamp(from date: Date?) -> String? {
    guard let date else { return nil }
    return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
  }

  private func updateAccessibility(for item: FKTimelineEventItem) {
    var components = [item.step.title]
    if let subtitle = item.step.subtitle, !subtitle.isEmpty { components.append(subtitle) }
    if let caption = item.step.caption, !caption.isEmpty { components.append(caption) }
    if let timestamp = item.step.formattedTimestamp { components.append(timestamp) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
