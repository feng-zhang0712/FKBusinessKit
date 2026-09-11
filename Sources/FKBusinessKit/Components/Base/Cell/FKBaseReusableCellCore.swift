import UIKit

/// Shared Auto Layout and shadow helpers for ``FKBaseTableViewCell`` and ``FKBaseCollectionViewCell``.
@MainActor
enum FKBaseReusableCellCore {

  static func activateContainerConstraints(
    containerView: UIView,
    contentView: UIView,
    insets: UIEdgeInsets,
    storage: inout [NSLayoutConstraint]
  ) {
    NSLayoutConstraint.deactivate(storage)
    let top = containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top)
    let leading = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left)
    let trailing = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right)
    // Priority 999 so UITableView’s temporary `UIView-Encapsulated-Layout-Height` (often 44)
    // can yield during self-sizing measurement instead of fighting required content heights.
    let bottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
    bottom.priority = UILayoutPriority(999)
    storage = [top, leading, trailing, bottom]
    NSLayoutConstraint.activate(storage)
  }

  /// Updates `layer.shadowPath` for rounded-rect shadows (reduces off-screen rendering when set).
  static func applyShadowPath(
    to layer: CALayer,
    bounds: CGRect,
    cornerRadius: CGFloat,
    shadowPathInset: CGFloat,
    shadowOpacity: Float,
    shadowRadius: CGFloat
  ) {
    guard shadowOpacity > .zero || shadowRadius > .zero else {
      layer.shadowPath = nil
      return
    }
    let pathRect = bounds.insetBy(dx: shadowPathInset, dy: shadowPathInset)
    layer.shadowPath = UIBezierPath(roundedRect: pathRect, cornerRadius: cornerRadius).cgPath
  }
}
