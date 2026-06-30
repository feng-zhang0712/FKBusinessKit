import UIKit
import FKUIKit
import FKBusinessKit

/// Exercises ``FKTabBarFilterHosting/embedStrip`` with ``overlayHost: parent.view`` while a full-screen modal
/// is presented and dismissed (`animated: false`, matching SACTrain SearchNavigation).
///
/// After dismiss, the expanded anchor panel should sit flush under the tab bar (gap ≤ 1 pt) without a visible
/// intermediate gap or corrective animation.
final class FKTabBarFilterModalDismissRelayoutExampleViewController: UIViewController {
  private enum FilterTab: String, Hashable {
    case filters
  }

  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()
  private let host = FKTabBarFilterTabBarHostView()
  private lazy var filter = makeFilterController()
  private var didRunAutomatedCheck = false

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Modal dismiss relayout"
    view.backgroundColor = .systemBackground

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(didTapPresentSearch)),
      UIBarButtonItem(title: "Expand", style: .plain, target: self, action: #selector(didTapExpand)),
    ]

    setupFilterStrip()
    setupLogView()
    appendLog("Tap Expand, then Search. Modal dismisses with animated: false; gap should stay ≤ 1 pt.")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard didRunAutomatedCheck == false else { return }
    didRunAutomatedCheck = true
    runAutomatedModalDismissCheck()
  }

  private func setupFilterStrip() {
    guard let stripView = FKTabBarFilterHosting.embedStrip(
      filter,
      in: self,
      topAnchor: view.safeAreaLayoutGuide.topAnchor,
      fixedStripHeight: 44,
      overlayHost: view,
      useCompactTabButtonInsets: true
    ) else { return }

    FKTabBarFilterHosting.installContentBackgroundBelowStrip(
      in: self,
      stripBottom: stripView.bottomAnchor
    )
  }

  private func setupLogView() {
    FKTabBarFilterExampleLogHelpers.installLogView(logView, in: view, below: filter.view)
  }

  private func makeFilterController() -> FKTabBarFilterController<FilterTab> {
    let tabs: [FKTabBarFilterTab<FilterTab>] = [
      FKTabBarFilterTab(
        id: .filters,
        title: { "Filters" },
        panelContent: .viewController { FKTabBarFilterFiltersPanelExampleViewController() }
      ),
    ]

    var configuration = FKTabBarFilterConfiguration<FilterTab>()
    configuration.applyTintOnlyChevronTabTypography()
    configuration.presentationConfiguration.contentInsets = .init(top: 8, leading: 12, bottom: 12, trailing: 12)

    return FKTabBarFilterController(
      tabs: tabs,
      configuration: configuration,
      tabBarHost: host
    )
  }

  @objc private func didTapExpand() {
    filter.expandPanel(for: .filters, animated: true)
    appendLog("expandPanel(filters)")
  }

  @objc private func didTapPresentSearch() {
    present(makeSearchModal(), animated: true)
    appendLog("present fullScreen search")
  }

  private func runAutomatedModalDismissCheck() {
    filter.expandPanel(for: .filters, animated: false)
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let search = self.makeSearchModal()
      search.onDismiss = { [weak self] in
        self?.verifyAnchorAlignment(label: "after modal dismiss")
      }
      self.present(search, animated: false)
      DispatchQueue.main.async {
        search.dismissSelf(animated: false)
      }
    }
  }

  private func makeSearchModal() -> SearchModalViewController {
    SearchModalViewController()
  }

  private func verifyAnchorAlignment(label: String) {
    func measureAndLog(pass: String) {
      guard let gap = Self.measurePanelTopGap(tabBar: filter.tabBar, overlayHost: view) else {
        appendLog("\(label) (\(pass)): could not measure panel frame")
        return
      }
      let passed = abs(gap) <= 1
      appendLog(String(format: "%@ (%@): gap=%.2f pt → %@", label, pass, gap, passed ? "PASS" : "FAIL"))
      if pass == "async" {
        assert(passed, "Expected anchor panel top within 1 pt of tab bar bottom, got \(gap) pt")
      }
    }

    view.layoutIfNeeded()
    filter.relayoutExpandedPanelIfNeeded(animated: false)
    measureAndLog(pass: "sync")

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.view.layoutIfNeeded()
      measureAndLog(pass: "async")
    }
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }

  /// Distance from tab bar bottom to panel top in `overlayHost` coordinates (0 = flush).
  static func measurePanelTopGap(tabBar: UIView, overlayHost: UIView) -> CGFloat? {
    guard let panelView = findAnchorPresentationWrapper(in: overlayHost) else { return nil }
    let panelTop = panelView.convert(panelView.bounds, to: overlayHost).minY
    let anchorBottom = tabBar.convert(tabBar.bounds, to: overlayHost).maxY
    return panelTop - anchorBottom
  }

  private static func findAnchorPresentationWrapper(in root: UIView) -> UIView? {
    var match: UIView?
    func walk(_ view: UIView) {
      let typeName = String(describing: type(of: view))
      if typeName.contains("FKAnchorRootView") {
        // maskView is first; wrapperView (presentation shell) follows.
        if view.subviews.count > 1 {
          match = view.subviews[1]
        }
      }
      view.subviews.forEach(walk)
    }
    walk(root)
    return match
  }
}

// MARK: - Full-screen search stand-in

private final class SearchModalViewController: UIViewController {
  var onDismiss: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let label = UILabel()
    label.text = "Full-screen search (SACTrain stand-in)"
    label.font = .preferredFont(forTextStyle: .headline)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)

    let close = UIButton(type: .system)
    close.setTitle("Close (animated: false)", for: .normal)
    close.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    close.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(close)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
      label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
      label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

      close.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
      close.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }

  func dismissSelf(animated: Bool) {
    dismiss(animated: animated) { [weak self] in
      self?.onDismiss?()
    }
  }

  @objc private func didTapClose() {
    dismissSelf(animated: false)
  }
}
