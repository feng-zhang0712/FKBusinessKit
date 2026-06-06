import FKCoreKit
import UIKit

/// Load-more footer lifecycle for scroll-based base controllers (``FKBaseTableViewController``, ``FKBaseCollectionViewController``).
public enum FKBaseLoadMoreState: Equatable {
  case idle
  case loading
  case completed
  case failed
}

/// Renamed to ``FKBaseLoadMoreState``; kept for source compatibility.
@available(*, deprecated, renamed: "FKBaseLoadMoreState")
public typealias FKBaseTableLoadMoreState = FKBaseLoadMoreState

/// A `FKBaseViewController` specialization centered on a single primary `UITableView`.
///
/// Responsibilities:
/// - Pins the table below ``tableViewTopLayoutAnchor`` (default: safe area top) and
///   ``UIView/keyboardLayoutGuide`` (iOS 15+) for keyboard avoidance.
/// - Keeps vertical bounce enabled for pull-to-refresh ergonomics (see ``disableScrollViewBounceByDefault``).
/// - Optionally wires ``FKRefreshControl`` pull and load-more footers via ``isPullToRefreshEnabled`` /
///   ``isLoadMoreEnabled``.
///
/// Data source and delegate are **not** implemented here; subclasses assign ``UITableView/dataSource``
/// and ``UITableView/delegate`` (and may use `UITableViewDiffableDataSource` independently).
@MainActor
open class FKBaseTableViewController: FKBaseViewController {

  // MARK: - Public surface

  /// Primary list view. Created with ``init(style:)`` / storyboard initializers.
  public let tableView: UITableView

  /// When `true`, installs ``UIScrollView/fk_addPullToRefresh(configuration:action:)`` during ``setupBindings()``.
  public var isPullToRefreshEnabled: Bool = false {
    didSet { refreshCoordinator.isPullToRefreshEnabled = isPullToRefreshEnabled }
  }

  /// When `true`, installs ``UIScrollView/fk_addLoadMore(configuration:action:)`` during ``setupBindings()``.
  public var isLoadMoreEnabled: Bool = false {
    didSet { refreshCoordinator.isLoadMoreEnabled = isLoadMoreEnabled }
  }

  /// Attached header control, if ``isPullToRefreshEnabled`` is `true` after ``setupBindings()``.
  public var pullToRefreshControl: FKRefreshControl? { refreshCoordinator.pullToRefreshControl }

  /// Attached footer control, if ``isLoadMoreEnabled`` is `true` after ``setupBindings()``.
  public var loadMoreControl: FKRefreshControl? { refreshCoordinator.loadMoreControl }

  /// High-level pagination hint for load-more UX (call ``markLoadMoreFinished()`` / ``markLoadMoreNoMoreData()`` from your fetch logic).
  public var loadMoreState: FKBaseLoadMoreState { refreshCoordinator.loadMoreState }

  private let refreshCoordinator = FKBaseRefreshCoordinator()

  // MARK: - Init

  /// Designated style-based initializer.
  public init(style: UITableView.Style = .plain) {
    self.tableView = UITableView(frame: .zero, style: style)
    super.init(nibName: nil, bundle: nil)
    commonTableControllerInit()
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.tableView = UITableView(frame: .zero, style: .plain)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonTableControllerInit()
  }

  public required init?(coder: NSCoder) {
    self.tableView = UITableView(frame: .zero, style: .plain)
    super.init(coder: coder)
    commonTableControllerInit()
  }

  private func commonTableControllerInit() {
    // Lists rely on vertical bounce for pull-to-refresh; do not inherit the global “disable all bounce” default.
    disableScrollViewBounceByDefault = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    refreshCoordinator.isPullToRefreshEnabled = isPullToRefreshEnabled
    refreshCoordinator.isLoadMoreEnabled = isLoadMoreEnabled
  }

  // MARK: - Lifecycle

  open override func setupUI() {
    super.setupUI()
    view.insertSubview(tableView, at: 0)
    configureTableView(tableView)
  }

  open override func setupConstraints() {
    super.setupConstraints()
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: tableViewTopLayoutAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
    ])
  }

  open override func setupBindings() {
    super.setupBindings()
    refreshCoordinator.installIfNeeded(on: tableView) { [weak self] in
      self?.performPullToRefresh()
    } loadMoreHandler: { [weak self] in
      self?.refreshCoordinator.handleLoadMoreInvoked {
        self?.performLoadMore()
      }
    }
    if let prefetching = self as? UITableViewDataSourcePrefetching {
      tableView.prefetchDataSource = prefetching
    } else {
      tableView.prefetchDataSource = nil
    }
  }

  // MARK: - Overridable configuration

  /// Top layout anchor for ``tableView``. Defaults to ``UIViewController/view``'s
  /// ``UIView/safeAreaLayoutGuide`` top.
  ///
  /// Override after adding chrome above the table (e.g. ``FKTabBarFilterHosting/embedStrip(_:in:topAnchor:fixedStripHeight:overlayHost:)``)
  /// so ``setupConstraints()`` pins the table below that view instead of the safe area.
  /// ``setupUI()`` runs before ``setupConstraints()``, so anchors from views added in ``setupUI()`` are valid here.
  open var tableViewTopLayoutAnchor: NSLayoutYAxisAnchor {
    view.safeAreaLayoutGuide.topAnchor
  }

  /// One-time table configuration (style is fixed by the initializer). Default enables self-sizing rows
  /// and separator behavior suitable for most apps.
  open func configureTableView(_ tableView: UITableView) {
    switch tableView.style {
    case .grouped, .insetGrouped:
      tableView.backgroundColor = .systemGroupedBackground
    default:
      tableView.backgroundColor = .systemBackground
    }
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.keyboardDismissMode = .onDrag
    if #available(iOS 15.0, *) {
      if tableView.style == .plain {
        tableView.sectionHeaderTopPadding = 0.0
      }
    }
    registerDefaultSkeletonTableCell()
  }

  /// Called when pull-to-refresh fires. Override to load the first page / reload.
  ///
  /// When finished, call ``endPullToRefresh(success:)`` (or ``FKRefreshControl`` APIs directly).
  open func performPullToRefresh() {
    endPullToRefresh(success: true)
  }

  /// Called when the load-more footer fires. Override to fetch the next page.
  ///
  /// When finished, call ``markLoadMoreFinished()`` or ``markLoadMoreNoMoreData()`` as appropriate.
  open func performLoadMore() {
    markLoadMoreFinished()
  }

  // MARK: - Public refresh helpers

  /// Ends the pull-to-refresh header using ``FKRefreshControl`` outcome helpers.
  public func endPullToRefresh(success: Bool) {
    refreshCoordinator.endPullToRefresh(success: success)
  }

  /// Marks a successful load-more cycle (more pages may exist).
  public func markLoadMoreFinished() {
    refreshCoordinator.markLoadMoreFinished()
  }

  /// Marks pagination as exhausted (disables further footer loading UX).
  public func markLoadMoreNoMoreData() {
    refreshCoordinator.markLoadMoreNoMoreData()
  }

  /// Marks load-more failure while keeping existing rows visible.
  public func markLoadMoreFailed(_ error: Error? = nil) {
    refreshCoordinator.markLoadMoreFailed(error)
  }

  /// Scrolls the table to the top using ``UIScrollView/fk_scrollToTop(animated:)``.
  public func scrollTableToTop(animated: Bool) {
    tableView.fk_scrollToTop(animated: animated)
  }
}
