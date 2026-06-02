import UIKit
import FKUIKit
import FKBusinessKit

/// Compares vertical anchor zones and presentation modes (filter strip vs custom anchor) on one screen.
final class FKTabBarFilterAnchorZonesPlaygroundViewController: UIViewController {
  private enum PresentationMode: Int {
    case filterStrip = 0
    case customAnchor
  }

  private let zoneSegment = UISegmentedControl(items: ["Nav bar", "Screen top", "Screen bottom"])
  private let modeSegment = UISegmentedControl(items: ["Filter strip", "Custom anchor"])
  private let hintLabel = UILabel()
  private let controlsStack: UIStackView
  private let logView = FKTabBarFilterExampleLogHelpers.makeCallbackLogTextView()

  private let tabStrip = FKTabBarFilterExampleTabStripView()
  private let filterState = FKTabBarFilterExampleState.presetEqualKnowledge()
  private var filterHost: FKTabBarFilterController<String>?
  private var filter: FKTabBarFilterController<FKTabBarFilterExampleTabID>?
  private var anchorHost: FKTabBarFilterExampleAnchorHostView?
  private let embedContainer = UIView()
  private var zoneInstallation: FKTabBarFilterAnchorZoneInstaller.Installation?
  private var chromeViews: [UIView] = []
  private var logConstraints: [NSLayoutConstraint] = []

  init() {
    zoneSegment.selectedSegmentIndex = 0
    modeSegment.selectedSegmentIndex = 0
    zoneSegment.translatesAutoresizingMaskIntoConstraints = false
    modeSegment.translatesAutoresizingMaskIntoConstraints = false

    hintLabel.font = .preferredFont(forTextStyle: .subheadline)
    hintLabel.textColor = .secondaryLabel
    hintLabel.numberOfLines = 0
    hintLabel.translatesAutoresizingMaskIntoConstraints = false

    controlsStack = FKTabBarFilterPlaygroundFormViews.makeControlsStack(arrangedSubviews: [
      FKTabBarFilterPlaygroundFormViews.sectionLabel("ANCHOR ZONE"),
      zoneSegment,
      FKTabBarFilterPlaygroundFormViews.sectionLabel("PRESENTATION"),
      modeSegment,
      hintLabel,
    ])
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Anchor zones"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never

    embedContainer.translatesAutoresizingMaskIntoConstraints = false
    embedContainer.backgroundColor = .clear
    embedContainer.isHidden = true
    view.addSubview(embedContainer)
    view.addSubview(controlsStack)
    view.addSubview(logView)

    NSLayoutConstraint.activate([
      controlsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      controlsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

      embedContainer.widthAnchor.constraint(equalToConstant: 1),
      embedContainer.heightAnchor.constraint(equalToConstant: 1),
      embedContainer.topAnchor.constraint(equalTo: view.topAnchor),
      embedContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    ])

    zoneSegment.addTarget(self, action: #selector(demoSettingsDidChange), for: .valueChanged)
    modeSegment.addTarget(self, action: #selector(demoSettingsDidChange), for: .valueChanged)

    rebuildDemo()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    applyPresentationAnchor()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    FKTabBarFilterAnchorZoneInstaller.remove(zoneInstallation)
    zoneInstallation = nil
  }

  @objc private func demoSettingsDidChange() {
    rebuildDemo()
    applyPresentationAnchor()
  }

  private func currentZone() -> FKTabBarFilterAnchorZone {
    switch zoneSegment.selectedSegmentIndex {
    case 1: return .screenTop
    case 2: return .screenBottom
    default: return .navigationBar
    }
  }

  private func currentMode() -> PresentationMode {
    PresentationMode(rawValue: modeSegment.selectedSegmentIndex) ?? .filterStrip
  }

  private func rebuildDemo() {
    teardownDemo()

    let zone = currentZone()
    hintLabel.text = currentMode() == .filterStrip ? zone.filterHint : zone.customHint

    switch currentMode() {
    case .filterStrip:
      logView.isHidden = true
      installFilterStripDemo(zone: zone)
    case .customAnchor:
      logView.isHidden = false
      installCustomAnchorDemo()
      installLogLayout()
      appendLog(zone.geometryLogLine)
    }
  }

  private func teardownDemo() {
    NSLayoutConstraint.deactivate(logConstraints)
    logConstraints.removeAll()

    filterHost?.collapsePanel(animated: false)
    filter?.collapsePanel(animated: false)

    filterHost?.willMove(toParent: nil)
    filterHost?.view.removeFromSuperview()
    filterHost?.removeFromParent()
    filterHost = nil

    filter?.willMove(toParent: nil)
    filter?.view.removeFromSuperview()
    filter?.removeFromParent()
    filter = nil
    anchorHost = nil

    chromeViews.forEach { $0.removeFromSuperview() }
    chromeViews.removeAll()

    navigationItem.rightBarButtonItems = nil
    logView.text = ""
  }

  private func installLogLayout() {
    logConstraints = [
      logView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 12),
      logView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
      logView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
      logView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
    ]
    NSLayoutConstraint.activate(logConstraints)
  }

  private func installFilterStripDemo(zone: FKTabBarFilterAnchorZone) {
    tabStrip.extendsChromeThroughBottomSafeArea = zone == .screenTop || zone == .navigationBar

    let panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(bindingTo: filterState)
    let host = FKTabBarFilterController(
      tabs: [
        .init(id: "browse", panelKind: .hierarchy, title: "Browse"),
        .init(id: "formats", panelKind: .gridPrimary, title: "Formats"),
        .init(id: "sort", panelKind: .singleList, title: "Sort"),
      ],
      configuration: FKTabBarFilterExampleAppearance.makeEqualThreeFilterConfiguration(),
      panelFactory: panelFactory,
      tabBarHost: tabStrip
    )
    filterHost = host
    host.onSelection = { FKTabBarFilterExampleChrome.debugPrintSelection($0) }

    switch zone {
    case .navigationBar, .screenTop:
      guard let strip = FKTabBarFilterExampleChrome.embedStripAtBottom(
        filterHost: host,
        in: self,
        bottomAnchor: view.bottomAnchor,
        overlayHost: view,
        logSelection: false,
        extendsIntoBottomSafeArea: true
      ) else { return }
      chromeViews.append(strip)

      let filler = UIView()
      filler.backgroundColor = .systemBackground
      filler.translatesAutoresizingMaskIntoConstraints = false
      view.insertSubview(filler, at: 0)
      chromeViews.append(filler)
      NSLayoutConstraint.activate([
        filler.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 8),
        filler.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        filler.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        filler.bottomAnchor.constraint(equalTo: strip.topAnchor),
      ])

    case .screenBottom:
      guard let strip = FKTabBarFilterExampleChrome.embed(
        filterHost: host,
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

  private func installCustomAnchorDemo() {
    let host = FKTabBarFilterExampleAnchorHostView(placement: .belowNavigationBar, title: "")
    anchorHost = host
    let controller = FKTabBarFilterThreeTabScenario.makeController(tabBarHost: host) { [weak self] line in
      self?.appendLog(line)
    }
    filter = controller
    controller.embed(in: self, pinTo: embedContainer)

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(didTapOpen)),
      UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(didTapClose)),
    ]
  }

  private func applyPresentationAnchor() {
    let zone = currentZone()
    guard let installation = FKTabBarFilterAnchorZoneInstaller.install(zone.installerKind, in: self) else { return }
    FKTabBarFilterAnchorZoneInstaller.remove(zoneInstallation)
    zoneInstallation = installation

    switch currentMode() {
    case .filterStrip:
      guard let filterHost else { return }
      filterHost.applyAnchorInstallation(installation.filterAnchorInstallation)
      zone.applyAnchorGeometry(to: filterHost)
      zone.applyZonePresentationConfiguration(to: filterHost, in: self)
    case .customAnchor:
      guard let filter else { return }
      filter.applyAnchorInstallation(installation.filterAnchorInstallation)
      zone.applyAnchorGeometry(to: filter)
      zone.applyZonePresentationConfiguration(to: filter, in: self)
    }
  }

  private func appendLog(_ text: String) {
    FKTabBarFilterExampleLogHelpers.appendLogLine(text, to: logView)
  }

  @objc private func didTapOpen() {
    filter?.expandPanel(for: .filters, animated: true)
  }

  @objc private func didTapClose() {
    filter?.collapsePanel(animated: true)
  }
}

private extension FKTabBarFilterAnchorZone {
  var geometryLogLine: String {
    let g = anchorGeometry
    return "geometry: edge=\(g.attachmentEdge) direction=\(g.expansionDirection)"
  }
}
