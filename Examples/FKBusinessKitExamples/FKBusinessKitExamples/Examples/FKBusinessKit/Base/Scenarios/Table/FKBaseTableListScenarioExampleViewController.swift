import FKBusinessKit
import FKUIKit
import UIKit

/// Table list scenario driven by ``FKBaseListDemoScenario`` (skeleton, empty, error, refresh).
final class FKBaseTableListScenarioExampleViewController: FKBusinessKitBase.TableViewController, UITableViewDataSource {

  private let scenario: FKBaseListDemoScenario
  private var rows: [String] = []
  private var retryCount = 0

  init(scenario: FKBaseListDemoScenario) {
    self.scenario = scenario
    super.init(style: .insetGrouped)
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

  override func configureTableView(_ tableView: UITableView) {
    super.configureTableView(tableView)
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.rowHeight = scenario.usesSkeletonPlaceholders ? 96 : 44
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
    rows = []
    hideListEmptyState(animated: false)
    tableView.reloadData()
    startInitialFlow()
  }

  private func startInitialFlow() {
    switch scenario {
    case .pullRefreshFailure, .pullRefreshBecomesEmpty:
      FKBaseListMockFetch.run(
        delay: 0.4,
        outcome: .success(items: FKBaseListMockFetch.sampleItems(prefix: "Row", count: 10))
      ) { [weak self] outcome in
        self?.applyFetchOutcome(outcome, isPullRefresh: false)
      }
    case .emptyStateLoadingTransition:
      var loading = FKEmptyStateConfiguration(phase: .loading, type: .loading, title: "Loading items…")
      loading.loadingMessage = "Fetching the latest rows"
      applyListEmptyState(loading)
      FKBaseListMockFetch.run(outcome: .empty) { [weak self] _ in
        guard let self else { return }
        var empty = FKEmptyStateConfiguration.scenario(.noSearchResult)
        empty.title = "Nothing here yet"
        empty.description = "The request succeeded but returned no rows."
        self.applyListEmptyState(empty)
      }
    case .errorRetryThenSuccess:
      rows = []
      tableView.reloadData()
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
      return .success(items: FKBaseListMockFetch.sampleItems(prefix: "Row", count: 12))
    case .initialLoadEmpty:
      return .empty
    case .initialLoadNoNetwork:
      return .noNetwork
    case .initialLoadServerError:
      return .serverError(message: "HTTP 500 — internal error")
    case .errorRetryThenSuccess:
      return retryAttempt >= 1
        ? .success(items: FKBaseListMockFetch.sampleItems(prefix: "Row", count: 8))
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
      rows = items
      tableView.reloadData()
      hideListEmptyState()
      if isPullRefresh {
        endPullToRefresh(success: true)
      } else {
        showToast("Loaded \(items.count) rows")
      }
    case .empty:
      rows = []
      tableView.reloadData()
      var empty = FKEmptyStateConfiguration.scenario(.noSearchResult)
      empty.title = "No items"
      empty.description = "Try adjusting filters or check back later."
      syncListEmptyState(itemCount: 0, emptyConfiguration: empty)
      if isPullRefresh { endPullToRefresh(success: true) }
    case .noNetwork:
      rows = []
      tableView.reloadData()
      let offline = FKEmptyStateConfiguration.scenario(.noNetwork)
      syncListEmptyState(itemCount: 0, emptyConfiguration: offline) { [weak self] _ in
        self?.replayTapped()
      }
      if isPullRefresh { endPullToRefresh(success: false) }
    case .serverError:
      if isPullRefresh {
        endPullToRefresh(success: false)
        showToast("Refresh failed")
        return
      }
      rows = []
      tableView.reloadData()
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

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isShowingSkeletonPlaceholders { return skeletonPlaceholderCount }
    return rows.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isShowingSkeletonPlaceholders {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: FKBusinessKitBase.ListSkeletonReuseIdentifier.tableCell,
        for: indexPath
      ) as! FKSkeletonTableViewCell
      configureDefaultSkeletonTableCell(cell, at: indexPath.row)
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var config = cell.defaultContentConfiguration()
    config.text = rows[indexPath.row]
    cell.contentConfiguration = config
    return cell
  }
}
