import UIKit
import FKUIKit

/// Social feed row with author header, multi-line body, and optional nine-grid images.
@MainActor
public final class FKFeedContentCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKFeedContentItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Fallback estimated height before ``FKFeedContentCellHeightEstimator`` warms the cache.
  public static let preferredRowHeight: CGFloat = 160

  /// Row-specific configuration.
  public var feedContentConfiguration: FKFeedContentCellConfiguration = FKCellKitDefaults.feedContentCell {
    didSet { applyFeedContentConfiguration() }
  }

  private let avatar = FKAvatar()
  private let authorLabel = UILabel()
  private var timestampLabel: UILabel?
  private var bodyLabel: UILabel?
  private let imageGridView = FKFeedImageGridView()
  private let headerStack = UIStackView()
  private let rootStack = UIStackView()

  /// Binds a feed content item to the row UI.
  public func configure(with item: FKFeedContentItem) {
    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: feedContentConfiguration.avatarSize,
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

    syncImageGrid(with: item.imageURLs)
    updateAccessibility(for: item)
  }

  public override func setupUI() {
    selectionStyle = .none

    avatar.translatesAutoresizingMaskIntoConstraints = false

    authorLabel.numberOfLines = 1
    authorLabel.lineBreakMode = .byTruncatingTail

    headerStack.axis = .horizontal
    headerStack.alignment = .top
    headerStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    headerStack.addArrangedSubview(avatar)
    headerStack.addArrangedSubview(authorLabel)

    rootStack.axis = .vertical
    rootStack.alignment = .fill
    rootStack.spacing = feedContentConfiguration.sectionSpacing
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.addArrangedSubview(headerStack)

    containerView.addSubview(rootStack)

    NSLayoutConstraint.activate([
      avatar.widthAnchor.constraint(equalToConstant: feedContentConfiguration.avatarSize.diameter),
      avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

      rootStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rootStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rootStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rootStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyFeedContentConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    avatar.resetForReuse()
    authorLabel.text = nil
    releaseTimestampLabel()
    releaseBodyLabel()
    releaseImageGrid()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyFeedContentConfiguration()
  }

  private func applyFeedContentConfiguration() {
    cellConfiguration = feedContentConfiguration.table
    rootStack.spacing = feedContentConfiguration.sectionSpacing
    imageGridView.configuration = feedContentConfiguration.grid
    authorLabel.font = UIFont.preferredFont(forTextStyle: feedContentConfiguration.authorTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: feedContentConfiguration.timestampTextStyle)
    bodyLabel?.font = UIFont.preferredFont(forTextStyle: feedContentConfiguration.bodyTextStyle)
    bodyLabel?.numberOfLines = feedContentConfiguration.bodyMaxLines ?? 0
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .right
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: feedContentConfiguration.timestampTextStyle)
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
    label.numberOfLines = feedContentConfiguration.bodyMaxLines ?? 0
    label.lineBreakMode = .byWordWrapping
    label.textColor = .label
    label.font = UIFont.preferredFont(forTextStyle: feedContentConfiguration.bodyTextStyle)
    bodyLabel = label

    let insertIndex = min(1, rootStack.arrangedSubviews.count)
    rootStack.insertArrangedSubview(label, at: insertIndex)
    return label
  }

  private func releaseBodyLabel() {
    guard let bodyLabel else { return }
    bodyLabel.text = nil
    rootStack.removeArrangedSubview(bodyLabel)
    bodyLabel.removeFromSuperview()
    self.bodyLabel = nil
  }

  private func syncImageGrid(with imageURLs: [URL]) {
    if imageURLs.isEmpty {
      releaseImageGrid()
    } else {
      if imageGridView.superview == nil {
        rootStack.addArrangedSubview(imageGridView)
      }
      imageGridView.apply(imageURLs: imageURLs)
    }
  }

  private func releaseImageGrid() {
    imageGridView.prepareForReuse()
    guard imageGridView.superview != nil else { return }
    rootStack.removeArrangedSubview(imageGridView)
    imageGridView.removeFromSuperview()
  }

  private func updateAccessibility(for item: FKFeedContentItem) {
    var components = [item.authorName]
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if !item.body.isEmpty {
      components.append(item.body)
    }
    if !item.imageURLs.isEmpty {
      components.append("\(item.imageURLs.count) images")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKFeedContentCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
    imageGridView.prepareForReuse()
  }
}
