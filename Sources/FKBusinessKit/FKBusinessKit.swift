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

/// Stable entry point for Base controller types when legacy copies may still be visible through **FKUIKit** (FKKit ≤ 0.60).
public enum FKBusinessKitBase {
  public typealias ViewController = FKBaseViewController
  public typealias TableViewController = FKBaseTableViewController
  public typealias CollectionViewController = FKBaseCollectionViewController
  public typealias SearchIntegration = FKBaseSearchIntegration
  public typealias ListSkeletonReuseIdentifier = FKBaseListSkeletonReuseIdentifier
  public typealias ListSkeletonLayout = FKBaseListSkeletonLayout
  public typealias LoadMoreState = FKBaseLoadMoreState
  public typealias ViewControllerComposite = FKViewControllerComposite
  public typealias ViewControllerBuildPhases = FKViewControllerBuildPhases
  public typealias ViewControllerCompositeHosting = FKViewControllerCompositeHosting
  public typealias ViewControllerTraitChangeHandling = FKViewControllerTraitChangeHandling
}
