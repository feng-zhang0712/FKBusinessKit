import UIKit
import FKUIKit

/// Indented comment thread row with avatar, author, body, and optional reply summary.
@MainActor
public final class FKCommentThreadCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKCommentThreadItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Fallback estimated height before ``FKCommentThreadCellHeightEstimator`` warms the cache.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var commentThreadConfiguration: FKCommentThreadCellConfiguration = FKCellKitDefaults.commentThreadCell {
    didSet { applyCommentThreadConfiguration() }
  }

  private var threadLine: UIView?
  private var threadLineConstraints: [NSLayoutConstraint] = []
  private var threadLineTrailingConstraint: NSLayoutConstraint?
  private let avatar = FKAvatar()
  private let authorLabel = UILabel()
  private var timestampLabel: UILabel?
  private var bodyLabel: UILabel?
  private var replySummaryLabel: UILabel?
  private let headerStack = UIStackView()
  private let textStack = UIStackView()
  private let contentRow = UIStackView()
  private var contentRowLeadingConstraint: NSLayoutConstraint?
  private var currentIndent: CGFloat = 0

  /// Binds a comment thread item to the row UI.
  public func configure(with item: FKCommentThreadItem) {
    let cappedDepth = min(max(0, item.depth), commentThreadConfiguration.maxDepth)
    let indent = CGFloat(cappedDepth) * commentThreadConfiguration.indentWidth
    currentIndent = indent
    contentRowLeadingConstraint?.constant = indent
    if cappedDepth == 0 {
      releaseThreadLine()
    } else {
      ensureThreadLine()
      threadLineTrailingConstraint?.constant = indent - 4
    }

    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: commentThreadConfiguration.avatarSize,
      isVerified: item.isVerified
    )

    authorLabel.text = item.authorName

    if let timestamp = item.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    if item.body.isEmpty {
      releaseBodyLabel()
    } else {
      ensureBodyLabel().text = item.body
    }

    if let replySummary = item.replySummaryText, !replySummary.isEmpty {
      ensureReplySummaryLabel().text = replySummary
    } else {
      releaseReplySummaryLabel()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    selectionStyle = .none

    avatar.translatesAutoresizingMaskIntoConstraints = false

    authorLabel.numberOfLines = 1
    authorLabel.lineBreakMode = .byTruncatingTail

    headerStack.axis = .horizontal
    headerStack.alignment = .firstBaseline
    headerStack.spacing = 8
    headerStack.addArrangedSubview(authorLabel)

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = commentThreadConfiguration.sectionSpacing
    textStack.addArrangedSubview(headerStack)

    contentRow.axis = .horizontal
    contentRow.alignment = .top
    contentRow.spacing = FKCellKitLayoutMetrics.interPartSpacing
    contentRow.translatesAutoresizingMaskIntoConstraints = false
    contentRow.addArrangedSubview(avatar)
    contentRow.addArrangedSubview(textStack)

    containerView.addSubview(contentRow)

    contentRowLeadingConstraint = contentRow.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)

    NSLayoutConstraint.activate([
      contentRowLeadingConstraint!,

      avatar.widthAnchor.constraint(equalToConstant: commentThreadConfiguration.avatarSize.diameter),
      avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

      contentRow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentRow.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentRow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: containerView.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyCommentThreadConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    avatar.resetForReuse()
    authorLabel.text = nil
    releaseTimestampLabel()
    releaseBodyLabel()
    releaseReplySummaryLabel()
    releaseThreadLine()
    currentIndent = 0
    contentRowLeadingConstraint?.constant = 0
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyCommentThreadConfiguration()
  }

  private func applyCommentThreadConfiguration() {
    cellConfiguration = commentThreadConfiguration.table
    textStack.spacing = commentThreadConfiguration.sectionSpacing
    authorLabel.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.authorTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.timestampTextStyle)
    bodyLabel?.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.bodyTextStyle)
    bodyLabel?.numberOfLines = commentThreadConfiguration.bodyMaxLines ?? 0
    replySummaryLabel?.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.replySummaryTextStyle)
    threadLine?.backgroundColor = commentThreadConfiguration.threadLineColor
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureThreadLine() -> UIView {
    if let threadLine { return threadLine }

    let line = UIView()
    line.backgroundColor = commentThreadConfiguration.threadLineColor
    line.translatesAutoresizingMaskIntoConstraints = false
    containerView.insertSubview(line, belowSubview: contentRow)
    threadLine = line

    threadLineTrailingConstraint = line.trailingAnchor.constraint(
      equalTo: containerView.leadingAnchor,
      constant: currentIndent - 4
    )
    threadLineConstraints = [
      line.widthAnchor.constraint(equalToConstant: 2),
      line.topAnchor.constraint(equalTo: containerView.topAnchor),
      line.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      threadLineTrailingConstraint!,
    ]
    NSLayoutConstraint.activate(threadLineConstraints)
    return line
  }

  private func releaseThreadLine() {
    guard let threadLine else { return }
    NSLayoutConstraint.deactivate(threadLineConstraints)
    threadLineConstraints = []
    threadLineTrailingConstraint = nil
    threadLine.removeFromSuperview()
    self.threadLine = nil
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .right
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.timestampTextStyle)
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentCompressionResistancePriority(.required, for: .horizontal)
    timestampLabel = label
    headerStack.addArrangedSubview(label)
    return label
  }

  private func releaseTimestampLabel() {
    guard let timestampLabel else { return }
    timestampLabel.text = nil
    headerStack.removeArrangedSubview(timestampLabel)
    timestampLabel.removeFromSuperview()
    self.timestampLabel = nil
  }

  @discardableResult
  private func ensureBodyLabel() -> UILabel {
    if let bodyLabel { return bodyLabel }

    let label = UILabel()
    label.numberOfLines = commentThreadConfiguration.bodyMaxLines ?? 0
    label.lineBreakMode = .byWordWrapping
    label.textColor = .label
    label.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.bodyTextStyle)
    bodyLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseBodyLabel() {
    guard let bodyLabel else { return }
    bodyLabel.text = nil
    textStack.removeArrangedSubview(bodyLabel)
    bodyLabel.removeFromSuperview()
    self.bodyLabel = nil
  }

  @discardableResult
  private func ensureReplySummaryLabel() -> UILabel {
    if let replySummaryLabel { return replySummaryLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: commentThreadConfiguration.replySummaryTextStyle)
    replySummaryLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseReplySummaryLabel() {
    guard let replySummaryLabel else { return }
    replySummaryLabel.text = nil
    textStack.removeArrangedSubview(replySummaryLabel)
    replySummaryLabel.removeFromSuperview()
    self.replySummaryLabel = nil
  }

  private func updateAccessibility(for item: FKCommentThreadItem) {
    var components = [item.authorName]
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if !item.body.isEmpty {
      components.append(item.body)
    }
    if let replySummary = item.replySummaryText, !replySummary.isEmpty {
      components.append(replySummary)
    }
    if item.depth > 0 {
      components.append("Reply level \(item.depth)")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKCommentThreadCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
  }
}
