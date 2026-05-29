# Tab bar filter (`FKTabBarFilter`)

Composite UIKit component: **`FKTabBar`** strip + **anchor-embedded panels** via **`FKSheetPresentationController`**, with optional **filter panel** factories and chrome.

## Layout

| Location | Role |
|----------|------|
| **`Public/Core/`** | ``FKTabBarFilterDropdownController``, ``FKTabBarFilterController``, configuration, tabs, hosting, panel factory. |
| **`Public/Panels/`** | Built-in filter panel view controllers (single list, two-column list/grid, chips). |
| **`Public/Appearance/`** | Panel chrome styles (pill, list cell, height behavior, shared two-column types). |
| **`Public/Models/`** | Filter selection and panel data models. |
| **`Internal/`** | View wrapping and top hairline wrapper helpers. |
| **`Extension/`** | ``FKTabBarFilterDropdownConfiguration`` presets. |

## When to use

### Anchored dropdown (generic)

- Tap a tab to **expand** a panel anchored under the bar (or a custom view).
- Tap the **same** tab to **collapse**.
- Tap **another** tab to **switch** (in-place or dismiss-then-present via ``FKSheetPresentationAnchorReplacementPolicy``).
- Dismiss via **backdrop / swipe** when enabled on `presentationConfiguration.dismissBehavior`.

Panel content is **your** `UIViewController` (or hosted `UIView`) per tab — use ``FKTabBarFilterDropdownController`` directly.

### Filter strip

- Same anchored-dropdown behavior with **filter-specific** tab chrome (chevron titles, title overrides on single-select).
- Built-in panel kinds via ``FKTabBarFilterPanelFactory`` — use ``FKTabBarFilterController`` or ``FKTabBarFilterHosting`` for layout.

## Anchor

Default: source = ``FKTabBarFilterTabBarHost/tabBar``, overlay = the host’s `view`.

Custom: assign ``FKTabBarFilterDropdownConfiguration/anchorPlacement`` or call ``FKTabBarFilterDropdownController/setAnchor(source:overlayHost:)``. Adjust geometry with ``updateAnchorPlacement(attachmentEdge:expansionDirection:horizontalAlignment:widthPolicy:attachmentOffset:)``; ``resetAnchorToDefault()`` clears placement.

``FKAnchor`` supports **top/bottom** attachment edges and **up/down** expansion only. Typical zones:

| Zone | `attachmentEdge` | `expansionDirection` |
|------|------------------|----------------------|
| Below navigation bar / screen top | `.bottom` | `.down` |
| Screen bottom toolbar | `.top` | `.up` |

Left/right edge trays are **not** part of TabBarFilter — use ``FKSheetPresentationConfiguration/Layout/edge(_:)`` on ``FKSheetPresentationController`` directly.

**Overlay host:** Pin to a full-screen ancestor when the dimmed backdrop should cover more than the strip container. ``FKTabBarFilterController/pinAnchoredPresentationOverlay(to:)`` sets `source = tabBar` and `overlayHost = hostView`. ``FKTabBarFilterHosting/embedStrip`` does the same after embedding.

**Upward panels:** Mask coverage switches to `.fullScreen` automatically when `expansionDirection == .up` so backdrop taps dismiss reliably.

## Main types

| Type | Role |
|------|------|
| ``FKTabBarFilterDropdownController`` | Child-friendly `UIViewController`; generic `TabID: Hashable`. |
| ``FKTabBarFilterController`` | Filter strip built on ``FKTabBarFilterDropdownController`` + ``FKTabBarFilterPanelFactory``. |
| ``FKTabBarFilterHosting`` | Embed strip under a top anchor and pin presentation overlay to a host view. |
| ``FKTabBarFilterDropdownTab`` / ``FKTabBarFilterTab`` | Tab id, bar item, and content / panel kind. |
| ``FKTabBarFilterDropdownConfiguration`` / ``FKTabBarFilterConfiguration`` | Tab bar + sheet presentation, ``anchorReplacementPolicy``, caching, ``dropdownEvents``. |
| ``FKTabBarFilterPanelKind`` | Stable kind id; maps to ``FKTabBarFilterPanelFactory/PanelSource`` (see kind doc comment). |
| ``FKTabBarFilterPanelFactory`` | Creates panel VCs for ``FKTabBarFilterPanelKind`` values (loading title, hairline wrapper). |
| ``FKTabBarFilterTabBarHost`` | Custom chrome around `FKTabBar`; default type ``FKTabBarFilterDefaultTabBarHost``. |

## Configuration paths

| Path | Use |
|------|-----|
| ``FKTabBarFilterController`` + ``setFilterConfiguration(_:)`` | Filter strip — syncs dropdown config and ``dropdownEvents``. |
| ``FKTabBarFilterDropdownController`` + ``configuration`` / ``events`` | Low-level dropdown only. |

Avoid mutating ``FKTabBarFilterController/dropdownController`` directly after ``setFilterConfiguration(_:)`` without updating ``filterConfiguration`` — the two can drift.

## Dependencies

- **FKUIKit**: `FKTabBar`, `FKSheetPresentationController`, anchor types.
- **FKCoreKit**: optional for your own panel code.

Integration: build tabs, pick configuration, optionally ``dropdownEvents``, then ``embed(in:pinTo:)`` / ``FKTabBarFilterHosting/embedStrip(...)`` or add as a child view controller.

## Examples

See `Examples/FKBusinessKitExamples/.../TabBarFilter/` — entry hub ``FKTabBarFilterExamplesHubViewController``.
