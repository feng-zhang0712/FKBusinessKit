#if canImport(UIKit)
import UIKit

/// Bridges nonisolated FKBusinessKit helpers to MainActor-isolated `UIDevice` / `UIScreen` APIs.
enum FKMainActorUIKitBridge {
  nonisolated static func systemVersion() -> String {
    executeOnMain { UIDevice.current.systemVersion }
  }

  nonisolated static func screenBoundsSize() -> CGSize {
    executeOnMain { UIScreen.main.bounds.size }
  }

  private nonisolated static func executeOnMain<T: Sendable>(_ body: @MainActor () -> T) -> T {
    if Thread.isMainThread {
      return MainActor.assumeIsolated(body)
    }
    return DispatchQueue.main.sync {
      MainActor.assumeIsolated(body)
    }
  }
}
#endif
