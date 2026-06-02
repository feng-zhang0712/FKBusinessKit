import UIKit
import FKUIKit
import FKBusinessKit

/// Interactive demo for filter configuration: tab switching, caching, backdrop, hairline, and layout animation.
///
/// Chrome views are siblings of the anchored presentation host (never a full-screen stack on top of it).
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

  private let scrollView = UIScrollView()
  private let settingsStack: UIStackView
  private var contentRegionView: UIView?
  private let tabSwitchSegment = UISegmentedControl(items: ["Crossfade", "Dismiss", "Slide ↓", "Slide ↑"])
  private let cacheSegment = UISegmentedControl(items: ["Per tab", "Recreate"])
  private let backdropSegment = UISegmentedControl(items: ["Default", "Strong", "Pass-through"])
  private let topHairlineSwitch = UISwitch()
  private let slowRelayoutSwitch = UISwitch()

  init() {
    tabSwitchSegment.selectedSegmentIndex = TabSwitch.crossfade.rawValue
    cacheSegment.selectedSegmentIndex = ContentCache.perTab.rawValue
    backdropSegment.selectedSegmentIndex = Backdrop.standard.rawValue
    topHairlineSwitch.isOn = true

    settingsStack = FKTabBarFilterPlaygroundFormViews.makeControlsStack(
      arrangedSubviews: [
        FKTabBarFilterPlaygroundFormViews.hintLabel(
          "Expand a tab to exercise backdrop and transitions. Changing a control collapses the panel and applies the new configuration."
        ),
        FKTabBarFilterPlaygroundFormViews.labeledSegment(title: "Tab switching", control: tabSwitchSegment),
        FKTabBarFilterPlaygroundFormViews.labeledSegment(title: "Content caching", control: cacheSegment),
        FKTabBarFilterPlaygroundFormViews.labeledSegment(title: "Backdrop", control: backdropSegment),
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
      ],
      spacing: 12
    )
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Configuration playground"
    view.backgroundColor = .systemGroupedBackground
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(didTapOpen)),
      UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapClose)),
    ]

    installFilterHost()
    installChromeLayout()
    wireControlTargets()
    filterHost.onSelection = { FKTabBarFilterExampleChrome.debugPrintSelection($0) }
  }

  private func installFilterHost() {
    panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(bindingTo: filterState)
    var configuration = FKTabBarFilterExampleAppearance.makeFilterConfiguration(
      anchored: buildFilterConfiguration()
    )
    attachPresentationCallbacks(to: &configuration)

    filterHost = FKTabBarFilterController(
      tabs: FKTabBarFilterEqualWidthTabSet.library.makeTabs(),
      configuration: configuration,
      panelFactory: panelFactory,
      tabBarHost: tabStrip
    )
  }

  private func installChromeLayout() {
    guard let strip = FKTabBarFilterExampleChrome.embed(
      filterHost: filterHost,
      in: self,
      topAnchor: view.safeAreaLayoutGuide.topAnchor,
      overlayHost: view,
      logSelection: false
    ) else { return }

    let contentRegion = UIView()
    contentRegion.backgroundColor = .secondarySystemGroupedBackground
    contentRegion.translatesAutoresizingMaskIntoConstraints = false
    contentRegionView = contentRegion
    installContentRegionLabels(in: contentRegion)
    view.addSubview(contentRegion)

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    scrollView.backgroundColor = .systemBackground
    view.insertSubview(scrollView, belowSubview: strip)

    settingsStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(settingsStack)

    NSLayoutConstraint.activate([
      contentRegion.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentRegion.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentRegion.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      contentRegion.heightAnchor.constraint(equalToConstant: 148),

      scrollView.topAnchor.constraint(equalTo: strip.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: contentRegion.topAnchor),

      settingsStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      settingsStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      settingsStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
      settingsStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
      settingsStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
    ])

    view.bringSubviewToFront(strip)
  }

  private func installContentRegionLabels(in contentRegion: UIView) {
    let titleLabel = UILabel()
    titleLabel.text = "Main content"
    titleLabel.font = .preferredFont(forTextStyle: .headline)
    titleLabel.textColor = .secondaryLabel
    titleLabel.textAlignment = .center

    let subtitleLabel = UILabel()
    subtitleLabel.text = "Your list or feed lives here when the filter panel is collapsed."
    subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
    subtitleLabel.textColor = .tertiaryLabel
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0

    let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    labels.axis = .vertical
    labels.spacing = 6
    labels.alignment = .center
    labels.translatesAutoresizingMaskIntoConstraints = false
    contentRegion.addSubview(labels)
    NSLayoutConstraint.activate([
      labels.centerXAnchor.constraint(equalTo: contentRegion.centerXAnchor),
      labels.centerYAnchor.constraint(equalTo: contentRegion.centerYAnchor),
      labels.leadingAnchor.constraint(greaterThanOrEqualTo: contentRegion.leadingAnchor, constant: 20),
      labels.trailingAnchor.constraint(lessThanOrEqualTo: contentRegion.trailingAnchor, constant: -20),
    ])
  }

  private func attachPresentationCallbacks(to configuration: inout FKTabBarFilterConfiguration<String>) {
    var events = configuration.events
    let priorDidExpand = events.onDidExpand
    events.onDidExpand = { [weak self] tab in
      priorDidExpand?(tab)
      self?.bringFilterPresentationToFront()
    }
    configuration.events = events
  }

  /// Anchored presentation is added to ``view``; keep it above scroll/content chrome.
  private func bringFilterPresentationToFront() {
    FKTabBarFilterExampleChrome.bringAnchoredPresentationToFront(in: view)
  }

  private func wireControlTargets() {
    tabSwitchSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    cacheSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    backdropSegment.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    topHairlineSwitch.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
    slowRelayoutSwitch.addTarget(self, action: #selector(configurationDidChange), for: .valueChanged)
  }

  @objc private func configurationDidChange() {
    filterHost.collapsePanel(animated: false)
    panelFactory.wrapsPanelWithTopHairline = topHairlineSwitch.isOn
    var configuration = FKTabBarFilterExampleAppearance.makeFilterConfiguration(
      anchored: buildFilterConfiguration()
    )
    attachPresentationCallbacks(to: &configuration)
    filterHost.configuration = configuration
    filterHost.pinAnchoredPresentationOverlay(to: view)
    filterHost.invalidateAllCachedContent()
  }

  @objc private func didTapOpen() {
    filterHost.expandPanel(for: "browse", animated: true)
  }

  @objc private func didTapClose() {
    filterHost.collapsePanel(animated: true)
  }

  private func buildFilterConfiguration() -> FKTabBarFilterConfiguration<String> {
    var cfg: FKTabBarFilterConfiguration<String> = {
      switch Backdrop(rawValue: backdropSegment.selectedSegmentIndex) ?? .standard {
      case .standard:
        return FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration()
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
