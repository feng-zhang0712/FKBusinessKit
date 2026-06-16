import UIKit
import FKUIKit

/// Invite code row with ``FKCopyChip`` and optional share affordance.
@MainActor
public final class FKInviteCodeCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKInviteCodeItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for invite code rows.
  public static let preferredRowHeight: CGFloat = 72

  /// Row-specific configuration.
  public var inviteCodeConfiguration: FKInviteCodeCellConfiguration = FKCellKitDefaults.inviteCodeCell {
    didSet { applyInviteCodeConfiguration() }
  }

  private let titleLabel = UILabel()
  private var subtitleLabel: UILabel?
  private let copyChip = FKCopyChip()
  private var shareImageView: UIImageView?
  private let textStack = UIStackView()
  private let actionStack = UIStackView()
  private let contentStack = UIStackView()
  private var boundItemID: String?
  private var boundShareHandlerID: String?

  /// Binds an invite code item to the row UI.
  public func configure(with item: FKInviteCodeItem) {
    boundItemID = item.id
    boundShareHandlerID = item.shareHandlerID

    titleLabel.text = item.title
    copyChip.text = item.inviteCode
    copyChip.copyText = item.inviteCode

    if let subtitle = item.subtitle, !subtitle.isEmpty {
      ensureSubtitleLabel().text = subtitle
    } else {
      releaseSubtitleLabel()
    }

    if item.showsShareAffordance {
      syncShareInteraction(on: ensureShareImageView(), handlerID: item.shareHandlerID)
    } else {
      releaseShareImageView()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    titleLabel.numberOfLines = 1

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = FKCellKitLayoutMetrics.titleSubtitleSpacing
    textStack.addArrangedSubview(titleLabel)

    actionStack.axis = .horizontal
    actionStack.alignment = .center
    actionStack.spacing = 8
    actionStack.addArrangedSubview(copyChip)

    contentStack.axis = .horizontal
    contentStack.alignment = .center
    contentStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    contentStack.addArrangedSubview(textStack)
    contentStack.addArrangedSubview(actionStack)

    containerView.addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: contentStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyInviteCodeConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    titleLabel.text = nil
    releaseSubtitleLabel()
    copyChip.text = ""
    copyChip.copyText = ""
    releaseShareImageView()
    boundItemID = nil
    boundShareHandlerID = nil
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyInviteCodeConfiguration()
  }

  private func applyInviteCodeConfiguration() {
    cellConfiguration = inviteCodeConfiguration.table
    titleLabel.font = UIFont.preferredFont(forTextStyle: inviteCodeConfiguration.titleTextStyle)
    subtitleLabel?.font = UIFont.preferredFont(forTextStyle: inviteCodeConfiguration.subtitleTextStyle)
    applyCellConfiguration()
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

  @discardableResult
  private func ensureShareImageView() -> UIImageView {
    if let shareImageView { return shareImageView }

    let imageView = UIImageView(image: UIImage(systemName: inviteCodeConfiguration.shareSymbolName))
    imageView.tintColor = inviteCodeConfiguration.shareTintColor
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    shareImageView = imageView
    actionStack.addArrangedSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: inviteCodeConfiguration.shareSymbolSide),
      imageView.heightAnchor.constraint(equalToConstant: inviteCodeConfiguration.shareSymbolSide),
    ])
    return imageView
  }

  private func releaseShareImageView() {
    guard let shareImageView else { return }
    actionStack.removeArrangedSubview(shareImageView)
    shareImageView.removeFromSuperview()
    self.shareImageView = nil
  }

  private func syncShareInteraction(on imageView: UIImageView, handlerID: String?) {
    imageView.gestureRecognizers?.forEach { imageView.removeGestureRecognizer($0) }
    let isInteractive = handlerID != nil
    imageView.isUserInteractionEnabled = isInteractive
    imageView.accessibilityTraits = isInteractive ? [.button, .image] : .image
    imageView.accessibilityLabel = isInteractive ? "Share" : nil
    if isInteractive {
      imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareTapped)))
    }
  }

  @objc private func shareTapped() {
    guard let boundItemID,
          let boundShareHandlerID,
          let controller = FKCellKitResponderLookup.diffableTableController(from: self),
          let handler = controller.cellKitValueHandlers.shareHandler(for: boundShareHandlerID) else {
      return
    }
    handler(FKListItemID(boundItemID))
  }

  private func updateAccessibility(for item: FKInviteCodeItem) {
    var components = [item.title, "Invite code \(item.inviteCode)"]
    if let subtitle = item.subtitle, !subtitle.isEmpty { components.insert(subtitle, at: 1) }
    accessibilityLabel = components.joined(separator: ", ")
  }
}
