import UIKit
import FKUIKit

/// Settings account header row with large avatar, account lines, and disclosure chevron.
@MainActor
public final class FKSettingsProfileCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKSettingsProfileItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended row height for profile header rows.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var settingsProfileConfiguration: FKSettingsProfileCellConfiguration = FKCellKitDefaults.settingsProfileCell {
    didSet { applySettingsProfileConfiguration() }
  }

  private let avatar = FKAvatar()
  private let titleLabel = UILabel()
  private var accountLabel: UILabel?
  private let textStack = UIStackView()
  private var disclosureImageView: UIImageView?
  private let contentRow = UIStackView()

  /// Binds a settings profile item to the row UI.
  public func configure(with item: FKSettingsProfileItem) {
    avatar.setDisplayName(item.displayName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: settingsProfileConfiguration.avatarSize,
      isVerified: item.isVerified
    )

    titleLabel.text = item.displayName
    if let accountText = item.accountText, !accountText.isEmpty {
      ensureAccountLabel().text = accountText
    } else {
      releaseAccountLabel()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    avatar.translatesAutoresizingMaskIntoConstraints = false

    titleLabel.numberOfLines = 1
    titleLabel.lineBreakMode = .byTruncatingTail

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    contentRow.axis = .horizontal
    contentRow.alignment = .center
    contentRow.spacing = FKCellKitLayoutMetrics.interPartSpacing
    contentRow.translatesAutoresizingMaskIntoConstraints = false
    contentRow.addArrangedSubview(avatar)
    contentRow.addArrangedSubview(textStack)

    textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

    containerView.addSubview(contentRow)
    NSLayoutConstraint.activate([
      contentRow.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentRow.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      contentRow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentRow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: contentRow.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applySettingsProfileConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    avatar.resetForReuse()
    titleLabel.text = nil
    releaseAccountLabel()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applySettingsProfileConfiguration()
  }

  private func applySettingsProfileConfiguration() {
    cellConfiguration = settingsProfileConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: settingsProfileConfiguration.titleTextStyle)
    accountLabel?.font = UIFont.preferredFont(forTextStyle: settingsProfileConfiguration.accountTextStyle)

    FKCellKitAvatarSupport.applyListRowChrome(
      to: avatar,
      size: settingsProfileConfiguration.avatarSize
    )

    if settingsProfileConfiguration.showsDisclosureIndicator {
      ensureDisclosureImageView().image = UIImage(systemName: "chevron.forward")
      accessoryType = .none
    } else {
      releaseDisclosureImageView()
    }
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureDisclosureImageView() -> UIImageView {
    if let disclosureImageView { return disclosureImageView }

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .tertiaryLabel
    imageView.setContentHuggingPriority(.required, for: .horizontal)
    disclosureImageView = imageView
    contentRow.addArrangedSubview(imageView)
    return imageView
  }

  private func releaseDisclosureImageView() {
    guard let disclosureImageView else { return }
    disclosureImageView.image = nil
    contentRow.removeArrangedSubview(disclosureImageView)
    disclosureImageView.removeFromSuperview()
    self.disclosureImageView = nil
  }

  @discardableResult
  private func ensureAccountLabel() -> UILabel {
    if let accountLabel { return accountLabel }

    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = .secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: settingsProfileConfiguration.accountTextStyle)
    accountLabel = label
    textStack.addArrangedSubview(label)
    return label
  }

  private func releaseAccountLabel() {
    guard let accountLabel else { return }
    accountLabel.text = nil
    textStack.removeArrangedSubview(accountLabel)
    accountLabel.removeFromSuperview()
    self.accountLabel = nil
  }

  private func updateAccessibility(for item: FKSettingsProfileItem) {
    var components = [item.displayName]
    if let accountText = item.accountText, !accountText.isEmpty {
      components.append(accountText)
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKSettingsProfileCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
  }
}
