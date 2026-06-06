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

  // MARK: - Private setup

  /// Adds and constrains the loading indicator used by `showLoading()` / `hideLoading()`.
  private func setupLoadingView() {
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.hidesWhenStopped = true
    loadingView.isHidden = true
    view.addSubview(loadingView)
    NSLayoutConstraint.activate([
      loadingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      loadingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
  }

  /// Adds and constrains the shared empty/error overlay view.
  private func setupStateViews() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateView.isHidden = true
    view.addSubview(emptyStateView)

    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
}
