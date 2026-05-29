import UIKit
import FKUIKit
import FKBusinessKit

/// Minimal custom panel registered via ``FKTabBarFilterPanelFactory/PanelSource/custom(make:)``.
final class FKTabBarFilterCustomPanelKindExampleViewController: UIViewController {
  private var onSelection: ((FKTabBarFilterPanelSelection) -> Void)?

  static func make(
    allowsMultipleSelection: Bool,
    onSelection: @escaping (FKTabBarFilterPanelSelection) -> Void
  ) -> UIViewController {
    let vc = FKTabBarFilterCustomPanelKindExampleViewController()
    vc.onSelection = onSelection
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let titleLabel = UILabel()
    titleLabel.text = "Custom panel kind"
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0

    let detailLabel = UILabel()
    detailLabel.text = "Built with PanelSource.custom — not a built-in two-column, chips, or list panel."
    detailLabel.font = .preferredFont(forTextStyle: .subheadline)
    detailLabel.textColor = .secondaryLabel
    detailLabel.textAlignment = .center
    detailLabel.numberOfLines = 0

    let applyButton = UIButton(configuration: {
      var config = UIButton.Configuration.filled()
      config.title = "Apply “Featured”"
      config.cornerStyle = .medium
      return config
    }())
    applyButton.addAction(UIAction { [weak self] _ in
      self?.applyFeatured()
    }, for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel, applyButton])
    stack.axis = .vertical
    stack.spacing = 16
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])

    preferredContentSize = CGSize(width: 0, height: 168)
  }

  private func applyFeatured() {
    let item = FKTabBarFilterOptionItem(
      id: FKTabBarFilterID(rawValue: "promo.featured"),
      title: "Featured",
      isSelected: true
    )
    let selection = FKTabBarFilterPanelSelection(
      sectionID: FKTabBarFilterID(rawValue: "promo"),
      item: item,
      effectiveSelectionMode: .single
    )
    onSelection?(selection)
  }
}
