import UIKit
import FKUIKit

/// Social feed row with author header, inline ``FKVideoPlayerView``, and optional caption.
@MainActor
public final class FKFeedVideoCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKFeedVideoItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for 16:9 video feed rows without caption.
  public static let preferredRowHeight: CGFloat = 320

  /// Row-specific configuration.
  public var feedVideoConfiguration: FKFeedVideoCellConfiguration = FKCellKitDefaults.feedVideoCell {
    didSet { applyFeedVideoConfiguration() }
  }

  /// Embedded player surface registered with ``FKListVideoVisibilityCoordinator``.
  public private(set) var playerView = FKVideoPlayerView()

  private let avatar = FKAvatar()
  private let authorLabel = UILabel()
  private var timestampLabel: UILabel?
  private var captionLabel: UILabel?
  private let headerStack = UIStackView()
  private let rootStack = UIStackView()
  private var videoHeightConstraint: NSLayoutConstraint?
  private var videoItem: FKVideoItem?
  private var isVideoPlaybackAttached = false

  /// Binds a feed video item to the row UI. Video playback starts on visibility forwarding.
  public func configure(with item: FKFeedVideoItem) {
    videoItem = item.video

    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: feedVideoConfiguration.avatarSize,
      isVerified: item.isVerified
    )

    authorLabel.text = item.authorName

    if let timestamp = item.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    if let caption = item.caption, !caption.isEmpty {
      ensureCaptionLabel().text = caption
    } else {
      releaseCaptionLabel()
    }

    updateAccessibility(for: item)
  }

  /// Computes a fixed row height for a given table width and optional caption.
  public static func preferredRowHeight(
    forWidth width: CGFloat,
    hasCaption: Bool,
    configuration: FKFeedVideoCellConfiguration = FKCellKitDefaults.feedVideoCell
  ) -> CGFloat {
    let insets = configuration.table.contentInsets
    let contentWidth = max(1, width - insets.left - insets.right)
    var height = insets.top + insets.bottom
    height += max(configuration.avatarSize.diameter, UIFont.preferredFont(forTextStyle: configuration.authorTextStyle).lineHeight)
    height += configuration.sectionSpacing
    height += contentWidth * configuration.videoHeightMultiplier
    if hasCaption {
      height += configuration.sectionSpacing
      height += UIFont.preferredFont(forTextStyle: configuration.captionTextStyle).lineHeight * 2
    }
    return height
  }

  public override func setupUI() {
    selectionStyle = .none

    avatar.translatesAutoresizingMaskIntoConstraints = false

    authorLabel.numberOfLines = 1
    authorLabel.lineBreakMode = .byTruncatingTail

    playerView.translatesAutoresizingMaskIntoConstraints = false
    playerView.clipsToBounds = true

    headerStack.axis = .horizontal
    headerStack.alignment = .top
    headerStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    headerStack.addArrangedSubview(avatar)
    headerStack.addArrangedSubview(authorLabel)

    rootStack.axis = .vertical
    rootStack.alignment = .fill
    rootStack.spacing = feedVideoConfiguration.sectionSpacing
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.addArrangedSubview(headerStack)
    rootStack.addArrangedSubview(playerView)

    containerView.addSubview(rootStack)

    videoHeightConstraint = playerView.heightAnchor.constraint(
      equalTo: playerView.widthAnchor,
      multiplier: feedVideoConfiguration.videoHeightMultiplier
    )

    NSLayoutConstraint.activate([
      avatar.widthAnchor.constraint(equalToConstant: feedVideoConfiguration.avatarSize.diameter),
      avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor),

      rootStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rootStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rootStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rootStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

      videoHeightConstraint!,
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyFeedVideoConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    avatar.resetForReuse()
    authorLabel.text = nil
    releaseTimestampLabel()
    releaseCaptionLabel()
    videoItem = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyFeedVideoConfiguration()
  }

  private func applyFeedVideoConfiguration() {
    cellConfiguration = feedVideoConfiguration.table
    rootStack.spacing = feedVideoConfiguration.sectionSpacing
    authorLabel.font = UIFont.preferredFont(forTextStyle: feedVideoConfiguration.authorTextStyle)
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: feedVideoConfiguration.timestampTextStyle)
    captionLabel?.font = UIFont.preferredFont(forTextStyle: feedVideoConfiguration.captionTextStyle)
    playerView.layer.cornerRadius = feedVideoConfiguration.videoCornerRadius
    videoHeightConstraint?.isActive = false
    videoHeightConstraint = playerView.heightAnchor.constraint(
      equalTo: playerView.widthAnchor,
      multiplier: feedVideoConfiguration.videoHeightMultiplier
    )
    videoHeightConstraint?.isActive = true
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .right
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: feedVideoConfiguration.timestampTextStyle)
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
  private func ensureCaptionLabel() -> UILabel {
    if let captionLabel { return captionLabel }

    let label = UILabel()
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textColor = .label
    label.font = UIFont.preferredFont(forTextStyle: feedVideoConfiguration.captionTextStyle)
    captionLabel = label
    rootStack.addArrangedSubview(label)
    return label
  }

  private func releaseCaptionLabel() {
    guard let captionLabel else { return }
    captionLabel.text = nil
    rootStack.removeArrangedSubview(captionLabel)
    captionLabel.removeFromSuperview()
    self.captionLabel = nil
  }

  private func updateAccessibility(for item: FKFeedVideoItem) {
    var components = [item.authorName]
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if let title = item.video.title, !title.isEmpty {
      components.append(title)
    }
    if let caption = item.caption, !caption.isEmpty {
      components.append(caption)
    }
    accessibilityLabel = components.joined(separator: ", ")
  }

  private func detachVideoPlaybackIfNeeded(
    coordinator: FKListVideoVisibilityCoordinator?,
    pool: FKVideoPlayerPool?
  ) {
    guard isVideoPlaybackAttached else { return }
    if let coordinator {
      coordinator.unregister(playerView)
    }
    if let pool {
      pool.releasePlayer(for: self)
    }
    isVideoPlaybackAttached = false
  }
}

extension FKFeedVideoCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
  }
}

extension FKFeedVideoCell: FKListCellVideoVisibilityHandling {
  public func cellWillDisplayVideo(
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    guard let videoItem, !isVideoPlaybackAttached else { return }
    let player = pool.player(for: self)
    player.bind(to: playerView)
    player.load(videoItem)
    coordinator.register(playerView)
    isVideoPlaybackAttached = true
  }

  public func cellDidEndDisplayingVideo(
    coordinator: FKListVideoVisibilityCoordinator,
    pool: FKVideoPlayerPool
  ) {
    detachVideoPlaybackIfNeeded(coordinator: coordinator, pool: pool)
    avatar.resetForReuse()
  }
}
