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
    var options = listPresentationOptions
    options.emptyConfiguration = FKEmptyStateConfiguration.scenario(.noSearchResult)
      .withTitle("No items")
      .withDescription("Try adjusting filters or check back later.")
    listPresentationOptions = options
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

  private func retryFromError() {
    retryCount += 1
    beginListLoadIfNeeded(isRefresh: true, currentItemCount: rows.count)
    FKBaseListMockFetch.run(outcome: mockOutcome(for: scenario, retryAttempt: retryCount)) { [weak self] outcome in
      self?.applyFetchOutcome(outcome, isPullRefresh: false)
    }
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
      // Alternative to skeleton rows: full-page FKEmptyState loading phase (not recommended for paginated lists).
      var loading = FKEmptyStateConfiguration(phase: .loading, type: .loading, title: "Loading items…")
      loading.content.loadingMessage = "Fetching the latest rows"
      applyListEmptyState(loading)
      FKBaseListMockFetch.run(outcome: .empty) { [weak self] _ in
        guard let self else { return }
        let empty = FKEmptyStateConfiguration.scenario(.noSearchResult)
          .withTitle("Nothing here yet")
          .withDescription("The request succeeded but returned no rows.")
        self.applyListEmptyState(empty)
      }
    case .errorRetryThenSuccess:
      rows = []
      tableView.reloadData()
      presentErrorState(retryAttempt: retryCount)
    default:
      beginListLoadIfNeeded(isRefresh: true, currentItemCount: rows.count)
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
    let preservedCount = rows.count
    let presentationOutcome = outcome.listPresentationOutcome(
      preservedItemCount: preservedCount,
      isPullRefresh: isPullRefresh
    )
    rows = outcome.rowsAfterApplying

    finishListLoadPresentation(
      outcome: presentationOutcome,
      isRefresh: isPullRefresh,
      retryHandler: { [weak self] _ in self?.retryFromError() }
    )
    reloadListContent()

    if isPullRefresh {
      endPullToRefresh(success: outcome.isRefreshSuccess)
      if !outcome.isRefreshSuccess {
        showToast("Refresh failed")
      }
    } else if case let .success(items) = outcome {
      showToast("Loaded \(items.count) rows")
    }
  }

  private func presentErrorState(retryAttempt: Int) {
    var error = FKEmptyStateConfiguration.scenario(.loadFailed)
    if scenario == .errorRetryThenSuccess, retryAttempt == 0 {
      error = error.withDescription("First attempt failed. Tap Retry to simulate a second request.")
    }
    applyListEmptyState(error) { [weak self] _ in
      self?.retryFromError()
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    listDataSourceRowCount(actualCount: rows.count)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isShowingSkeletonPlaceholders {
      return dequeueDefaultSkeletonTableCell(in: tableView, at: indexPath)
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    var config = cell.defaultContentConfiguration()
    config.text = rows[indexPath.row]
    cell.contentConfiguration = config
    return cell
  }
}
