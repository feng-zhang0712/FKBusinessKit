import UIKit
import FKUIKit

/// Avatar + primary/subtitle stack used by ``FKUserListCell`` and other composite rows.
@MainActor
public final class FKUserListLeadingView: UIView {
  /// Layout and typography tokens for the leading column.
  public var configuration: FKUserListLeadingConfiguration {
    didSet { applyConfiguration() }
  }

  private let avatar = FKAvatar()
  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private let textStack = UIStackView()
  private var lastAppliedModel: FKUserListLeadingDisplayModel?

  /// Creates a user list leading composite view.
  public init(configuration: FKUserListLeadingConfiguration = .init()) {
    self.configuration = configuration
    super.init(frame: .zero)
    setupUI()
    applyConfiguration()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Binds display content to embedded widgets.
  public func apply(_ model: FKUserListLeadingDisplayModel) {
    lastAppliedModel = model
    applyAvatarChrome(from: model)
    avatar.setDisplayName(model.displayName)
    avatar.setImageURL(model.avatarURL, placeholder: nil)

    titleLabel.text = model.displayName
    if let subtitle = model.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    updateAccessibility(model: model)
  }

  /// Applies an unread badge on the avatar when `count` is greater than zero.
  public func applyUnreadCount(_ count: Int) {
    if count > 0 {
      avatar.fk_badge.showCount(count)
    } else {
      avatar.fk_badge.clear()
    }
  }

  /// Clears transient widget state during cell reuse.
  public func prepareForReuse() {
    lastAppliedModel = nil
    avatar.resetForReuse()
    avatar.fk_badge.clear()
    titleLabel.text = nil
    releaseSubtitleLabel()
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    avatar.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.translatesAutoresizingMaskIntoConstraints = false
    textStack.addArrangedSubview(titleLabel)

    addSubview(avatar)
    addSubview(textStack)

    NSLayoutConstraint.activate([
      avatar.leadingAnchor.constraint(equalTo: leadingAnchor),
      avatar.centerYAnchor.constraint(equalTo: centerYAnchor),
      avatar.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
      avatar.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

      textStack.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: configuration.spacing),
      textStack.trailingAnchor.constraint(equalTo: trailingAnchor),
      textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
      textStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
      textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
    ])
  }

  private func applyConfiguration() {
    titleLabel.font = UIFont.preferredFont(forTextStyle: configuration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: configuration.subtitleTextStyle)
    if let lastAppliedModel {
      applyAvatarChrome(from: lastAppliedModel)
    } else {
      FKCellKitAvatarSupport.applyListRowChrome(
        to: avatar,
        size: configuration.avatarSize,
        showsPresenceIndicator: configuration.showsPresenceIndicator
      )
    }
  }

  private func applyAvatarChrome(from model: FKUserListLeadingDisplayModel) {
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: configuration.avatarSize,
      isVerified: model.isVerified,
      presenceState: model.presenceState,
      showsPresenceIndicator: configuration.showsPresenceIndicator
    )
    avatar.setNeedsLayout()
    avatar.layoutIfNeeded()
  }

  @discardableResult
  private func ensureSubtitleLabel() -> UILabel {
    if let subtitleLabel { return subtitleLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: configuration.subtitleTextStyle)
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

  private func updateAccessibility(model: FKUserListLeadingDisplayModel) {
    isAccessibilityElement = true
    var components = [model.displayName]
    if let subtitle = model.subtitle, !subtitle.isEmpty {
      components.append(subtitle)
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
