# Changelog

This file follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-29

### Added

- Initial open-source release extracted from FKKit `FKCoreKit/BusinessKit`.
- **FKBusinessKit** SwiftPM product and CocoaPods pod with subsystems:
  - Version management (local/remote compare, update prompts, App Store provider)
  - Global event tracking (buffer, batch, retry, pluggable uploader)
  - In-app i18n (language switching, bundle resolution)
  - App lifecycle observation
  - Deeplink / Universal Link routing
  - Business utilities (time/number formatting, masking, alerts, startup tasks)
- Example app under `Examples/FKBusinessKitExamples/`.
- CI workflow for iOS Simulator build and test.
- Maintainer docs under `docs/` and release scripts under `scripts/`.
