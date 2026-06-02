import UIKit
import FKUIKit
import FKBusinessKit

/// Custom **`UIView`** anchor: ``setAnchor(source:overlayHost:)``, ``updateAnchorPlacement``, and programmatic expand/collapse.
final class FKTabBarFilterCustomAnchorExampleViewController: UIViewController {
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterExampleAnchorHostView(
    placement: .interactive,
    title: "Custom anchor — tap to toggle Filters"
  )
  private let childContainer = UIView()
  private let expansionControl = UISegmentedControl(items: ["Expand down", "Expand up"])
  private let alignmentControl = UISegmentedControl(items: ["Fill width", "Center · match anchor"])
  private lazy var filter: FKTabBarFilterController<FKTabBarFilterExampleTabID> = {
    FKTabBarFilterDropdownExampleFactory.makeController(tabBarHost: host) { [weak self] line in
      self?.appendLog(line)
    }
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Custom anchor"
    view.backgroundColor = .systemBackground
    setupGeometryControls()
    setupAnchorInteraction()
    setupNavigation()
    setupChild()
    setupLogView()
    applyCustomAnchor()
    appendLog("Anchor source = anchorControl. Adjust geometry above; tap the bar or use Open/Close.")
  }

  private func setupGeometryControls() {
    expansionControl.selectedSegmentIndex = 0
    expansionControl.addTarget(self, action: #selector(didChangeGeometry), for: .valueChanged)
    alignmentControl.selectedSegmentIndex = 0
    alignmentControl.addTarget(self, action: #selector(didChangeGeometry), for: .valueChanged)

    let stack = UIStackView(arrangedSubviews: [expansionControl, alignmentControl])
    stack.axis = .vertical
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
    ])
  }

  private func setupAnchorInteraction() {
    host.anchorControl.addTarget(self, action: #selector(didTapAnchorControl), for: .touchUpInside)
  }

  private func setupNavigation() {
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(didTapOpenFilters)),
      UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapClose)),
    ]
  }

  private func setupChild() {
    childContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(childContainer)
    NSLayoutConstraint.activate([
      childContainer.topAnchor.constraint(equalTo: alignmentControl.bottomAnchor, constant: 8),
      childContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      childContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      childContainer.heightAnchor.constraint(equalToConstant: 120),
    ])
    filter.embed(in: self, pinTo: childContainer)
  }

  private func setupLogView() {
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: childContainer)
  }

  private func applyCustomAnchor() {
    filter.setAnchor(source: host.anchorControl, overlayHost: view)
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }

  @objc private func didChangeGeometry() {
    switch expansionControl.selectedSegmentIndex {
    case 1:
      filter.updateAnchorPlacement(attachmentEdge: .top, expansionDirection: .up)
      appendLog("geometry: edge=top direction=up")
    default:
      filter.updateAnchorPlacement(attachmentEdge: .bottom, expansionDirection: .down)
      appendLog("geometry: edge=bottom direction=down")
    }
    switch alignmentControl.selectedSegmentIndex {
    case 1:
      filter.updateAnchorPlacement(horizontalAlignment: .center, widthPolicy: .matchAnchor)
      appendLog("geometry: alignment=center width=matchAnchor")
    default:
      filter.updateAnchorPlacement(horizontalAlignment: .fill, widthPolicy: .matchContainer)
      appendLog("geometry: alignment=fill width=matchContainer")
    }
  }

  @objc private func didTapAnchorControl() {
    filter.togglePanel(for: .filters, animated: true)
  }

  @objc private func didTapOpenFilters() {
    filter.expandPanel(for: .filters, animated: true)
  }

  @objc private func didTapClose() {
    filter.collapsePanel(animated: true)
  }
}
