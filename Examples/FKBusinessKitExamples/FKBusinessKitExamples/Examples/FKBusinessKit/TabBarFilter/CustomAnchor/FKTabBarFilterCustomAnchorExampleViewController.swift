import UIKit
import FKUIKit
import FKBusinessKit

/// Custom **`UIView`** anchor only (no visible `FKTabBar`). Tap the bar to call ``togglePanel(for:animated:)``; Open/Close use the same APIs.
final class FKTabBarFilterCustomAnchorExampleViewController: UIViewController {
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterCustomAnchorHostView()
  private lazy var dropdown: FKTabBarFilterDropdownController<FKTabBarFilterExampleTabID> = {
    FKTabBarFilterDropdownExampleFactory.makeController(tabBarHost: host) { [weak self] line in
      self?.appendLog(line)
    }
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Custom anchor"
    view.backgroundColor = .systemBackground
    setupAnchorInteraction()
    setupNavigation()
    setupChild()
    setupLogView()
    applyCustomAnchor()
    appendLog("Anchor source = anchorControl (UIButton). FKTabBar is off-screen; tap the bar or use Open/Close.")
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
    dropdown.embed(in: self)
  }

  private func setupLogView() {
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: dropdown.view)
  }

  private func applyCustomAnchor() {
    dropdown.setAnchor(source: host.anchorControl, overlayHost: host)
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }

  @objc private func didTapAnchorControl() {
    dropdown.togglePanel(for: .filters, animated: true)
  }

  @objc private func didTapOpenFilters() {
    dropdown.expandPanel(for: .filters, animated: true)
  }

  @objc private func didTapClose() {
    dropdown.collapsePanel(animated: true)
  }
}
