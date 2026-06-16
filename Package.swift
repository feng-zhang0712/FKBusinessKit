// swift-tools-version: 6.0

import PackageDescription

/// Lowest FKKit tag this package compiles against (ListKit v4, Widgets, TabBarFilter sheet APIs).
/// Raise when adopting APIs from a newer FKKit release; keep `FKBusinessKit.podspec` FKCoreKit/FKUIKit deps in sync.
private let fkKitMinimumVersion = Version(0, 71, 0)

let package = Package(
  name: "FKBusinessKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "FKBusinessKit", targets: ["FKBusinessKit"]),
  ],
  dependencies: [
    // Resolves to the highest FKKit version compatible with `fkKitMinimumVersion` and the app’s graph (< 1.0.0).
    // Do not use `branch:` or `exact:` here for published releases.
    .package(
      url: "https://github.com/feng-zhang0712/FKKit.git",
      .upToNextMajor(from: fkKitMinimumVersion)
    ),
  ],
  targets: [
    .target(
      name: "FKBusinessKit",
      dependencies: [
        .product(name: "FKCoreKit", package: "FKKit"),
        .product(name: "FKUIKit", package: "FKKit"),
      ],
      path: "Sources/FKBusinessKit",
      exclude: [
        "README.md",
        "Components/TabBarFilter/README.md",
        "Components/Base/README.md",
        "Components/CellKit/README.md",
      ]
    ),
  ],
  /// Swift 6 language mode for all targets (region isolation; aligns with strict concurrency work).
  ///
  /// Default MainActor isolation is **not** enabled at the package level (see CI `SWIFT_STRICT_CONCURRENCY=complete`).
  swiftLanguageModes: [.v6]
)
