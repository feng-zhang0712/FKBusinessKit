import UIKit
import FKUIKit
import FKBusinessKit

/// Read-only note: horizontal edge trays are outside TabBarFilter’s anchor API.
final class FKTabBarFilterHorizontalEdgeNoteViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Horizontal edge trays"
    view.backgroundColor = .systemBackground

    let label = UILabel()
    label.numberOfLines = 0
    label.font = .preferredFont(forTextStyle: .body)
    label.textColor = .label
    label.text = """
    TabBarFilter presents panels with FKSheetPresentationController anchor layout. FKAnchor only attaches to the top or bottom edge of a source view and expands vertically (up or down).

    Left- and right-attached trays are available on FKSheetPresentationConfiguration.Layout.edge(_:) in FKUIKit, but TabBarFilter does not expose that layout mode — FKTabBarFilterController always uses anchor hosting for tab-attached panels.

    For side drawers, use FKSheetPresentationController directly with .edge(.left) or .edge(.right), or keep TabBarFilter for vertical zones (navigation bar, screen top, screen bottom).
    """
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    ])
  }
}
