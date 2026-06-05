import Foundation

/// Demo scenarios for ``FKBaseTableViewController`` / ``FKBaseCollectionViewController`` list presentation.
enum FKBaseListDemoScenario: String, CaseIterable {

  case initialLoadSuccess
  case initialLoadEmpty
  case initialLoadNoNetwork
  case initialLoadServerError
  case errorRetryThenSuccess
  case pullRefreshFailure
  case pullRefreshBecomesEmpty
  case emptyStateLoadingTransition

  var title: String {
    switch self {
    case .initialLoadSuccess: return "Initial load · success"
    case .initialLoadEmpty: return "Initial load · empty"
    case .initialLoadNoNetwork: return "Initial load · no network"
    case .initialLoadServerError: return "Initial load · server error"
    case .errorRetryThenSuccess: return "Error · retry succeeds"
    case .pullRefreshFailure: return "Pull to refresh · failure"
    case .pullRefreshBecomesEmpty: return "Pull to refresh · becomes empty"
    case .emptyStateLoadingTransition: return "FKEmptyState loading → empty"
    }
  }

  var subtitle: String {
    switch self {
    case .initialLoadSuccess:
      return "FKSkeleton placeholder rows, then populated list."
    case .initialLoadEmpty:
      return "Skeleton, then FKEmptyState empty overlay."
    case .initialLoadNoNetwork:
      return "Skeleton, then offline empty state with reload."
    case .initialLoadServerError:
      return "Skeleton, then error phase with mandatory retry."
    case .errorRetryThenSuccess:
      return "Starts in error; first retry fails, second succeeds."
    case .pullRefreshFailure:
      return "Keeps rows visible; refresh ends with error footer."
    case .pullRefreshBecomesEmpty:
      return "Refresh succeeds with zero items and empty overlay."
    case .emptyStateLoadingTransition:
      return "FKEmptyState loading spinner transitions to empty (no skeleton rows)."
    }
  }

  var usesPullToRefresh: Bool {
    switch self {
    case .pullRefreshFailure, .pullRefreshBecomesEmpty:
      return true
    default:
      return false
    }
  }

  var usesSkeletonPlaceholders: Bool {
    self != .emptyStateLoadingTransition
  }
}
