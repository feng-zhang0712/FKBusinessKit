// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "FKBusinessKit",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "FKBusinessKit", targets: ["FKBusinessKit"]),
  ],
  targets: [
    .target(
      name: "FKBusinessKit",
      path: "Sources/FKBusinessKit",
      exclude: [
        "README.md",
      ]
    ),
    .testTarget(
      name: "FKBusinessKitTests",
      dependencies: ["FKBusinessKit"],
      path: "Tests/FKBusinessKitTests"
    ),
  ],
  /// Swift 6 language mode for all targets (region isolation; aligns with strict concurrency work).
  ///
  /// Default MainActor isolation is **not** enabled at the package level: ``FKBusinessKit`` mixes background-safe
  /// analytics and lifecycle code with UI helpers; forcing module-wide ``MainActor`` would fight that split.
  /// UI-heavy APIs rely on UIKit’s own isolation plus explicit annotations instead (see CI strict concurrency).
  swiftLanguageModes: [.v6]
)
