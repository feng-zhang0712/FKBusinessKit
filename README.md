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
FKBusinessKit is a pure native Swift business capability library for iOS applications.  
It provides a **single entry point** (`FKBusinessKit.shared`) for high-frequency app features commonly needed in medium and large iOS projects.

The library is built on top of Apple system frameworks and distributed via **Swift Package Manager (SPM)** and **CocoaPods**, with no third-party runtime dependencies.

## Features
- Pure Swift implementation (Swift 6 language mode in package settings).
- No third-party dependencies (Foundation/UIKit only).
- Swift Package Manager and CocoaPods integration.
- Continuous integration via **GitHub Actions**: builds and runs **unit tests** on **iOS Simulator** (see `.github/workflows/ci.yml`).
- Protocol-oriented design with pluggable implementations for testability.
- Thread-safe, non-blocking APIs (async/await + closure dual styles).
- Example app under [`Examples/FKBusinessKitExamples`](Examples/FKBusinessKitExamples) for direct integration reference.

## Module Structure

```text
FKBusinessKit/
├─ Package.swift
├─ FKBusinessKit.podspec
├─ Tests/
│  └─ FKBusinessKitTests/
├─ Sources/
│  └─ FKBusinessKit/
│     ├─ Core/
│     ├─ Version/
│     ├─ Track/
│     ├─ I18n/
│     ├─ Lifecycle/
│     ├─ Deeplink/
│     ├─ Utils/
│     ├─ Model/
│     └─ README.md
└─ Examples/
   └─ FKBusinessKitExamples/
```

### Core Business Capabilities

| Area | Description |
|------|-------------|
| **Version** | Local/remote version comparison, optional/forced update prompts, App Store lookup provider |
| **Track** | Page view / click / custom event APIs, file-backed buffering, batch upload, retry |
| **I18n** | In-app language switching independent of system language |
| **Lifecycle** | Centralized `UIApplication` lifecycle state stream |
| **Deeplink** | URL parsing, pattern matching, pluggable route handlers |
| **Utils** | Time/number formatting, sensitive-string masking, alert de-duplication, startup tasks |
| **Info** | Device and app metadata (bundle ID, version, screen, channel) |

For complete API documentation, see [`Sources/FKBusinessKit/README.md`](Sources/FKBusinessKit/README.md).

## Requirements
- **iOS 15.0+** (declared in `Package.swift`)
- Swift toolchain **6.0+** / **Xcode 16.2+** (`swift-tools-version` in `Package.swift` is **6.0**)

## Installation (SPM)

### Xcode
1. Open `File` -> `Add Package Dependencies...`
2. Enter repository URL:
   - `https://github.com/feng-zhang0712/FKBusinessKit.git`
3. Select product:
   - `FKBusinessKit`

### Package.swift
```swift
dependencies: [
  .package(url: "https://github.com/feng-zhang0712/FKBusinessKit.git", from: "0.1.0")
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "FKBusinessKit", package: "FKBusinessKit")
    ]
  )
]
```

## Installation (CocoaPods)

The repository ships a podspec aligned with the SPM product. The podspec **`s.version`** must match a **published Git tag** (for example `0.1.0`).

**Maintainers:** version bump script (`scripts/bump-version.sh`), drift check (`scripts/verify-podspec-versions.sh`, also run in CI), and full release checklist — **`docs/RELEASING.md`**.

### Podfile (Git tag)

```ruby
platform :ios, '15.0'

pod 'FKBusinessKit', :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => '0.1.0'
```

### Podfile (local path, for development)

```ruby
platform :ios, '15.0'

pod 'FKBusinessKit', :path => '../FKBusinessKit'
```

### Linting podspecs (maintainers)

```text
pod spec lint FKBusinessKit.podspec --allow-warnings
```

## Usage

```swift
import FKBusinessKit

FKBusinessKit.shared.updateConfiguration { config in
  config.channel = "AppStore"
  config.defaultLanguageCode = "en"
}

FKBusinessKit.shared.track.trackPageView("Home", parameters: ["source": "tab"])
FKBusinessKit.shared.track.trackClick("BuyButton", page: "Product", parameters: ["sku": "123"])
```

For advanced usage (version checks, deeplink routing, i18n, lifecycle observation), refer to [`Sources/FKBusinessKit/README.md`](Sources/FKBusinessKit/README.md).

## Contributing

Pull requests are welcome. Open PRs against **`develop`**, keep changes focused, and ensure tests pass (locally with Xcode / `xcodebuild`, or via CI). Branch naming, git hooks, commit message conventions, and release flow: [Branching & Collaboration (Recommended)](#branching--collaboration-recommended).

## Support

File bug reports and feature requests in [GitHub Issues](https://github.com/feng-zhang0712/FKBusinessKit/issues).

## Security

Please report security vulnerabilities through [GitHub private security advisories](https://github.com/feng-zhang0712/FKBusinessKit/security/advisories/new) instead of public issues.

## Branching & Collaboration (Recommended)

- **Optional Git hooks:** after cloning, run `./scripts/install-git-hooks.sh` so **`git push`** runs **`scripts/verify-podspec-versions.sh`** first (podspec version alignment). See **`docs/GIT_HOOKS.md`**.
- Use `develop` as the integration branch.
- Create feature branches from `develop` (for example: `feature/version-provider`).
- Keep commits focused and use clear conventional-style messages.
- Follow this commit format:
  - `<type>(<scope>): <subject>`
  - Example: `feat(track): add custom event batch size override`
- Recommended commit types:
  - `feat`: new feature
  - `fix`: bug fix
  - `refactor`: internal refactor without behavior change
  - `perf`: performance improvement
  - `docs`: documentation updates
  - `test`: tests added or updated
  - `build`: build/dependency/tooling changes
  - `chore`: maintenance tasks
- Open pull requests into `develop` with:
  - change summary
  - test/verification notes
  - migration notes when APIs change
- Tag stable releases with semantic versions (for example: `0.1.0`), then merge release work back into `develop`.

## License
This repository is licensed under the MIT License.  
See [`LICENSE`](LICENSE) for details.

## Changelog
Release history and migration details are maintained in [`CHANGELOG.md`](CHANGELOG.md).
