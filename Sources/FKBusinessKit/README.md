# FKBusinessKit (module)

Swift package module for **iOS** business and composite components, built on **[FKKit](https://github.com/feng-zhang0712/FKKit)**.

## Overview

This target depends on **`FKCoreKit`** from FKKit. Add new Swift sources under `Sources/FKBusinessKit/` (for example `Components/YourFeature/`) and `import FKCoreKit` (and `FKUIKit` in app targets when needed).

Legacy **BusinessKit** infrastructure (version, analytics, i18n, lifecycle, deeplink, utilities) is maintained in **FKKit** at `Sources/FKCoreKit/BusinessKit/`. Use `import FKCoreKit` and `FKBusinessKit.shared` from that repository — not from this package.

## Directory layout

| Path | Role |
|------|------|
| `FKBusinessKit.swift` | Package module marker; re-exports FKCoreKit + FKUIKit |
| `Components/TabBarFilter/` | Anchored dropdown filter strip ([README](Components/TabBarFilter/README.md)) |
| `README.md` | This file (excluded from the compile target) |

Recommended layout for new work (match FKUIKit conventions when adding UI):

```text
Sources/FKBusinessKit/
├─ FKBusinessKit.swift
└─ Components/
   └─ <YourComponent>/
      ├─ Public/
      ├─ Internal/
      └─ README.md
```

## Requirements

- iOS 15.0+
- Swift 6.0+
- FKKit `0.59.1+` (`FKCoreKit`, `FKUIKit`)

## Installation

See the repository root [`README.md`](../../../README.md).

## Usage

```swift
import FKBusinessKit
import FKCoreKit

_ = FKBusinessKitModule.name
_ = FKUtilsDevice.systemVersion()
```

## Examples

[`Examples/FKBusinessKitExamples/`](../../../Examples/FKBusinessKitExamples/) — open `FKBusinessKitExamples.xcodeproj` and run on Simulator.

## License

MIT — see [`LICENSE`](../../../LICENSE).
