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
  dependencies: [
    // TabBarFilter needs FKUIKit SheetPresentation — raise minimum after the next FKKit release (e.g. `from: "0.55.0"`).
    .package(url: "https://github.com/feng-zhang0712/FKKit.git", from: "0.54.0"),
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
      ]
    ),
  ],
  /// Swift 6 language mode for all targets (region isolation; aligns with strict concurrency work).
  ///
  /// Default MainActor isolation is **not** enabled at the package level (see CI `SWIFT_STRICT_CONCURRENCY=complete`).
  swiftLanguageModes: [.v6]
)
