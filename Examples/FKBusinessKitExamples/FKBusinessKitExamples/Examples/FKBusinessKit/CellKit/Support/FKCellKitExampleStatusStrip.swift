import UIKit
import FKUIKit

/// Compact monospace log strip for CellKit integration demos.
enum FKCellKitExampleStatusStrip {
  @MainActor
  @discardableResult
  static func install(on viewController: UIViewController, above scrollView: UIScrollView) -> UILabel {
    precondition(
      scrollView.superview != nil,
      "Call after FKDiffableTableViewController.viewDidLoad so the scroll view is in the hierarchy."
    )

    let label = UILabel()
    label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    label.textColor = .secondaryLabel
    label.numberOfLines = 3
    label.text = "Events appear here…"
    label.translatesAutoresizingMaskIntoConstraints = false
    viewController.view.addSubview(label)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 4),
      label.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 12),
      label.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -12),
    ])

    deactivateTopConstraints(for: scrollView, in: viewController.view)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
    ])
    return label
  }

  private static func deactivateTopConstraints(for scrollView: UIScrollView, in containerView: UIView) {
    for constraint in containerView.constraints where constraint.isActive {
      let involvesScrollView =
        (constraint.firstItem as? UIView) === scrollView || (constraint.secondItem as? UIView) === scrollView
      guard involvesScrollView else { continue }
      if constraint.firstAttribute == .top || constraint.secondAttribute == .top {
        constraint.isActive = false
      }
    }
  }

  @MainActor
  static func append(_ line: String, to label: UILabel) {
    let existing = label.text ?? ""
    let merged = (existing + "\n" + line)
      .split(separator: "\n")
      .suffix(3)
      .joined(separator: "\n")
    label.text = merged
  }
}
