import FKBusinessKit
import FKUIKit
import UIKit

/// Collection list scenario driven by ``FKBaseListDemoScenario`` (skeleton, empty, error, refresh).
final class FKBaseCollectionListScenarioExampleViewController: FKBusinessKitBase.CollectionViewController {

  private static let dataReuseId = "cell"
  private let scenario: FKBaseListDemoScenario
  private var labels: [String] = []
  private var retryCount = 0

  init(scenario: FKBaseListDemoScenario) {
    self.scenario = scenario
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    super.init(collectionViewLayout: layout)
    isPullToRefreshEnabled = scenario.usesPullToRefresh
    skeletonPlaceholderCount = 8
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = scenario.title
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Replay",
      style: .plain,
      target: self,
      action: #selector(replayTapped)
    )
  }

  override func configureCollectionView(_ collectionView: UICollectionView) {
    super.configureCollectionView(collectionView)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.dataReuseId)
  }

  override func loadInitialContent() {
    super.loadInitialContent()
    startInitialFlow()
  }

  override func performPullToRefresh() {
    switch scenario {
    case .pullRefreshFailure:
      FKBaseListMockFetch.run(delay: 0.9, outcome: .serverError(message: "Refresh failed")) { [weak self] outcome in
        self?.applyFetchOutcome(outcome, isPullRefresh: true)
      }
    case .pullRefreshBecomesEmpty:
      FKBaseListMockFetch.run(delay: 0.9, outcome: .empty) { [weak self] outcome in
        self?.applyFetchOutcome(outcome, isPullRefresh: true)
      }
    default:
      endPullToRefresh(success: true)
    }
  }

  @objc private func replayTapped() {
    retryCount = 0
    labels = []
    hideListEmptyState(animated: false)
    collectionView.reloadData()
    startInitialFlow()
  }

  private func startInitialFlow() {
    switch scenario {
    case .pullRefreshFailure, .pullRefreshBecomesEmpty:
      FKBaseListMockFetch.run(
        delay: 0.4,
        outcome: .success(items: FKBaseListMockFetch.sampleColors(count: 8))
      ) { [weak self] outcome in
        self?.applyFetchOutcome(outcome, isPullRefresh: false)
      }
    case .emptyStateLoadingTransition:
      let loading = FKEmptyStateConfiguration(phase: .loading, type: .loading, title: "Loading tiles…")
      applyListEmptyState(loading)
      FKBaseListMockFetch.run(outcome: .empty) { [weak self] _ in
        guard let self else { return }
        var empty = FKEmptyStateConfiguration.scenario(.noFavorites)
        empty.title = "No tiles yet"
        self.applyListEmptyState(empty)
      }
    case .errorRetryThenSuccess:
      labels = []
      collectionView.reloadData()
      presentErrorState(retryAttempt: retryCount)
    default:
      if scenario.usesSkeletonPlaceholders {
        beginSkeletonPlaceholderLoading()
      }
      FKBaseListMockFetch.run(outcome: mockOutcome(for: scenario, retryAttempt: retryCount)) { [weak self] outcome in
        self?.applyFetchOutcome(outcome, isPullRefresh: false)
      }
    }
  }

  private func mockOutcome(for scenario: FKBaseListDemoScenario, retryAttempt: Int) -> FKBaseListMockFetchOutcome {
    switch scenario {
    case .initialLoadSuccess:
      return .success(items: FKBaseListMockFetch.sampleColors(count: 8))
    case .initialLoadEmpty:
      return .empty
    case .initialLoadNoNetwork:
      return .noNetwork
    case .initialLoadServerError:
      return .serverError(message: "HTTP 503 — service unavailable")
    case .errorRetryThenSuccess:
      return retryAttempt >= 1
        ? .success(items: FKBaseListMockFetch.sampleColors(count: 6))
        : .serverError(message: "Temporary failure")
    default:
      return .success(items: [])
    }
  }

  private func applyFetchOutcome(_ outcome: FKBaseListMockFetchOutcome, isPullRefresh: Bool) {
    if scenario.usesSkeletonPlaceholders, !isPullRefresh {
      endSkeletonPlaceholderLoading(reloadData: false)
    }

    switch outcome {
    case let .success(items):
      labels = items
      collectionView.reloadData()
      hideListEmptyState()
      if isPullRefresh {
        endPullToRefresh(success: true)
      } else {
        showToast("Loaded \(items.count) tiles")
      }
    case .empty:
      labels = []
      collectionView.reloadData()
      let empty = FKEmptyStateConfiguration.scenario(.noFavorites)
      syncListEmptyState(itemCount: 0, emptyConfiguration: empty)
      if isPullRefresh { endPullToRefresh(success: true) }
    case .noNetwork:
      labels = []
      collectionView.reloadData()
      syncListEmptyState(itemCount: 0, emptyConfiguration: .scenario(.noNetwork)) { [weak self] _ in
        self?.replayTapped()
      }
      if isPullRefresh { endPullToRefresh(success: false) }
    case .serverError:
      if isPullRefresh {
        endPullToRefresh(success: false)
        showToast("Refresh failed")
        return
      }
      labels = []
      collectionView.reloadData()
      presentErrorState(retryAttempt: retryCount)
    }
  }

  private func presentErrorState(retryAttempt: Int) {
    var error = FKEmptyStateConfiguration.scenario(.loadFailed)
    if scenario == .errorRetryThenSuccess, retryAttempt == 0 {
      error.description = "First attempt failed. Tap Retry to simulate a second request."
    }
    applyListEmptyState(error) { [weak self] _ in
      guard let self else { return }
      self.retryCount += 1
      if self.scenario.usesSkeletonPlaceholders {
        self.beginSkeletonPlaceholderLoading()
      }
      FKBaseListMockFetch.run(outcome: self.mockOutcome(for: self.scenario, retryAttempt: self.retryCount)) { outcome in
        self.applyFetchOutcome(outcome, isPullRefresh: false)
      }
    }
  }

  private static let tileColors: [UIColor] = [
    .systemBlue, .systemGreen, .systemOrange, .systemPurple,
    .systemTeal, .systemIndigo, .systemPink, .systemMint,
  ]

  private func tileColor(at index: Int) -> UIColor {
    Self.tileColors[index % Self.tileColors.count]
  }
}

extension FKBaseCollectionListScenarioExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if isShowingSkeletonPlaceholders { return skeletonPlaceholderCount }
    return labels.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if isShowingSkeletonPlaceholders {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: FKBusinessKitBase.ListSkeletonReuseIdentifier.collectionCell,
        for: indexPath
      ) as! FKSkeletonCollectionViewCell
      configureDefaultSkeletonCollectionCell(cell, at: indexPath.item)
      return cell
    }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.dataReuseId, for: indexPath)
    cell.contentView.backgroundColor = tileColor(at: indexPath.item)
    cell.contentView.layer.cornerRadius = 8
    cell.contentView.clipsToBounds = true
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let inset = layout.sectionInset.left + layout.sectionInset.right
    let spacing = layout.minimumInteritemSpacing
    let width = (collectionView.bounds.width - inset - spacing) / 2
    return CGSize(width: max(60, width), height: 72)
  }
}
