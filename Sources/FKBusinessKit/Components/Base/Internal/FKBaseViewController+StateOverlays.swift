import FKUIKit
import UIKit

extension FKBaseViewController {

  /// Performs one-time setup for the base controller’s shared UI and bindings.
  ///
  /// This adds the loading indicator and empty-state overlay, then wires keyboard dismissal so all
  /// derived controllers inherit the same default behavior without duplicating boilerplate.
  func performBaseSetupIfNeeded() {
    guard !hasPerformedBaseSetup else { return }
    hasPerformedBaseSetup = true

    view.backgroundColor = .systemBackground
    setupLoadingView()
    setupStateViews()
    composite.tapToDismissKeyboard.bindIfNeeded(to: self)
  }

  /// Pushes the current public configuration into the shared composition bucket.
  ///
  /// Call this after the controller’s properties are finalized so the composition layer can mirror the
  /// latest keyboard, navigation chrome, and interactive pop settings.
  func syncCompositeConfiguration() {
    composite.tapToDismissKeyboard.isEnabled = dismissKeyboardOnTapEnabled
    composite.disablesScrollBounceRecursivelyByDefault = disableScrollViewBounceByDefault
    composite.interactivePopGesture.disablesInteractivePopGesture = disablesInteractivePopGesture
    composite.navigationChrome.visibility = navigationBarVisibility
    composite.navigationChrome.style = navigationBarStyle
    composite.navigationChrome.prefersLargeTitlesWhileVisible = prefersLargeTitlesWhileVisible
    composite.keyboard.isEnabled = keyboardObservationEnabled
  }

  /// Connects composition callbacks back to overridable controller hooks exactly once.
  ///
  /// The wiring is intentionally lazy so subclasses can finish configuring closures before the first
  /// `viewDidLoad` execution triggers them.
  func wireCompositeCallbacksIfNeeded() {
    guard composite.keyboard.onWillChangeFrame == nil else { return }
    composite.keyboard.onWillChangeFrame = { [weak self] frame, duration, curve in
      self?.keyboardWillChange(to: frame, duration: duration, curve: curve)
    }
    composite.keyboard.onWillHide = { [weak self] duration, curve in
      self?.keyboardWillHide(duration: duration, curve: curve)
    }
    composite.appearanceState.onFirstAppearance = { [weak self] animated in
      guard let self else { return }
      self.loadInitialContent()
      self.viewDidAppearForTheFirstTime(animated)
    }
  }

  /// Emits lifecycle diagnostics to the optional handler and debug logger.
  func logLifecycleEvent(_ event: String) {
    let metadata: [String: String] = ["controller": String(describing: type(of: self))]
    logHandler?(event, metadata)
    if debugLifecycleLoggingEnabled {
      FKLogger.shared.debug("FKBaseViewController.\(event)", metadata: metadata)
    }
  }

  // MARK: - State overlay layout

  /// Pins ``emptyStateView`` below ``stateOverlayTopLayoutAnchor``. Called from ``setupConstraints()``.
  func installStateOverlayConstraintsIfNeeded() {
    guard !hasInstalledStateOverlayConstraints else { return }
    hasInstalledStateOverlayConstraints = true
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: stateOverlayTopLayoutAnchor, constant: stateOverlayTopInset),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  // MARK: - Private setup

  /// Adds the loading indicator used by `showLoading()` / `hideLoading()` (below ``setupUI()`` content).
  private func setupLoadingView() {
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.hidesWhenStopped = true
    loadingView.isHidden = true
    view.insertSubview(loadingView, at: 0)
    NSLayoutConstraint.activate([
      loadingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      loadingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
  }

  /// Adds the shared empty/error overlay view (below ``setupUI()`` content; constraints in ``setupConstraints()``).
  private func setupStateViews() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateView.isHidden = true
    emptyStateView.alpha = 0
    view.insertSubview(emptyStateView, at: 0)
  }

  /// Presents the shared ``emptyStateView`` overlay.
  ///
  /// Matches ``UIView/fk_applyEmptyState`` visibility (`alpha` + `isHidden`) but keeps the view **below**
  /// subviews added in ``setupUI()`` so fixed chrome stays interactive.
  func revealStateOverlay(
    _ configuration: FKEmptyStateConfiguration,
    actionHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    emptyStateView.actionHandler = actionHandler
    emptyStateView.apply(configuration)
    emptyStateView.isHidden = false
    emptyStateView.alpha = 1
  }

  /// Hides the shared ``emptyStateView`` overlay and clears any action handler.
  func concealStateOverlay() {
    emptyStateView.isHidden = true
    emptyStateView.alpha = 0
    emptyStateView.actionHandler = nil
  }
}
