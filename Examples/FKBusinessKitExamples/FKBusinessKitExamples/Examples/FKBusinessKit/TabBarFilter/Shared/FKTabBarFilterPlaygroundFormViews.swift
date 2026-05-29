import UIKit

/// Labeled form rows for TabBarFilter playground screens.
enum FKTabBarFilterPlaygroundFormViews {
  static func hintLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }

  static func sectionLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }

  static func labeledSegment(
    title: String,
    items: [String],
    selectedIndex: Int = 0,
    target: Any?,
    action: Selector
  ) -> UIStackView {
    let control = UISegmentedControl(items: items)
    control.selectedSegmentIndex = selectedIndex
    control.addTarget(target, action: action, for: .valueChanged)
    return labeledControl(title: title, control: control)
  }

  static func labeledSwitch(
    title: String,
    control: UISwitch,
    target: Any?,
    action: Selector
  ) -> UIStackView {
    control.addTarget(target, action: action, for: .valueChanged)
    return labeledControl(title: title, control: control)
  }

  static func labeledSwitch(
    title: String,
    isOn: Bool,
    target: Any?,
    action: Selector
  ) -> UIStackView {
    let control = UISwitch()
    control.isOn = isOn
    return labeledSwitch(title: title, control: control, target: target, action: action)
  }

  private static func labeledControl(title: String, control: UIView) -> UIStackView {
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .preferredFont(forTextStyle: .subheadline)
    titleLabel.numberOfLines = 0
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

    control.translatesAutoresizingMaskIntoConstraints = false
    control.setContentHuggingPriority(.required, for: .horizontal)

    let row = UIStackView(arrangedSubviews: [titleLabel, control])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 12
    row.translatesAutoresizingMaskIntoConstraints = false
    return row
  }

  static func makeControlsStack(
    arrangedSubviews: [UIView],
    spacing: CGFloat = 14
  ) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    stack.axis = .vertical
    stack.spacing = spacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }
}
