import UIKit
import FKUIKit
import FKBusinessKit

/// Dropdown anchored to **`FKTabBar`** (default). Tabs, switch animations, callbacks — no custom anchor APIs.
///
/// Uses `FKTabBarFilterTabBarHostView` so the tab row stays **top-aligned** with natural height.
/// ``FKTabBarFilterDefaultTabBarHost`` would pin ``FKTabBar`` to the full host height (undesirable for top-aligned titles).
final class FKTabBarFilterTabBarAnchorExampleViewController: UIViewController {
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterTabBarHostView()
  private lazy var filter: FKTabBarFilterController<FKTabBarFilterExampleTabID> = {
    FKTabBarFilterDropdownExampleFactory.makeController(tabBarHost: host) { [weak self] line in
      self?.appendLog(line)
    }
  }()

  private let animationControl = UISegmentedControl(items: ["Replace", "Dismiss→Present"])

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Tab bar anchor"
    view.backgroundColor = .systemBackground
    setupNavigation()
    setupChild()
    setupLogView()
    appendLog("Anchor = embedded FKTabBar (default). Tap tabs; toggle replace vs dismiss→present above.")
  }

  private func setupNavigation() {
    animationControl.selectedSegmentIndex = 0
    animationControl.addTarget(self, action: #selector(didChangeAnimationStyle), for: .valueChanged)
    navigationItem.titleView = animationControl

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(didTapOpenFilters)),
      UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapClose)),
    ]
  }

  private func setupChild() {
    filter.embed(in: self)
  }

  private func setupLogView() {
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: filter.view)
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }

  @objc private func didTapOpenFilters() {
    filter.expandPanel(for: .filters, animated: true)
  }

  @objc private func didTapClose() {
    filter.collapsePanel(animated: true)
  }

  @objc private func didChangeAnimationStyle() {
    switch animationControl.selectedSegmentIndex {
    case 0:
      filter.configuration.anchorReplacementPolicy = .replaceInPlace(contentTransition: .crossfade(duration: 0.18))
      appendLog("anchorReplacementPolicy = replaceInPlace(crossfade)")
    default:
      filter.configuration.anchorReplacementPolicy = .dismissThenPresent(dismissAnimated: false, presentAnimated: true)
      appendLog("anchorReplacementPolicy = dismissThenPresent")
    }
  }
}
