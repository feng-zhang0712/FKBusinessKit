import FKUIKit
import UIKit

/// Shared begin/finish orchestration for ``FKBaseTableViewController`` and ``FKBaseCollectionViewController``.
@MainActor
public enum FKBaseListPresentationCoordinator {

  /// Starts skeleton placeholders when a first-page refresh begins against an empty list.
  public static func beginListLoadIfNeeded(
    isRefresh: Bool,
    currentItemCount: Int,
    options: FKBaseListPresentationOptions,
    isShowingSkeletonPlaceholders: Bool,
    beginSkeleton: () -> Void
  ) {
    guard isRefresh, currentItemCount == 0, options.usesSkeletonOnInitialLoad else { return }
    guard !isShowingSkeletonPlaceholders else { return }
    beginSkeleton()
  }

  /// Ends skeleton placeholders and updates host empty/error overlays. Does **not** end pull-to-refresh or load-more.
  public static func finishListLoadPresentation(
    outcome: FKBaseListPresentationOutcome,
    options: FKBaseListPresentationOptions,
    applyEmptyState: (FKEmptyStateConfiguration, ((FKEmptyStateAction) -> Void)?) -> Void,
    syncEmptyState: (FKEmptyStateConfiguration, ((FKEmptyStateAction) -> Void)?) -> Void,
    hideEmptyState: () -> Void,
    retryHandler: ((FKEmptyStateAction) -> Void)? = nil
  ) {
    let animated = options.animatesEmptyState

    switch outcome {
    case .content:
      hideEmptyState()

    case .empty:
      syncEmptyState(options.emptyConfiguration, retryHandler)

    case let .failed(kind, message):
      let itemCount = itemCountForPresentationOutcome(outcome)
      guard itemCount == 0 else {
        hideEmptyState()
        return
      }
      var configuration = kind == .transport
        ? options.networkErrorConfiguration
        : options.errorConfiguration
      if let message, !message.isEmpty, kind == .business {
        configuration = configuration.withDescription(message)
      }
      configuration.phase = .error
      applyEmptyState(configuration, retryHandler)

    case .sessionExpired:
      let itemCount = itemCountForPresentationOutcome(outcome)
      guard itemCount == 0 else {
        hideEmptyState()
        return
      }
      var configuration = options.sessionExpiredConfiguration
      configuration.phase = .error
      applyEmptyState(configuration, retryHandler)
    }
  }

  /// Item count implied by `outcome` for failed/session branches (`.content` only carries a count).
  public static func itemCountForPresentationOutcome(_ outcome: FKBaseListPresentationOutcome) -> Int {
    switch outcome {
    case let .content(count): return count
    case .empty, .failed, .sessionExpired: return 0
    }
  }
}
