import UIKit
import FKUIKit

/// Timestamp and optional role tag column for user list rows.
@MainActor
public final class FKUserListTrailingView: UIView {
  /// Layout tokens for the trailing column.
  public var configuration: FKUserListTrailingConfiguration {
    didSet { applyConfiguration() }
  }

  private var roleTag: FKTag?
  private var timestampLabel: UILabel?
  private let stack = UIStackView()

  /// Creates a user list trailing composite view.
  public init(configuration: FKUserListTrailingConfiguration = .init()) {
    self.configuration = configuration
    super.init(frame: .zero)
    setupUI()
    applyConfiguration()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Binds trailing content.
  public func apply(_ model: FKUserListTrailingDisplayModel) {
    if let tagModel = model.roleTag {
      let tag = ensureRoleTag()
      tag.title = tagModel.title
      tag.variant = tagModel.variant
    } else {
      releaseRoleTag()
    }

    if let timestamp = model.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    isHidden = roleTag == nil && timestampLabel == nil
  }

  /// Clears trailing content during cell reuse.
  public func prepareForReuse() {
    releaseRoleTag()
    releaseTimestampLabel()
    isHidden = true
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    setContentHuggingPriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .horizontal)

    stack.axis = .vertical
    stack.alignment = .trailing
    stack.spacing = FKCellKitLayoutMetrics.trailingStackSpacing
    stack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func applyConfiguration() {
    timestampLabel?.font = UIFont.preferredFont(forTextStyle: configuration.timestampTextStyle)
    timestampLabel?.textColor = configuration.timestampColor
    timestampLabel?.numberOfLines = configuration.timestampNumberOfLines
  }

  @discardableResult
  private func ensureRoleTag() -> FKTag {
    if let roleTag { return roleTag }

    let tag = FKTag()
    roleTag = tag
    stack.insertArrangedSubview(tag, at: 0)
    return tag
  }

  private func releaseRoleTag() {
    guard let roleTag else { return }
    roleTag.title = ""
    stack.removeArrangedSubview(roleTag)
    roleTag.removeFromSuperview()
    self.roleTag = nil
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }

    let label = UILabel()
    label.textAlignment = .right
    label.font = UIFont.preferredFont(forTextStyle: configuration.timestampTextStyle)
    label.textColor = configuration.timestampColor
    label.numberOfLines = configuration.timestampNumberOfLines
    timestampLabel = label
    stack.addArrangedSubview(label)
    return label
  }

  private func releaseTimestampLabel() {
    guard let timestampLabel else { return }
    timestampLabel.text = nil
    stack.removeArrangedSubview(timestampLabel)
    timestampLabel.removeFromSuperview()
    self.timestampLabel = nil
  }
}
