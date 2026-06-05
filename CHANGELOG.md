# Changelog

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- Raise minimum FKKit dependency to `0.61.0` (`Package.swift`, `FKBusinessKit.podspec`, README).

## [0.2.0] - 2026-06-02

### Changed

- Raise minimum FKKit dependency to `0.59.1` (`Package.swift`, `FKBusinessKit.podspec`, README).
- **TabBarFilter** — merge ``FKTabBarFilterDropdownController`` into ``FKTabBarFilterController`` (single public view controller). ``FKTabBarFilterConfiguration`` holds tab bar, presentation, anchor, caching, and ``events`` directly.
- **TabBarFilter** (breaking) — rename ``FKTabBarFilterTabStripConfiguration`` → ``FKTabBarFilterTabAppearance``; ``defaultTabStrip`` → ``tabAppearance``; ``FKTabBarFilterTab/tabStrip`` → ``appearance``. Remove ``setFilterConfiguration(_:)`` and ``FKTabBarFilterDropdownController`` typealias. ``panelFactory`` is optional; initializer order is `tabs`, `configuration`, `panelFactory`, `tabBarHost`, `onSelection`. Split controller implementation into internal extensions; re-resolve tabs when ``configuration`` changes.
- **FKBusinessKitExamples** — reorganize TabBarFilter demos (`Catalog`, `Controller`, `Anchoring`, `Panels`, `Support`).

### Fixed

- **TabBarFilter** — `chevronTitle` uses ``FKTabBarItem/accessoryIcon`` so filter chevrons render on FKUIKit 0.59+.
- **TabBarFilter** — ``FKTabBarFilterController`` rotates chevron accessories 180° on expand/collapse (FKKit filter-strip preset).
- **TabBarFilter** — chevron accessory tint follows title highlight when chevron/title colors match (FKTabBar `textColor` fallback).
- **TabBarFilter** — preserve ``FKTabBarFilterConfiguration/anchorPlacement`` when assigning a new ``configuration`` without placement (fixes mask/panel constrained to the strip host after playground toggles).

### Migration (0.1.x → 0.2.0)

| Before (0.1.x) | After (0.2.0) |
|----------------|---------------|
| ``FKTabBarFilterDropdownController`` | ``FKTabBarFilterController`` |
| ``FKTabBarFilterDropdownConfiguration`` | ``FKTabBarFilterConfiguration`` |
| ``FKTabBarFilterTabStripConfiguration`` | ``FKTabBarFilterTabAppearance`` |
| ``defaultTabStrip`` / ``tab.tabStrip`` | ``tabAppearance`` / ``tab.appearance`` |
| ``setFilterConfiguration(_:)`` | ``configuration = …`` |
| ``init(tabs, panelFactory:, configuration:, …)`` | ``init(tabs, configuration:, panelFactory:, tabBarHost:, onSelection:)`` |
| Nested ``dropdownConfiguration`` / ``dropdownEvents`` | Flat ``FKTabBarFilterConfiguration`` fields + ``events`` |

Tabs that use ``FKTabBarFilterTabPanelContent/panelKind`` still require a non-`nil` ``FKTabBarFilterPanelFactory``. Tabs with only ``panelContent/view`` or ``panelContent/viewController`` may omit the factory.

## [0.1.2] - 2026-06-02

### Changed

- Raise minimum FKKit dependency to `0.59.0` (`Package.swift`, `FKBusinessKit.podspec`, README); superseded by `0.59.1` minimum in 0.2.0.

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
- **TabBarFilter** — anchored filter strip built on `FKTabBar` and `FKSheetPresentationController`:
  - `FKTabBarFilterDropdownController` for generic anchored panels per tab (removed in 0.2.0; use `FKTabBarFilterController`).
  - `FKTabBarFilterController` with `FKTabBarFilterPanelFactory` for built-in filter panel kinds (single list, two-column list/grid, chips) and custom panels.
  - Tab-switch transitions (`anchorReplacementPolicy`), per-tab content caching, backdrop/swipe dismiss, and configurable anchor placement (navigation bar, screen top/bottom).
  - `FKTabBarFilterHosting` helpers to embed the strip and pin presentation overlay to a full-screen host.
- Example app **FKBusinessKitExamples** with consolidated playgrounds (configuration, equal-width tabs, anchor zones) and isolated panel demos.
- GitHub Actions CI (iOS Simulator SPM build, podspec version alignment).
- Maintainer scripts under `scripts/` (`bump-version.sh`, `verify-podspec-versions.sh`, `install-git-hooks.sh`).

### Changed

- Package scope is **new business/composite components** on FKKit. Legacy **BusinessKit** infrastructure (`FKBusinessKit.shared`, version, track, i18n, lifecycle, deeplink, utils) lives in **FKKit** (`FKCoreKit/BusinessKit`) — not in this repository.

[0.2.0]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.2.0
[0.1.2]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.1.2
[0.1.1]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.1.1
[0.1.0]: https://github.com/feng-zhang0712/FKBusinessKit/releases/tag/0.1.0
