@_exported import FKCoreKit
@_exported import FKUIKit

/// Marker for the **FKBusinessKit** Swift package (built on FKKit).
///
/// `import FKBusinessKit` re-exports **FKCoreKit** and **FKUIKit**.
/// TabBarFilter and future components live under `Sources/FKBusinessKit/Components/`.
public enum FKBusinessKitModule {
  /// Package module name (for diagnostics and logging).
  public static let name = "FKBusinessKit"
}
