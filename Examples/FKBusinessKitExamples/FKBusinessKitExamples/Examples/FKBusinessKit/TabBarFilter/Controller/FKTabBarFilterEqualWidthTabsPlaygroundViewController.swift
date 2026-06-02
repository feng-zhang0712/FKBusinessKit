import UIKit
import FKUIKit
import FKBusinessKit

/// Compares equal-width tab datasets (commerce vs library) on one screen.
final class FKTabBarFilterEqualWidthTabsPlaygroundViewController: UIViewController {
  private let tabStrip = FKTabBarFilterExampleTabStripView()
  private let datasetSegment = UISegmentedControl(items: FKTabBarFilterEqualWidthTabSet.allCases.map(\.menuTitle))
  private let hintLabel = FKTabBarFilterPlaygroundFormViews.hintLabel(
    "Switch datasets to compare panel recipes. Expand each tab to see grid, hierarchy, tags, or list layouts."
  )
  private let controlsStack: UIStackView

  private var filterState = FKTabBarFilterExampleState.presetEqualBusiness()
  private var filterHost: FKTabBarFilterController<String>!
  private var panelFactory: FKTabBarFilterPanelFactory!
  private var chromeViews: [UIView] = []

  init() {
    datasetSegment.selectedSegmentIndex = FKTabBarFilterEqualWidthTabSet.commerce.rawValue
    datasetSegment.translatesAutoresizingMaskIntoConstraints = false
    controlsStack = FKTabBarFilterPlaygroundFormViews.makeControlsStack(arrangedSubviews: [
      hintLabel,
      FKTabBarFilterPlaygroundFormViews.sectionLabel("DATASET"),
      datasetSegment,
    ])
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Equal-width tabs"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never

    datasetSegment.addTarget(self, action: #selector(datasetDidChange), for: .valueChanged)
    view.addSubview(controlsStack)
    NSLayoutConstraint.activate([
      controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])

    rebuildFilterHost()
    filterHost.onSelection = { FKTabBarFilterExampleChrome.debugPrintSelection($0) }
  }

  @objc private func datasetDidChange() {
    rebuildFilterHost()
  }

  private func rebuildFilterHost() {
    filterHost?.collapsePanel(animated: false)
    filterHost?.willMove(toParent: nil)
    filterHost?.view.removeFromSuperview()
    filterHost?.removeFromParent()
    chromeViews.forEach { $0.removeFromSuperview() }
    chromeViews.removeAll()

    let dataset = FKTabBarFilterEqualWidthTabSet(rawValue: datasetSegment.selectedSegmentIndex) ?? .commerce
    filterState = dataset.initialState()
    panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(bindingTo: filterState)
    filterHost = FKTabBarFilterController(
      tabs: dataset.makeTabs(),
      configuration: FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration(),
      panelFactory: panelFactory,
      tabBarHost: tabStrip
    )

    guard let strip = FKTabBarFilterExampleChrome.embed(
      filterHost: filterHost,
      in: self,
      topAnchor: controlsStack.bottomAnchor,
      topConstant: 12,
      overlayHost: view,
      logSelection: false
    ) else { return }
    chromeViews.append(strip)
    chromeViews.append(FKTabBarFilterExampleChrome.installBodyPlaceholder(below: strip.bottomAnchor, in: self))
  }
}
