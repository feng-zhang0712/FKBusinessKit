# FKBusinessKit

[![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
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
FKBusinessKit is an **iOS** Swift package for business-oriented and composite components, built on **[FKKit](https://github.com/feng-zhang0712/FKKit)** (`FKCoreKit`).

It is distributed via **Swift Package Manager (SPM)** and **CocoaPods**. Use it alongside FKKit when you want business-layer or app-specific widgets in a dedicated package, separate from the core FKKit modules.

> **Note:** Legacy business infrastructure APIs (version, track, i18n, lifecycle, deeplink, utils) previously sketched here now live under **FKKit → `FKCoreKit/BusinessKit`**. This repository is the home for **new** FKBusinessKit components going forward.

## Features
- Pure Swift implementation (Swift 6 language mode in package settings).
- **iOS-only** — `platforms: [.iOS(.v15)]` in `Package.swift`.
- Depends on **FKCoreKit** (FKKit `0.54.0+`) via SPM / CocoaPods.
- GitHub Actions CI: builds on **iOS Simulator**.
- Example app under [`Examples/FKBusinessKitExamples`](Examples/FKBusinessKitExamples).

## Module Structure

```text
FKBusinessKit/
├─ Package.swift
├─ FKBusinessKit.podspec
├─ scripts/
├─ Sources/
│  └─ FKBusinessKit/
│     ├─ FKBusinessKit.swift    # Module marker (extend with new components here)
│     └─ README.md
└─ Examples/
   └─ FKBusinessKitExamples/
```

## Requirements
- **iOS 15.0+**
- Swift **6.0+** / **Xcode 16.2+**
- **[FKKit](https://github.com/feng-zhang0712/FKKit)** `0.54.0+` — **`FKCoreKit`** (transitive via this package)

## Installation (SPM)

### Xcode
1. Add **FKKit**: `https://github.com/feng-zhang0712/FKKit.git` (from `0.54.0`)
2. Add **FKBusinessKit**: `https://github.com/feng-zhang0712/FKBusinessKit.git` (from `0.1.0`)
3. Link **`FKBusinessKit`** to your app target (FKCoreKit is resolved transitively).

### Package.swift
```swift
dependencies: [
  .package(url: "https://github.com/feng-zhang0712/FKKit.git", from: "0.54.0"),
  .package(url: "https://github.com/feng-zhang0712/FKBusinessKit.git", from: "0.1.0"),
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "FKBusinessKit", package: "FKBusinessKit"),
      // Optional UI from FKKit:
      // .product(name: "FKUIKit", package: "FKKit"),
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

pod 'FKCoreKit',     :git => 'https://github.com/feng-zhang0712/FKKit.git', :tag => '0.54.0'
pod 'FKBusinessKit', :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => '0.1.0'
```

Local development:

```ruby
pod 'FKCoreKit',     :path => '../FKKit'
pod 'FKBusinessKit', :path => '../FKBusinessKit'
```

## Usage

```swift
import FKBusinessKit
import FKCoreKit

// Use FKCoreKit / FKUIKit APIs from FKKit in your app or in new FKBusinessKit components.
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
