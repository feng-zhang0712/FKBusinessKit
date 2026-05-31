import UIKit
import FKUIKit
import FKBusinessKit

/// Interactive demo for dropdown configuration: tab switching, caching, backdrop, hairline, and layout animation.
final class FKTabBarFilterConfigurationPlaygroundViewController: UIViewController {
  private enum TabSwitch: Int {
    case crossfade = 0
    case dismissThenPresent
    case slideDown
    case slideUp
  }

  private enum ContentCache: Int {
    case perTab = 0
    case recreate
  }

  private enum Backdrop: Int {
    case standard = 0
    case strongDim
    case passthrough
  }

  private let filterState = FKTabBarFilterExampleState.presetEqualKnowledge()
  private let tabStrip = FKTabBarFilterExampleTabStripView()
  private var filterHost: FKTabBarFilterController<String>!
  private var panelFactory: FKTabBarFilterPanelFactory!

  private let tabSwitchSegment = UISegmentedControl(items: ["Crossfade", "Dismiss", "Slide ↓", "Slide ↑"])
  private let cacheSegment = UISegmentedControl(items: ["Per tab", "Recreate"])
  private let backdropSegment = UISegmentedControl(items: ["Default", "Strong", "Pass-through"])
  private let topHairlineSwitch = UISwitch()
  private let slowRelayoutSwitch = UISwitch()
  private let controlsStack: UIStackView

  init() {
    tabSwitchSegment.selectedSegmentIndex = TabSwitch.crossfade.rawValue
    cacheSegment.selectedSegmentIndex = ContentCache.perTab.rawValue
    backdropSegment.selectedSegmentIndex = Backdrop.standard.rawValue
    topHairlineSwitch.isOn = true

    tabSwitchSegment.translatesAutoresizingMaskIntoConstraints = false
    cacheSegment.translatesAutoresizingMaskIntoConstraints = false
    backdropSegment.translatesAutoresizingMaskIntoConstraints = false

    controlsStack = FKTabBarFilterPlaygroundFormViews.makeControlsStack(arrangedSubviews: [
      FKTabBarFilterPlaygroundFormViews.hintLabel(
        "Expand a tab, then switch tabs or change Browse categories to compare behaviors. Collapse the panel before changing controls."
      ),
      FKTabBarFilterPlaygroundFormViews.sectionLabel("TAB SWITCHING"),
      tabSwitchSegment,
      FKTabBarFilterPlaygroundFormViews.sectionLabel("CONTENT CACHING"),
      cacheSegment,
      FKTabBarFilterPlaygroundFormViews.sectionLabel("BACKDROP"),
      backdropSegment,
      FKTabBarFilterPlaygroundFormViews.labeledSwitch(
        title: "Top hairline above panel",
        control: topHairlineSwitch,
        target: nil,
        action: #selector(configurationDidChange)
      ),
      FKTabBarFilterPlaygroundFormViews.labeledSwitch(
        title: "Slow layout relayout",
        control: slowRelayoutSwitch,
        target: nil,
        action: #selector(configurationDidChange)
      ),
    ])
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Configuration playground"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never

    wireControlTargets()
    view.addSubview(controlsStack)
    NSLayoutConstraint.activate([
      controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])

    installFilterHost()
    filterHost.onSelection = { FKTabBarFilterExampleChrome.debugPrintSelection($0) }
  }

  private func wireControlTargets() {
    tabSwitchSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    cacheSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    backdropSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    topHairlineSwitch.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    slowRelayoutSwitch.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
  }

  @objc private func configurationDidChange() {
    filterHost.dropdownController.collapsePanel(animated: false)
    panelFactory.wrapsPanelWithTopHairline = topHairlineSwitch.isOn
    filterHost.setFilterConfiguration(
      FKTabBarFilterExampleAppearance.makeFilterConfiguration(anchored: buildDropdownConfiguration())
    )
    filterHost.invalidateAllCachedContent()
  }

  private func installFilterHost() {
    panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(bindingTo: filterState)
    filterHost = FKTabBarFilterController(
      tabs: FKTabBarFilterEqualWidthTabSet.library.makeTabs(),
      panelFactory: panelFactory,
      filterConfiguration: FKTabBarFilterExampleAppearance.makeFilterConfiguration(
        anchored: buildDropdownConfiguration()
      ),
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
    _ = FKTabBarFilterExampleChrome.installBodyPlaceholder(below: strip.bottomAnchor, in: self)
  }

  private func buildDropdownConfiguration() -> FKTabBarFilterDropdownConfiguration {
    var cfg: FKTabBarFilterDropdownConfiguration = {
      switch Backdrop(rawValue: backdropSegment.selectedSegmentIndex) ?? .standard {
      case .standard:
        return FKTabBarFilterExampleAppearance.equalThreeAnchoredConfiguration()
      case .strongDim:
        return FKTabBarFilterExampleAppearance.equalThreeStrongBackdrop()
      case .passthrough:
        return FKTabBarFilterExampleAppearance.equalThreePassthroughBackdrop()
      }
    }()

    let slow = slowRelayoutSwitch.isOn
    let layoutDuration: TimeInterval = slow ? 0.42 : 0.24

    switch TabSwitch(rawValue: tabSwitchSegment.selectedSegmentIndex) ?? .crossfade {
    case .crossfade:
      cfg.anchorReplacementPolicy = .replaceInPlace(
        contentTransition: .crossfade(duration: 0.18),
        animateLayout: slow,
        layoutAnimationDuration: layoutDuration
      )
    case .dismissThenPresent:
      cfg.anchorReplacementPolicy = .dismissThenPresent(dismissAnimated: true, presentAnimated: true)
    case .slideDown:
      cfg.anchorReplacementPolicy = .replaceInPlace(
        contentTransition: .slideVertical(direction: .down, duration: 0.22),
        animateLayout: slow,
        layoutAnimationDuration: layoutDuration
      )
    case .slideUp:
      cfg.anchorReplacementPolicy = .replaceInPlace(
        contentTransition: .slideVertical(direction: .up, duration: 0.22),
        animateLayout: slow,
        layoutAnimationDuration: layoutDuration
      )
    }

    cfg.contentCachingPolicy = (cacheSegment.selectedSegmentIndex == ContentCache.recreate.rawValue)
      ? .recreate
      : .cachePerTab
    return cfg
  }
}
