# Changelog

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- Raise minimum FKKit dependency to `0.59.1` (`Package.swift`, `FKBusinessKit.podspec`, README).
- **TabBarFilter** — merge ``FKTabBarFilterDropdownController`` into ``FKTabBarFilterController`` (single public VC). ``FKTabBarFilterConfiguration`` now holds tab bar, presentation, anchor, caching, and ``events`` directly; ``FKTabBarFilterDropdownConfiguration`` removed. ``FKTabBarFilterDropdownController`` is a deprecated typealias.

### Fixed

- **TabBarFilter** — `chevronTitle` uses ``FKTabBarItem/accessoryIcon`` so filter chevrons render on FKUIKit 0.59+.
- **TabBarFilter** — ``FKTabBarFilterController`` rotates chevron accessories 180° on expand/collapse (FKKit filter-strip preset).
- **TabBarFilter** — chevron accessory tint follows title highlight when chevron/title colors match (FKTabBar `textColor` fallback).

## [0.1.2] - 2026-06-02

### Changed

- Raise minimum FKKit dependency to `0.59.0` (`Package.swift`, `FKBusinessKit.podspec`, README); superseded by `0.59.1` minimum in a follow-up release.

### Fixed

- **TabBarFilter** — compact tab padding uses `FKTabBarConfiguration.layout.itemInsets` (FKUIKit 0.59; replaces `itemContentInsets`).

## [0.1.1] - 2026-06-01

### Changed

- Raise minimum FKKit dependency to `0.58.0` (`Package.swift`, `FKBusinessKit.podspec`).

### Fixed

- **TabBarFilter** — migrate compact tab button insets to `FKTabBarConfiguration.layout.itemContentInsets` for FKUIKit 0.58 `FKTabBar` API.
- **FKBusinessKitExamples** — resolve Swift 6 strict-concurrency warnings in TabBarFilter anchor-zone and configuration playgrounds.

## [0.1.0] - 2026-05-29

### Added

- **FKBusinessKit** Swift Package Manager product and CocoaPods pod (iOS 15+, Swift 6 language mode).
- Re-exports **FKCoreKit** and **FKUIKit** from [FKKit](https://github.com/feng-zhang0712/FKKit) (`0.55.0+`).
- **TabBarFilter** — anchored dropdown filter strip built on `FKTabBar` and `FKSheetPresentationController`:
  - `FKTabBarFilterDropdownController` for generic anchored panels per tab.
  - `FKTabBarFilterController` with `FKTabBarFilterPanelFactory` for built-in filter panel kinds (single list, two-column list/grid, chips) and custom panels.
  - Tab-switch transitions (`anchorReplacementPolicy`), per-tab content caching, backdrop/swipe dismiss, and configurable anchor placement (navigation bar, screen top/bottom).
  - `FKTabBarFilterHosting` helpers to embed the strip and pin presentation overlay to a full-screen host.
- Example app **FKBusinessKitExamples** with consolidated playgrounds (configuration, equal-width tabs, anchor zones) and isolated panel demos.
- GitHub Actions CI (iOS Simulator SPM build, podspec version alignment).
- Maintainer scripts under `scripts/` (`bump-version.sh`, `verify-podspec-versions.sh`, `install-git-hooks.sh`).

### Changed

- Package scope is **new business/composite components** on FKKit. Legacy **BusinessKit** infrastructure (`FKBusinessKit.shared`, version, track, i18n, lifecycle, deeplink, utils) lives in **FKKit** (`FKCoreKit/BusinessKit`) — not in this repository.

[0.1.1]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.1.1
[0.1.0]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.1.0
