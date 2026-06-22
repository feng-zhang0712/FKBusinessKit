# FKBusinessKit

[![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Version](https://img.shields.io/badge/version-0.8.0-blue.svg)](https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.8.0)
[![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg)](https://swift.org/)
[![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-ee3322.svg)](https://cocoapods.org/)
[![CI](https://github.com/feng-zhang0712/FKBusinessKit/actions/workflows/ci.yml/badge.svg)](https://github.com/feng-zhang0712/FKBusinessKit/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Module Structure](#module-structure)
- [Requirements](#requirements)
- [FKKit dependency & versions](#fkit-dependency--versions)
- [Installation (SPM)](#installation-spm)
- [Installation (CocoaPods)](#installation-cocoapods)
- [Usage](#usage)
- [Contributing](#contributing)
- [Support](#support)
- [Security](#security)
- [Branching & Collaboration (Recommended)](#branching--collaboration-recommended)
- [License](#license)
- [Changelog](#changelog)

## Overview
FKBusinessKit is an **iOS** Swift package for business-oriented and composite components, built on **[FKKit](https://github.com/feng-zhang0712/FKKit)** (`FKCoreKit`, `FKUIKit`).

It is distributed via **Swift Package Manager (SPM)** and **CocoaPods**. `import FKBusinessKit` re-exports **FKCoreKit** and **FKUIKit** (see `Sources/FKBusinessKit/FKBusinessKit.swift`).

> **Note:** Legacy business infrastructure APIs (version, track, i18n, lifecycle, deeplink, utils) previously sketched here now live under **FKKit → `FKCoreKit/BusinessKit`**. This repository is the home for **new** FKBusinessKit components going forward.

## Features
- Pure Swift implementation (Swift 6 language mode in package settings).
- **iOS-only** — `platforms: [.iOS(.v15)]` in `Package.swift`.
- **`Base`** — inheritance-friendly view controller bases and optional composition layer ([component README](Sources/FKBusinessKit/Components/Base/README.md)).
- **`TabBarFilter`** — anchored filter strip with built-in panel kinds and custom panel support ([component README](Sources/FKBusinessKit/Components/TabBarFilter/README.md)).
- **`CellKit`** — business list and collection cells with ListKit registration glue ([component README](Sources/FKBusinessKit/Components/CellKit/README.md)).
- **Widgets integration** — compose FKUIKit Widgets with Base/TabBarFilter/CellKit ([design fragment 中文](docs/FKWidgets-Integration_DESIGN.md)).
- Depends on **FKCoreKit** and **FKUIKit** (FKKit `0.71.0+`, see [FKKit dependency & versions](#fkit-dependency--versions)).
- GitHub Actions CI: builds on **iOS Simulator**.
- Example app under [`Examples/FKBusinessKitExamples`](Examples/FKBusinessKitExamples).

## Module Structure

```text
FKBusinessKit/
├─ Package.swift
├─ FKBusinessKit.podspec
├─ scripts/
├─ docs/
│  ├─ FKWidgets-Integration_DESIGN.md
│  └─ FKCellKit_DESIGN.md
├─ Sources/
│  └─ FKBusinessKit/
│     ├─ FKBusinessKit.swift    # Module marker (extend with new components here)
│     ├─ Components/            # Base · TabBarFilter · CellKit
│     └─ README.md
└─ Examples/
   └─ FKBusinessKitExamples/
```

## Requirements
- **iOS 15.0+**
- Swift **6.0+** / **Xcode 16.2+**
- **[FKKit](https://github.com/feng-zhang0712/FKKit)** `0.71.0+` — resolved transitively when you depend on **FKBusinessKit** (see below)

## FKKit dependency & versions

`Package.swift` declares FKKit with **`.upToNextMajor(from: "0.71.0")`** (equivalent to `from: "0.71.0"`): consumers resolve **one** FKKit package in the `0.71.0 … < 1.0.0` range — typically the **highest** version that satisfies your app and FKBusinessKit.

| Topic | Guidance |
| --- | --- |
| **Minimum FKKit** | `0.71.0` — required for ListKit v4, Widgets, TabBarFilter sheet APIs, etc. Bumped in `Package.swift` when this repo adopts newer FKKit APIs. |
| **App adds only FKBusinessKit** | FKKit is pulled in transitively; no duplicate modules or import conflicts. |
| **App also adds FKUIKit** | Fine for UI-heavy targets. Use the **same** FKKit package URL and a **lower bound ≥ `0.71.0`** so SPM picks a single resolved version. |
| **Staying current** | In your app: **File → Packages → Update to Latest Package Versions**, or `swift package update`. |
| **Maintainers** | After raising the minimum in `Package.swift`, update `FKBusinessKit.podspec` and this README. |

## Installation (SPM)

### Xcode
1. Add **FKBusinessKit**: `https://github.com/feng-zhang0712/FKBusinessKit.git` (from `0.8.0`)
2. Link **`FKBusinessKit`** to your app target (FKKit is resolved transitively).
3. **Optional:** also add **FKKit** (`from: "0.71.0"`) if many targets use `FKUIKit` directly without `import FKBusinessKit`.

### Package.swift (typical app)
```swift
dependencies: [
  .package(url: "https://github.com/feng-zhang0712/FKBusinessKit.git", from: "0.8.0"),
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "FKBusinessKit", package: "FKBusinessKit"),
    ]
  )
]
```

### Package.swift (app also depends on FKKit directly)
```swift
dependencies: [
  .package(url: "https://github.com/feng-zhang0712/FKKit.git", from: "0.71.0"),
  .package(url: "https://github.com/feng-zhang0712/FKBusinessKit.git", from: "0.8.0"),
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "FKBusinessKit", package: "FKBusinessKit"),
      .product(name: "FKUIKit", package: "FKKit"),
    ]
  )
]
```

### Local path (side-by-side clones)
```swift
dependencies: [
  .package(path: "../FKKit"),
  .package(path: "../FKBusinessKit"),
],
```

## Installation (CocoaPods)

```ruby
platform :ios, '15.0'

pod 'FKCoreKit',     :git => 'https://github.com/feng-zhang0712/FKKit.git', :tag => '0.71.0'
pod 'FKBusinessKit', :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => '0.8.0'
```

Local development:

```ruby
pod 'FKCoreKit',     :path => '../FKKit'
pod 'FKBusinessKit', :path => '../FKBusinessKit'
```

## Usage

```swift
import FKBusinessKit  // re-exports FKCoreKit + FKUIKit

let version = FKUtilsDevice.systemVersion()
```

For legacy **BusinessKit** capabilities (`FKBusinessKit.shared`, version, track, i18n, etc.), use **`FKCoreKit`** from the [FKKit](https://github.com/feng-zhang0712/FKKit) repository — see `Sources/FKCoreKit/BusinessKit/README.md` there.

Module notes: [`Sources/FKBusinessKit/README.md`](Sources/FKBusinessKit/README.md).

## Contributing

Pull requests welcome against **`develop`**. Ensure the package builds on iOS Simulator before opening a PR.

## Support

[GitHub Issues](https://github.com/feng-zhang0712/FKBusinessKit/issues)

## Security

[Private security advisories](https://github.com/feng-zhang0712/FKBusinessKit/security/advisories/new)

## Branching & Collaboration (Recommended)

- Optional hooks: `./scripts/install-git-hooks.sh`
- Integration branch: **`develop`**
- Conventional commits: `feat:`, `fix:`, `docs:`, etc.
- PRs target **`develop`** with build verification notes

## License

MIT — see [`LICENSE`](LICENSE).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).
