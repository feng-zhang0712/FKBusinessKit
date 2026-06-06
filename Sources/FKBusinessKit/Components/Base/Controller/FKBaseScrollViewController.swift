import FKUIKit
import UIKit

/// A ``FKBaseViewController`` specialization centered on a single primary ``UIScrollView`` and a
/// scrollable ``contentView``.
///
/// Responsibilities:
/// - Pins the scroll view to the safe area and ``UIView/keyboardLayoutGuide`` (iOS 15+) for keyboard avoidance.
/// - Scrolls the current first responder into view when the keyboard frame changes (via ``FKBaseViewController/keyboardFocusScrollView``).
/// - Wires the standard Auto Layout scroll-content pattern (``contentView`` width tracks the scroll view frame).
/// - Keeps vertical bounce enabled for overflow content (see ``disableScrollViewBounceByDefault``).
/// - Optionally installs pull-to-refresh via ``isPullToRefreshEnabled``.
///
/// Add subviews inside ``contentView`` (not directly on ``scrollView``). Load-more is intentionally omitted —
/// use ``FKBaseTableViewController`` / ``FKBaseCollectionViewController`` for paginated lists.
@MainActor
open class FKBaseScrollViewController: FKBaseViewController {

  // MARK: - Public surface

  /// Primary scroll view.
  public let scrollView = UIScrollView()

  /// Content root whose height defines the scrollable area. Subclasses attach custom subviews here.
  public let contentView = UIView()

  /// Insets applied around ``contentView`` inside ``scrollView``'s content layout guide.
  public var contentLayoutMargins: UIEdgeInsets = .zero {
    didSet { applyContentLayoutMarginsIfInstalled() }
  }

  /// When `true`, installs ``UIScrollView/fk_addPullToRefresh(configuration:action:)`` during ``setupBindings()``.
  public var isPullToRefreshEnabled: Bool = false {
    didSet { refreshCoordinator.isPullToRefreshEnabled = isPullToRefreshEnabled }
  }

  /// Attached header control, if ``isPullToRefreshEnabled`` is `true` after ``setupBindings()``.
  public var pullToRefreshControl: FKRefreshControl? { refreshCoordinator.pullToRefreshControl }

  open override var keyboardFocusScrollView: UIScrollView? { scrollView }

  private let refreshCoordinator = FKBaseRefreshCoordinator()

  private var contentLayoutConstraints: [NSLayoutConstraint] = []

  // MARK: - Init

  public override init() {
    super.init()
    commonScrollControllerInit()
  }

  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    commonScrollControllerInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonScrollControllerInit()
  }

  private func commonScrollControllerInit() {
    disableScrollViewBounceByDefault = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    refreshCoordinator.isPullToRefreshEnabled = isPullToRefreshEnabled
  }

  // MARK: - Lifecycle

  open override func setupUI() {
    super.setupUI()
    view.insertSubview(scrollView, at: 0)
    scrollView.addSubview(contentView)
    configureScrollView(scrollView)
  }

  open override func setupConstraints() {
    super.setupConstraints()
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
    ])
    installContentLayoutConstraints()
  }

  open override func setupBindings() {
    super.setupBindings()
    refreshCoordinator.installIfNeeded(on: scrollView) { [weak self] in
      self?.performPullToRefresh()
    }
  }

  // MARK: - Overridable configuration

  /// One-time scroll view configuration. Default enables vertical bounce and drag-to-dismiss keyboard.
  open func configureScrollView(_ scrollView: UIScrollView) {
    scrollView.backgroundColor = .systemBackground
    scrollView.alwaysBounceVertical = true
    scrollView.keyboardDismissMode = .onDrag
    scrollView.contentInsetAdjustmentBehavior = .never
  }

  /// Called when pull-to-refresh fires. Override to reload page content.
  ///
  /// When finished, call ``endPullToRefresh(success:)`` (or ``FKRefreshControl`` APIs directly).
  open func performPullToRefresh() {
    endPullToRefresh(success: true)
  }

  // MARK: - Public helpers

  /// Ends the pull-to-refresh header using ``FKRefreshControl`` outcome helpers.
  public func endPullToRefresh(success: Bool) {
    refreshCoordinator.endPullToRefresh(success: success)
  }

  /// Scrolls to the top using ``UIScrollView/fk_scrollToTop(animated:)``.
  public func scrollToTop(animated: Bool) {
    scrollView.fk_scrollToTop(animated: animated)
  }

  // MARK: - Content layout

  private func installContentLayoutConstraints() {
    NSLayoutConstraint.deactivate(contentLayoutConstraints)
    contentLayoutConstraints.removeAll()

    let margins = contentLayoutMargins
    contentLayoutConstraints = [
      contentView.topAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.topAnchor,
        constant: margins.top
      ),
      contentView.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor,
        constant: margins.left
      ),
      contentView.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor,
        constant: -margins.right
      ),
      contentView.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor,
        constant: -margins.bottom
      ),
      contentView.widthAnchor.constraint(
        equalTo: scrollView.frameLayoutGuide.widthAnchor,
        constant: -(margins.left + margins.right)
      ),
    ]
    NSLayoutConstraint.activate(contentLayoutConstraints)
  }

  private func applyContentLayoutMarginsIfInstalled() {
    guard !contentLayoutConstraints.isEmpty else { return }
    installContentLayoutConstraints()
  }
}
