import UIKit
import FKUIKit

/// IM / contacts style list row combining ``FKUserListLeadingView`` and ``FKUserListTrailingView``.
@MainActor
public final class FKUserListCell: FKCellKitTableCell, FKListTableCellConfigurable {
  public typealias Item = FKUserListItem

  /// Registry key for ListKit custom items (`String(describing: FKUserListCell.self)`).
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended fixed row height for feed-style lists.
  public static let preferredRowHeight: CGFloat = FKCellKitLayoutMetrics.minimumTableRowHeight()

  /// Row-specific configuration including leading/trailing tokens.
  public var userListConfiguration: FKUserListCellConfiguration = FKCellKitDefaults.userListCell {
    didSet { applyUserListConfiguration() }
  }

  private let leadingView = FKUserListLeadingView()
  private var trailingView: FKUserListTrailingView?
  private let rowStack = UIStackView()

  /// Binds a user list item to embedded row parts.
  public func configure(with item: FKUserListItem) {
    leadingView.apply(
      FKUserListLeadingDisplayModel(
        displayName: item.displayName,
        subtitle: item.subtitle,
        avatarURL: item.avatarURL,
        presenceState: item.presenceState,
        isVerified: item.isVerified
      )
    )
    leadingView.applyUnreadCount(item.unreadCount)

    let hasTrailingContent = item.roleTag != nil
      || (item.timestampText.map { !$0.isEmpty } ?? false)
    if hasTrailingContent {
      ensureTrailingView().apply(
        FKUserListTrailingDisplayModel(
          timestampText: item.timestampText,
          roleTag: item.roleTag
        )
      )
    } else {
      releaseTrailingView()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.distribution = .fill
    rowStack.spacing = FKCellKitLayoutMetrics.interPartSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false

    leadingView.setContentHuggingPriority(.defaultLow, for: .horizontal)

    rowStack.addArrangedSubview(leadingView)
    containerView.addSubview(rowStack)

    NSLayoutConstraint.activate([
      rowStack.topAnchor.constraint(equalTo: containerView.topAnchor),
      rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      FKCellKitLayoutMetrics.minimumContentHeightConstraint(for: rowStack.heightAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyUserListConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    leadingView.prepareForReuse()
    releaseTrailingView()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyUserListConfiguration()
  }

  private func applyUserListConfiguration() {
    cellConfiguration = userListConfiguration.table
    leadingView.configuration = userListConfiguration.leading
    trailingView?.configuration = userListConfiguration.trailing
    applyCellConfiguration()
  }

  @discardableResult
  private func ensureTrailingView() -> FKUserListTrailingView {
    if let trailingView { return trailingView }

    let view = FKUserListTrailingView(configuration: userListConfiguration.trailing)
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.setContentCompressionResistancePriority(.required, for: .horizontal)
    trailingView = view
    rowStack.addArrangedSubview(view)
    return view
  }

  private func releaseTrailingView() {
    guard let trailingView else { return }
    trailingView.prepareForReuse()
    rowStack.removeArrangedSubview(trailingView)
    trailingView.removeFromSuperview()
    self.trailingView = nil
  }

  private func updateAccessibility(for item: FKUserListItem) {
    var components = [item.displayName]
    if let subtitle = item.subtitle, !subtitle.isEmpty {
      components.append(subtitle)
    }
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if item.unreadCount > 0 {
      components.append("\(item.unreadCount) unread")
    }
    if let roleTag = item.roleTag?.title, !roleTag.isEmpty {
      components.append(roleTag)
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKUserListCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {}
}
