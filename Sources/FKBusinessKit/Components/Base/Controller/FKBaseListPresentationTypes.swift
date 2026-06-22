import FKUIKit
import Foundation

// MARK: - Phase

/// High-level list presentation phase for diagnostics and logging.
public enum FKBaseListPresentationPhase: Sendable, Equatable {
  /// First load with no displayable rows yet (skeleton or loading empty state).
  case initialLoading
  /// At least one row is visible.
  case content
  /// Request succeeded and the list is intentionally empty.
  case empty
  /// Request failed with no cached rows to show.
  case error
  /// Pull-to-refresh in progress while prior content remains visible.
  case refreshing
  /// Load-more footer in progress while prior pages remain visible.
  case loadingNextPage
}

// MARK: - Outcome

/// Gateway-agnostic list load result consumed by ``FKBaseTableViewController/finishListLoadPresentation(outcome:isRefresh:retryHandler:)``.
public enum FKBaseListPresentationOutcome: Equatable, Sendable {
  /// Rows are available for display.
  case content(itemCount: Int)
  /// Request succeeded with an empty list (business or filtered empty).
  case empty
  /// Request failed. `kind` selects the error preset; `message` may override business descriptions.
  case failed(kind: FKBaseListFailureKind, message: String?)
  /// Session expired or account required.
  case sessionExpired
}

/// Failure category for ``FKBaseListPresentationOutcome/failed(kind:message:)``.
public enum FKBaseListFailureKind: Equatable, Sendable {
  case transport
  case business
}

// MARK: - Options

/// Skeleton and empty/error presentation policy for list base controllers.
public struct FKBaseListPresentationOptions {
  /// Shows skeleton placeholder rows on first-page refresh when the list is empty.
  public var usesSkeletonOnInitialLoad: Bool
  /// Skeleton placeholder row count while ``FKBaseTableViewController/isShowingSkeletonPlaceholders`` is `true`.
  public var skeletonPlaceholderCount: Int
  /// Business-empty configuration (`outcome == .empty`).
  public var emptyConfiguration: FKEmptyStateConfiguration
  /// General load failure (`failed(.business, …)`).
  public var errorConfiguration: FKEmptyStateConfiguration
  /// Network unavailable (`failed(.transport, …)`).
  public var networkErrorConfiguration: FKEmptyStateConfiguration
  /// Session expired (`sessionExpired`).
  public var sessionExpiredConfiguration: FKEmptyStateConfiguration
  /// Whether empty/error overlay transitions animate.
  public var animatesEmptyState: Bool

  public init(
    usesSkeletonOnInitialLoad: Bool = true,
    skeletonPlaceholderCount: Int = 8,
    emptyConfiguration: FKEmptyStateConfiguration = FKBaseListPresentationDefaults.empty,
    errorConfiguration: FKEmptyStateConfiguration = FKBaseListPresentationDefaults.loadFailed,
    networkErrorConfiguration: FKEmptyStateConfiguration = FKBaseListPresentationDefaults.noNetwork,
    sessionExpiredConfiguration: FKEmptyStateConfiguration = FKBaseListPresentationDefaults.sessionExpired,
    animatesEmptyState: Bool = false
  ) {
    self.usesSkeletonOnInitialLoad = usesSkeletonOnInitialLoad
    self.skeletonPlaceholderCount = max(1, skeletonPlaceholderCount)
    self.emptyConfiguration = emptyConfiguration
    self.errorConfiguration = errorConfiguration
    self.networkErrorConfiguration = networkErrorConfiguration
    self.sessionExpiredConfiguration = sessionExpiredConfiguration
    self.animatesEmptyState = animatesEmptyState
  }
}

/// Built-in empty/error presets; override per screen via ``FKBaseListPresentationOptions``.
public enum FKBaseListPresentationDefaults {
  public static var empty: FKEmptyStateConfiguration {
    FKEmptyStateConfiguration.scenario(.noSearchResult)
  }

  public static var loadFailed: FKEmptyStateConfiguration {
    FKEmptyStateConfiguration.scenario(.loadFailed)
  }

  public static var noNetwork: FKEmptyStateConfiguration {
    FKEmptyStateConfiguration.scenario(.noNetwork)
  }

  public static var sessionExpired: FKEmptyStateConfiguration {
    FKEmptyStateConfiguration.scenario(.notLoggedIn)
  }
}
