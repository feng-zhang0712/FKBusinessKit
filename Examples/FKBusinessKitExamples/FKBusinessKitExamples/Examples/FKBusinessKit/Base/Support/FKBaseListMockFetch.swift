import Foundation

enum FKBaseListMockFetchOutcome: Equatable {
  case success(items: [String])
  case empty
  case noNetwork
  case serverError(message: String)
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
