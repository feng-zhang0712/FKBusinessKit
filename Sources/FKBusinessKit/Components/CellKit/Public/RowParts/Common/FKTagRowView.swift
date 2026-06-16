import UIKit
import FKUIKit

/// Horizontally arranged ``FKTag`` views for product or content metadata.
@MainActor
public final class FKTagRowView: UIView {
  /// Spacing between tags.
  public var spacing: CGFloat = FKCellKitLayoutMetrics.trailingStackSpacing {
    didSet { stack.spacing = spacing }
  }

  private let stack = UIStackView()
  private var tagViews: [FKTag] = []

  /// Creates a horizontal tag row.
  public init(spacing: CGFloat = FKCellKitLayoutMetrics.trailingStackSpacing) {
    self.spacing = spacing
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Rebuilds tags from display models.
  public func apply(_ tags: [FKTagDisplayModel]) {
    stack.arrangedSubviews.forEach { view in
      stack.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
    tagViews.removeAll()

    tags.forEach { model in
      let tag = FKTag(title: model.title, variant: model.variant)
      tagViews.append(tag)
      stack.addArrangedSubview(tag)
    }

    isHidden = tags.isEmpty
  }

  /// Clears all tags during reuse.
  public func prepareForReuse() {
    apply([])
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = spacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}
