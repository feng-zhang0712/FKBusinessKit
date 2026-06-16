import UIKit
import FKUIKit

/// Product review row with avatar, star rating, body text, and optional photo strip.
@MainActor
public final class FKReviewListCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKReviewListItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended minimum row height for review rows.
  public static let preferredRowHeight: CGFloat = 120

  /// Row-specific configuration.
  public var reviewListConfiguration: FKReviewListCellConfiguration = FKCellKitDefaults.reviewListCell {
    didSet { applyReviewListConfiguration() }
  }

  private let avatar = FKAvatar()
  private let authorLabel = UILabel()
  private let ratingControl = FKRatingControl.readOnlyStars(value: 0, itemCount: 5)
  private var timestampLabel: UILabel?
  private let reviewLabel = UILabel()
  private let photoStack = UIStackView()
  /// Absorbs trailing space so fixed-size thumbnails are not stretched by `.fill` distribution.
  private let photoTrailingSpacer = UIView()
  private var photoImageViews: [FKImageView] = []
  private let headerStack = UIStackView()
  private let contentStack = UIStackView()

  /// Binds a review list item to the row UI.
  public func configure(with item: FKReviewListItem) {
    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: reviewListConfiguration.avatarSize
    )

    authorLabel.text = item.authorName
    ratingControl.maximumValue = 5
    ratingControl.setValue(item.rating, animated: false, sendsControlEvents: false)

    if let timestamp = item.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    reviewLabel.text = item.reviewText
    applyPhotoStrip(urls: item.imageURLs)
    updateAccessibility(for: item)
  }

  public override func setupUI() {
    authorLabel.numberOfLines = 1
    avatar.translatesAutoresizingMaskIntoConstraints = false

    ratingControl.isUserInteractionEnabled = false
    ratingControl.setContentHuggingPriority(.required, for: .horizontal)
    ratingControl.setContentCompressionResistancePriority(.required, for: .horizontal)

    authorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    headerStack.axis = .horizontal
    headerStack.alignment = .center
    headerStack.distribution = .fill
    headerStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    headerStack.addArrangedSubview(avatar)
    headerStack.addArrangedSubview(authorLabel)
    headerStack.addArrangedSubview(ratingControl)

    photoStack.axis = .horizontal
    photoStack.alignment = .leading
    photoStack.distribution = .fill
    photoStack.spacing = 6
    photoTrailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    photoTrailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    photoStack.addArrangedSubview(photoTrailingSpacer)

    reviewLabel.numberOfLines = reviewListConfiguration.reviewMaxLines ?? 0
    reviewLabel.lineBreakMode = .byTruncatingTail

    contentStack.axis = .vertical
    contentStack.alignment = .fill
    contentStack.spacing = reviewListConfiguration.sectionSpacing
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(headerStack)
    contentStack.addArrangedSubview(reviewLabel)

    containerView.addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyReviewListConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    avatar.setImageURL(nil, placeholder: nil)
    authorLabel.text = nil
    ratingControl.setValue(0, animated: false, sendsControlEvents: false)
    releaseTimestampLabel()
    reviewLabel.text = nil
    releasePhotoStack()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyReviewListConfiguration()
  }

  private func applyReviewListConfiguration() {
    cellConfiguration = reviewListConfiguration.table
    authorLabel.font = UIFont.preferredFont(forTextStyle: reviewListConfiguration.authorTextStyle)
    reviewLabel.font = UIFont.preferredFont(forTextStyle: reviewListConfiguration.reviewTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: reviewListConfiguration.timestampTextStyle)
    contentStack.spacing = reviewListConfiguration.sectionSpacing
    applyCellConfiguration()
  }

  private func applyPhotoStrip(urls: [URL]) {
    clearPhotoStrip()
    let limited = Array(urls.prefix(3))
    guard !limited.isEmpty else {
      releasePhotoStack()
      return
    }
    ensurePhotoStack()
    for url in limited {
      let imageView = FKImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.clipsToBounds = true
      imageView.layer.cornerRadius = reviewListConfiguration.photoCornerRadius
      imageView.load(url: url)
      NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: reviewListConfiguration.photoSide),
        imageView.heightAnchor.constraint(equalToConstant: reviewListConfiguration.photoSide),
      ])
      let insertIndex = max(0, photoStack.arrangedSubviews.count - 1)
      photoStack.insertArrangedSubview(imageView, at: insertIndex)
      photoImageViews.append(imageView)
    }
  }

  private func clearPhotoStrip() {
    photoImageViews.forEach { $0.cancelLoad(); $0.removeFromSuperview() }
    photoImageViews.removeAll()
    for subview in photoStack.arrangedSubviews where subview !== photoTrailingSpacer {
      photoStack.removeArrangedSubview(subview)
      subview.removeFromSuperview()
    }
  }

  private func ensurePhotoStack() {
    guard photoStack.superview == nil else { return }
    contentStack.addArrangedSubview(photoStack)
  }

  private func releasePhotoStack() {
    clearPhotoStrip()
    guard photoStack.superview != nil else { return }
    contentStack.removeArrangedSubview(photoStack)
    photoStack.removeFromSuperview()
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.textColor = .tertiaryLabel
    label.font = UIFont.preferredFont(forTextStyle: reviewListConfiguration.timestampTextStyle)
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

  private func updateAccessibility(for item: FKReviewListItem) {
    var components = [item.authorName, "\(item.rating) stars", item.reviewText]
    if let timestamp = item.timestampText { components.append(timestamp) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKReviewListCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    releasePhotoStack()
    avatar.setImageURL(nil, placeholder: nil)
  }
}
