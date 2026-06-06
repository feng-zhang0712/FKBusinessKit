import FKCoreKit
import UIKit

/// A ``FKBaseViewController`` specialization centered on a single primary ``UICollectionView``.
///
/// Mirrors ``FKBaseTableViewController``: safe-area + keyboard layout pinning, optional ``FKRefreshControl``
/// header/footer, and prefetch wiring when the subclass conforms to ``UICollectionViewDataSourcePrefetching``.
///
/// Supply a layout via ``init(collectionViewLayout:)``, or use ``init()`` / storyboard initializers for the default vertical flow layout.
/// Data source and delegate are **not** implemented here.
@MainActor
open class FKBaseCollectionViewController: FKBaseViewController {

  public let collectionView: UICollectionView

  public var isPullToRefreshEnabled: Bool = false {
    didSet { listRefresh.isPullToRefreshEnabled = isPullToRefreshEnabled }
  }

  public var isLoadMoreEnabled: Bool = false {
    didSet { listRefresh.isLoadMoreEnabled = isLoadMoreEnabled }
  }

  public var pullToRefreshControl: FKRefreshControl? { listRefresh.pullToRefreshControl }

  public var loadMoreControl: FKRefreshControl? { listRefresh.loadMoreControl }

  public var loadMoreState: FKBaseLoadMoreState { listRefresh.loadMoreState }

  /// Flow layout cast when the controller was created with ``UICollectionViewFlowLayout`` (including the default).
  public var flowLayout: UICollectionViewFlowLayout? {
    collectionView.collectionViewLayout as? UICollectionViewFlowLayout
  }

  private let listRefresh = FKBaseListRefreshCoordinator()

  // MARK: - Init

  /// Creates the controller with the given collection view layout.
  public init(collectionViewLayout: UICollectionViewLayout) {
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    super.init(nibName: nil, bundle: nil)
    commonCollectionControllerInit()
  }

  /// Creates the controller with ``makeDefaultFlowLayout()``.
  public override init() {
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeDefaultFlowLayout())
    super.init()
    commonCollectionControllerInit()
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeDefaultFlowLayout())
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonCollectionControllerInit()
  }

  public required init?(coder: NSCoder) {
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeDefaultFlowLayout())
    super.init(coder: coder)
    commonCollectionControllerInit()
  }

  private func commonCollectionControllerInit() {
    disableScrollViewBounceByDefault = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    listRefresh.isPullToRefreshEnabled = isPullToRefreshEnabled
    listRefresh.isLoadMoreEnabled = isLoadMoreEnabled
  }

  /// Default flow layout: vertical scrolling with estimated sizing-friendly defaults.
  open class func makeDefaultFlowLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8.0
    layout.minimumInteritemSpacing = 8.0
    layout.sectionInset = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    return layout
  }

  // MARK: - Lifecycle

  open override func setupUI() {
    super.setupUI()
    view.insertSubview(collectionView, at: 0)
    configureCollectionView(collectionView)
  }

  open override func setupConstraints() {
    super.setupConstraints()
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
    ])
  }

  open override func setupBindings() {
    super.setupBindings()
    listRefresh.installIfNeeded(on: collectionView) { [weak self] in
      self?.performPullToRefresh()
    } loadMoreHandler: { [weak self] in
      self?.listRefresh.handleLoadMoreInvoked {
        self?.performLoadMore()
      }
    }
    if let prefetching = self as? UICollectionViewDataSourcePrefetching {
      collectionView.prefetchDataSource = prefetching
    } else {
      collectionView.prefetchDataSource = nil
    }
  }

  // MARK: - Configuration

  open func configureCollectionView(_ collectionView: UICollectionView) {
    collectionView.backgroundColor = .systemBackground
    collectionView.keyboardDismissMode = .onDrag
    collectionView.alwaysBounceVertical = true
    registerDefaultSkeletonCollectionCell()
  }

  open func performPullToRefresh() {
    endPullToRefresh(success: true)
  }

  open func performLoadMore() {
    markLoadMoreFinished()
  }

  // MARK: - Refresh helpers

  public func endPullToRefresh(success: Bool) {
    listRefresh.endPullToRefresh(success: success)
  }

  public func markLoadMoreFinished() {
    listRefresh.markLoadMoreFinished()
  }

  public func markLoadMoreNoMoreData() {
    listRefresh.markLoadMoreNoMoreData()
  }

  public func markLoadMoreFailed(_ error: Error? = nil) {
    listRefresh.markLoadMoreFailed(error)
  }

  public func scrollCollectionToTop(animated: Bool) {
    collectionView.fk_scrollToTop(animated: animated)
  }
}
