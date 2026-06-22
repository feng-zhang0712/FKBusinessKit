import FKBusinessKit
import Foundation

enum FKBaseListMockFetchOutcome: Equatable {
  case success(items: [String])
  case empty
  case noNetwork
  case serverError(message: String)
}

extension FKBaseListMockFetchOutcome {

  /// Maps demo fetch results to ``FKBaseListPresentationOutcome`` using SACTrain-style rules.
  func listPresentationOutcome(preservedItemCount: Int, isPullRefresh: Bool) -> FKBaseListPresentationOutcome {
    switch self {
    case let .success(items):
      return .content(itemCount: items.count)
    case .empty:
      return .empty
    case .noNetwork:
      if preservedItemCount > 0, isPullRefresh {
        return .content(itemCount: preservedItemCount)
      }
      return .failed(kind: .transport, message: nil)
    case let .serverError(message):
      if preservedItemCount > 0, isPullRefresh {
        return .content(itemCount: preservedItemCount)
      }
      return .failed(kind: .business, message: message)
    }
  }

  var rowsAfterApplying: [String] {
    switch self {
    case let .success(items):
      return items
    case .empty, .noNetwork, .serverError:
      return []
    }
  }

  var isRefreshSuccess: Bool {
    switch self {
    case .success, .empty:
      return true
    case .noNetwork, .serverError:
      return false
    }
  }
}

enum FKBaseListMockFetch {

  static func sampleItems(prefix: String, count: Int) -> [String] {
    (0..<count).map { "\(prefix) \($0 + 1)" }
  }

  static func sampleColors(count: Int) -> [String] {
    let palette = ["Blue", "Green", "Orange", "Purple", "Teal", "Indigo", "Pink", "Mint"]
    return (0..<count).map { palette[$0 % palette.count] + " tile \($0 + 1)" }
  }

  /// Simulates network latency on the main queue.
  static func run(
    delay: TimeInterval = 1.1,
    outcome: FKBaseListMockFetchOutcome,
    completion: @escaping @MainActor (FKBaseListMockFetchOutcome) -> Void
  ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      completion(outcome)
    }
  }
}
