import UIKit
import FKUIKit

/// System notification style list row with icon, summary, timestamp, and unread dot.
@MainActor
public final class FKNotificationListCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKNotificationListItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for notification lists.
  public static let preferredRowHeight: CGFloat = 68

  /// Row-specific configuration.
  public var notificationListConfiguration: FKNotificationListCellConfiguration = FKCellKitDefaults.notificationListCell {
    didSet { applyNotificationListConfiguration() }
  }

  private let leadingIcon = FKCellKitLeadingSymbolView()
  private let titleLabel = UILabel()
  private var summaryLabel: UILabel?
  private var timestampLabel: UILabel?
  private var unreadDot: UIView?
  private var unreadDotWidthConstraint: NSLayoutConstraint?
  private var unreadDotHeightConstraint: NSLayoutConstraint?
  private let textStack = UIStackView()
  private var trailingStack: UIStackView?
  private var trailingStackConstraints: [NSLayoutConstraint] = []
  private var leadingWidthConstraint: NSLayoutConstraint?
  private var textStackTrailingToContainer: NSLayoutConstraint?
  private var textStackTrailingSpacingConstraint: NSLayoutConstraint?

  /// Binds a notification list item to the row UI.
  public func configure(with item: FKNotificationListItem) {
    leadingIcon.symbolName = item.symbolName
    titleLabel.text = item.title

    if let summary = item.summary, !summary.isEmpty {
      ensureSummaryLabel().text = summary
    } else {
      releaseSummaryLabel()
    }

    if let timestamp = item.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    if item.isUnread {
      ensureUnreadDot()
    } else {
      releaseUnreadDot()
    }

    syncTrailingStackVisibility()
    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    leadingIcon.translatesAutoresizingMaskIntoConstraints = false
    textStack.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(leadingIcon)
    containerView.addSubview(textStack)

    leadingWidthConstraint = leadingIcon.widthAnchor.constraint(
      equalToConstant: notificationListConfiguration.leadingSymbolSide
    )
    leadingIcon.symbolSide = notificationListConfiguration.leadingSymbolSide
    textStackTrailingToContainer = textStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)

    NSLayoutConstraint.activate([
      leadingIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      leadingIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      leadingWidthConstraint!,
      leadingIcon.heightAnchor.constraint(equalTo: leadingIcon.widthAnchor),

      textStack.leadingAnchor.constraint(
        equalTo: leadingIcon.trailingAnchor,
        constant: FKCellKitLayoutMetrics.interPartSpacing
      ),
      textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      textStack.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
      textStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),

      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: containerView.heightAnchor),
      textStackTrailingToContainer!,
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyNotificationListConfiguration()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    if let unreadDot, unreadDot.bounds.width > 0 {
      unreadDot.layer.cornerRadius = unreadDot.bounds.width / 2
    }
  }

  public override func resetCellContent() {
    super.resetCellContent()
    leadingIcon.symbolName = nil
    leadingIcon.prepareForReuse()
    titleLabel.text = nil
    releaseSummaryLabel()
    releaseTimestampLabel()
    releaseUnreadDot()
    syncTrailingStackVisibility()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyNotificationListConfiguration()
  }

  private func applyNotificationListConfiguration() {
    cellConfiguration = notificationListConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: notificationListConfiguration.titleTextStyle)
    summaryLabel?.font = UIFont.preferredFont(forTextStyle: notificationListConfiguration.summaryTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: notificationListConfiguration.timestampTextStyle)
    leadingWidthConstraint?.constant = notificationListConfiguration.leadingSymbolSide
    leadingIcon.symbolSide = notificationListConfiguration.leadingSymbolSide
    let diameter = notificationListConfiguration.unreadDotDiameter
    unreadDotWidthConstraint?.constant = diameter
    unreadDotHeightConstraint?.constant = diameter
    unreadDot?.layer.cornerRadius = diameter / 2
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureSummaryLabel() -> UILabel {
    if let summaryLabel { return summaryLabel }

    let label = UILabel()
    label.numberOfLines = 2
    label.lineBreakMode = .byTruncatingTail
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: notificationListConfiguration.summaryTextStyle)
    summaryLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseSummaryLabel() {
    guard let summaryLabel else { return }
    summaryLabel.text = nil
    textStack.removeArrangedSubview(summaryLabel)
    summaryLabel.removeFromSuperview()
    self.summaryLabel = nil
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.textAlignment = .right
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: notificationListConfiguration.timestampTextStyle)
    timestampLabel = label
    ensureTrailingStack().insertArrangedSubview(label, at: 0)
    return label
  }

  private func releaseTimestampLabel() {
    guard let timestampLabel else { return }
    timestampLabel.text = nil
    trailingStack?.removeArrangedSubview(timestampLabel)
    timestampLabel.removeFromSuperview()
    self.timestampLabel = nil
    syncTrailingStackVisibility()
  }

  private func ensureUnreadDot() {
    guard unreadDot == nil else { return }

    let diameter = notificationListConfiguration.unreadDotDiameter
    let dot = UIView()
    dot.backgroundColor = .systemRed
    dot.layer.cornerRadius = diameter / 2
    dot.layer.masksToBounds = true
    dot.translatesAutoresizingMaskIntoConstraints = false
    dot.setContentHuggingPriority(.required, for: .horizontal)
    dot.setContentHuggingPriority(.required, for: .vertical)
    dot.setContentCompressionResistancePriority(.required, for: .horizontal)
    dot.setContentCompressionResistancePriority(.required, for: .vertical)
    ensureTrailingStack().addArrangedSubview(dot)
    unreadDot = dot

    unreadDotWidthConstraint = dot.widthAnchor.constraint(equalToConstant: diameter)
    unreadDotHeightConstraint = dot.heightAnchor.constraint(equalToConstant: diameter)
    NSLayoutConstraint.activate([
      unreadDotWidthConstraint!,
      unreadDotHeightConstraint!,
      dot.widthAnchor.constraint(equalTo: dot.heightAnchor),
    ])
    syncTrailingStackVisibility()
  }

  private func releaseUnreadDot() {
    guard let unreadDot else { return }
    NSLayoutConstraint.deactivate([unreadDotWidthConstraint, unreadDotHeightConstraint].compactMap { $0 })
    unreadDotWidthConstraint = nil
    unreadDotHeightConstraint = nil
    trailingStack?.removeArrangedSubview(unreadDot)
    unreadDot.removeFromSuperview()
    self.unreadDot = nil
    syncTrailingStackVisibility()
  }

  @discardableResult
  private func ensureTrailingStack() -> UIStackView {
    if let trailingStack { return trailingStack }

    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .trailing
    stack.distribution = .equalSpacing
    stack.spacing = FKCellKitLayoutMetrics.trailingStackSpacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(stack)
    trailingStack = stack

    textStackTrailingSpacingConstraint = textStack.trailingAnchor.constraint(
      lessThanOrEqualTo: stack.leadingAnchor,
      constant: -8
    )
    trailingStackConstraints = [
      stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
    ]
    NSLayoutConstraint.activate(trailingStackConstraints)
    textStackTrailingToContainer?.isActive = false
    textStackTrailingSpacingConstraint?.isActive = true
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

  private func syncTrailingStackVisibility() {
    if timestampLabel == nil && unreadDot == nil {
      releaseTrailingStack()
    }
  }

  private func updateAccessibility(for item: FKNotificationListItem) {
    var components = [item.title]
    if let summary = item.summary, !summary.isEmpty {
      components.append(summary)
    }
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if item.isUnread {
      components.append("Unread")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
