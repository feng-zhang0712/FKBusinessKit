# FKBusinessKit

Module-level documentation for the **FKBusinessKit** Swift package.  
For repository overview, installation badges, and contributing, see the root [`README.md`](../../../README.md).

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Directory Map](#directory-map)
- [Architecture](#architecture)
- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [License](#license)

## Overview

`FKBusinessKit` is a **pure native Swift** business-capability library distributed as a standalone open-source package (SPM + CocoaPods).

It exposes a **single entry point** — `FKBusinessKit.shared` — for high-frequency app features commonly needed in medium and large iOS projects:

| Subsystem | Access | Purpose |
|-----------|--------|---------|
| Version | `.version` | Local/remote compare, optional/forced update prompts |
| Track | `.track` | Page/click/custom events, batch upload, retry |
| I18n | `.i18n` | In-app language switching (`xx.lproj`) |
| Lifecycle | `.lifecycle` | Foreground/background state stream |
| Deeplink | `.deeplink` | URL parsing, pattern routing |
| Info | `.info` | Bundle, device, channel, environment metadata |
| Utils | `.utils` | Time/number formatting, masking, alerts, startup tasks |

Design goals:

- **Zero third-party dependencies** (Foundation/UIKit only)
- **Protocol-oriented** and **pluggable** (uploaders, version providers, common params)
- **Thread-safe** and **non-blocking** analytics
- **Async/await + closure** dual APIs
- Works with any architecture (MVVM, MVP, Clean Architecture, etc.)

## Requirements

- **iOS 15.0+** (declared in `Package.swift`)
- **Swift 6.0+** / **Xcode 16.2+** (`swift-tools-version: 6.0`)

## Installation

### Swift Package Manager

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

Then:

```swift
import FKBusinessKit
```

### CocoaPods

```ruby
platform :ios, '15.0'
pod 'FKBusinessKit', :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => '0.1.0'
```

Local development:

```ruby
pod 'FKBusinessKit', :path => '../FKBusinessKit'
```

## Directory Map

Source root: `Sources/FKBusinessKit/`

| Folder | Responsibility | Key types |
|--------|----------------|-----------|
| `Core/` | Hub singleton, configuration, public protocols, device/app info, UIKit bridge | `FKBusinessKit`, `FKBusinessKitConfiguration`, `FKBusinessProtocols`, `FKBusinessInfoProvider`, `FKMainActorUIKitBridge` |
| `Version/` | Version compare, update prompts, App Store lookup | `FKBusinessVersionManager`, `FKAppStoreRemoteVersionProvider` |
| `Track/` | Event buffering, batch upload, retry | `FKBusinessAnalyticsTracker` |
| `I18n/` | Language selection, bundle resolution, change notifications | `FKBusinessI18nManager` |
| `Lifecycle/` | `UIApplication` lifecycle observation | `FKBusinessLifecycleObserver` |
| `Deeplink/` | Route registry, URL matching, dispatch | `FKBusinessDeeplinkRouter` |
| `Utils/` | Formatters, masking, alert de-duplication, startup orchestration | `FKBusinessUtilities`, `FKBusinessTimeFormatter`, `FKBusinessNumberFormatter`, `FKBusinessMasker`, `FKBusinessAlertManager`, `FKBusinessStartupTaskManager` |
| `Model/` | Shared models, unified errors, observation tokens | `FKBusinessModels`, `FKBusinessError`, `FKBusinessObservationToken` |

Integrators typically interact only with `FKBusinessKit.shared` and the public protocols in `Core/FKBusinessProtocols.swift`.

## Architecture

```
FKBusinessKit.shared
├── configuration          ← FKBusinessKitConfiguration (channel, environment, analytics policy)
├── version                ← FKBusinessVersioning
├── track                  ← FKBusinessTracking
├── i18n                   ← FKBusinessLocalizing
├── lifecycle              ← FKBusinessLifecycleObserving
├── deeplink               ← FKBusinessDeeplinkRouting
├── info                   ← FKBusinessInfoProviding
└── utils                  ← FKBusinessUtilitiesProviding
    ├── time
    ├── number
    ├── mask
    ├── alerts
    └── startup
```

Key principles:

- **Protocol-oriented** public surface for testability and custom implementations
- **Pluggable providers** — `FKRemoteVersionProviding`, `FKAnalyticsUploading`, `FKAnalyticsCommonParametersProviding`
- **Thread-safe internals** — locks and serial queues; analytics never blocks the caller
- **MainActor UI** — update prompts and alerts presented on the main thread via explicit isolation

## Basic Usage

### Configure (optional)

```swift
import FKBusinessKit

FKBusinessKit.shared.updateConfiguration { config in
  config.channel = "AppStore"
  config.defaultLanguageCode = "en"
  config.analyticsFlushInterval = 10
  config.analyticsMaxBatchSize = 20
  config.analyticsMaxRetryCount = 3
}
```

### Track events (non-blocking)

```swift
FKBusinessKit.shared.track.trackPageView("Home", parameters: ["source": "tab"])
FKBusinessKit.shared.track.trackClick("BuyButton", page: "Product", parameters: ["sku": "123"])
FKBusinessKit.shared.track.trackEvent("checkout_submit", parameters: ["step": "pay"])
```

### In-app language switching

```swift
FKBusinessKit.shared.i18n.setLanguageCode("zh-Hans")
let title = FKBusinessKit.shared.i18n.localized("home_title", table: nil)
```

### Observe lifecycle

```swift
let token = FKBusinessKit.shared.lifecycle.observe { state in
  print("lifecycle:", state.rawValue)
}
// token.invalidate() when done
```

## Advanced Usage

### Version check & update

**App Store provider:**

```swift
let provider = FKAppStoreRemoteVersionProvider(
  bundleID: FKBusinessKit.shared.info.bundleID,
  countryCode: "us",
  isForceUpdate: false
)

FKBusinessKit.shared.version.checkForUpdate(using: provider) { result in
  if case let .success(check) = result {
    FKBusinessKit.shared.version.presentUpdatePromptIfNeeded(result: check, presenter: nil)
  }
}
```

**Custom backend** — implement `FKRemoteVersionProviding` and return `FKRemoteVersionInfo`.

### Analytics upload

Implement `FKAnalyticsUploading` and register:

```swift
FKBusinessKit.shared.track.setUploader(MyAnalyticsUploader())
FKBusinessKit.shared.track.setCommonParametersProvider(MyCommonParams())
```

Events persist under `Caches/FKBusinessKit/` until uploaded. Call `flush()` on background or before termination.

### Deeplink routing

```swift
FKBusinessKit.shared.deeplink.register(
  FKDeeplinkRoute(id: "product", host: "example.com", pathPattern: "/product/*") { context in
    print("params:", context.parameters)
    return true
  }
)

let handled = FKBusinessKit.shared.deeplink.route(
  URL(string: "https://example.com/product/123?ref=ad")!,
  source: .universalLink
)
```

### Business utilities

```swift
// Relative time
FKBusinessKit.shared.utils.time.relativeDescription(from: earlier, now: now)

// Amount / compact number
FKBusinessKit.shared.utils.number.formatAmount(Decimal(string: "1234567.89")!, fractionDigits: 2)
FKBusinessKit.shared.utils.number.formatCompact(12_345_678, fractionDigits: 1)

// Masking
FKBusinessKit.shared.utils.mask.maskPhone("13800138000")       // 138****8000
FKBusinessKit.shared.utils.mask.maskEmail("name@example.com")  // n***@example.com

// Alert de-duplication
FKBusinessKit.shared.utils.alerts.presentOnce(id: "session_expired", title: "…", message: "…", actions: [...], presenter: nil)

// Startup tasks
FKBusinessKit.shared.utils.startup.register(FKStartupTask(id: "warmup", priority: .low, delay: 1.0) { … })
await FKBusinessKit.shared.utils.startup.runAll()
```

## API Reference

**Entry:** `FKBusinessKit.shared`

| Area | Protocol | Notable APIs |
|------|----------|--------------|
| Config | — | `configuration`, `updateConfiguration(_:)` |
| Version | `FKBusinessVersioning` | `appMetadata()`, `checkForUpdate(using:)`, `presentUpdatePromptIfNeeded(result:presenter:)` |
| Track | `FKBusinessTracking` | `trackPageView`, `trackClick`, `trackEvent`, `setUploader`, `flush` |
| I18n | `FKBusinessLocalizing` | `currentLanguageCode`, `setLanguageCode`, `localized`, `observeLanguageChange` |
| Lifecycle | `FKBusinessLifecycleObserving` | `state`, `observe(_:)` |
| Deeplink | `FKBusinessDeeplinkRouting` | `register`, `unregister`, `route(_:source:)` |
| Info | `FKBusinessInfoProviding` | `bundleID`, `appVersion`, `buildNumber`, `deviceModelIdentifier`, `screenSize`, `channel`, `environment` |
| Utils | `FKBusinessUtilitiesProviding` | `.time`, `.number`, `.mask`, `.alerts`, `.startup` |

Pluggable protocols: `FKRemoteVersionProviding`, `FKAnalyticsUploading`, `FKAnalyticsCommonParametersProviding`.

Shared types: `FKBusinessError`, `FKBusinessObservationToken`, models in `Model/FKBusinessModels.swift`.

## Error Handling

Unified error type: `FKBusinessError`

- `.invalidArgument(...)`
- `.missingConfiguration(...)`
- `.unsupported(...)`
- `.networkFailed(...)`
- `.persistenceFailed(...)`
- `.cancelled`
- `.unknown(...)`

Analytics upload failures propagate through `FKAnalyticsUploading`; throw to enable retry.

## Best Practices

- Configure channel/environment and register an uploader **at app launch**.
- Keep tracking calls lightweight — defer heavy parameter computation.
- Flush analytics when entering background (`lifecycle.observe`).
- Mask sensitive values before logging or analytics (`utils.mask`).
- Observe language changes in one place (root coordinator) and refresh UI.
- Validate deeplink parameters before navigation.
- Use backend force-update flags for critical security releases.

## Examples

Interactive demo app: [`Examples/FKBusinessKitExamples/`](../../../Examples/FKBusinessKitExamples/)

Open `FKBusinessKitExamples.xcodeproj`, run on Simulator, and use the demo buttons to exercise every subsystem (version, track, i18n, lifecycle, deeplink, utils).

Entry point: `Examples/FKBusinessKitExamples/FKBusinessKitExamples/Examples/FKBusinessKit/FKBusinessKitExampleViewController.swift`

## License

MIT License — see repository root [`LICENSE`](../../../LICENSE).
