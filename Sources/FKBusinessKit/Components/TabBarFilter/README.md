# Tab bar filter (`FKTabBarFilter`)

Composite UIKit component: **`FKTabBar`** strip + **anchor-embedded panels** via **`FKSheetPresentationController`**, with optional **filter panel** factories and chevron tab chrome.

## Layout

| Location | Role |
|----------|------|
| **`Public/Core/`** | ``FKTabBarFilterController``, configuration, tabs, hosting, panel factory. |
| **`Public/Panels/`** | Built-in filter panel view controllers (single list, two-column list/grid, chips). |
| **`Public/Appearance/`** | Panel chrome styles (pill, list cell, height behavior, shared two-column types). |
| **`Public/Models/`** | Filter selection and panel data models. |
| **`Internal/`** | Resolved tab items, view wrapping, top hairline wrapper helpers. |
| **`Extension/`** | ``FKTabBarFilterConfiguration`` presets. |

## When to use

- Tap a tab to **expand** a panel anchored under the bar (or a custom view).
- Tap the **same** tab to **collapse**.
- Tap **another** tab to **switch** (in-place or dismiss-then-present via ``FKSheetPresentationAnchorReplacementPolicy``).
- Dismiss via **backdrop / swipe** when enabled on `presentationConfiguration.dismissBehavior`.

Use ``FKTabBarFilterController`` for the full experience (chevron titles, built-in panel kinds via ``FKTabBarFilterPanelFactory``, or custom ``FKTabBarFilterTab/panelContent``). ``FKTabBarFilterHosting`` helps embed the strip and pin the presentation overlay.

## Anchor

Default: source = ``FKTabBarFilterTabBarHost/tabBar``, overlay = the host’s `view`.

Custom: assign ``FKTabBarFilterConfiguration/anchorPlacement`` or call ``FKTabBarFilterController/setAnchor(source:overlayHost:)``. Adjust geometry with ``updateAnchorPlacement(attachmentEdge:expansionDirection:horizontalAlignment:widthPolicy:attachmentOffset:)``; ``resetAnchorToDefault()`` clears placement.

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
| ``FKTabBarFilterController`` | `UIViewController`; `TabID: Hashable`. Tab strip, expand/collapse, anchor presentation, optional panel factory. |
| ``FKTabBarFilterHosting`` | Embed strip under a top anchor and pin presentation overlay to a host view. |
| ``FKTabBarFilterTab`` | Tab id, bar item, panel kind or custom content, optional per-tab strip overrides. |
| ``FKTabBarFilterConfiguration`` | Tab bar + sheet presentation, ``anchorReplacementPolicy``, caching, ``events``, ``defaultTabStrip``. |
| ``FKTabBarFilterTabStripConfiguration`` | Chevron title typography and colors (per-tab via ``FKTabBarFilterTab/tabStrip``). |
| ``FKTabBarFilterPanelKind`` | Stable kind id; maps to ``FKTabBarFilterPanelFactory/PanelSource``. |
| ``FKTabBarFilterPanelFactory`` | Creates panel VCs for ``FKTabBarFilterPanelKind`` values (loading title, hairline wrapper). |
| ``FKTabBarFilterTabBarHost`` | Custom chrome around `FKTabBar`; default type ``FKTabBarFilterDefaultTabBarHost``. |

`FKTabBarFilterDropdownController` remains a **deprecated typealias** for ``FKTabBarFilterController`` (migration only).

## Configuration

Pass ``FKTabBarFilterConfiguration`` at init or assign ``FKTabBarFilterController/configuration``. Lifecycle hooks live on ``FKTabBarFilterConfiguration/events``. Per-tab strip styling: ``FKTabBarFilterTab/tabStrip`` or ``defaultTabStrip``.

## Dependencies

- **FKUIKit**: `FKTabBar`, `FKSheetPresentationController`, anchor types.
- **FKCoreKit**: optional for your own panel code.

Integration: build tabs, optional ``FKTabBarFilterPanelFactory``, configuration and ``events``, then ``embed(in:pinTo:)`` / ``FKTabBarFilterHosting/embedStrip(...)`` or add as a child view controller.

## Examples

See `Examples/FKBusinessKitExamples/.../TabBarFilter/` — entry hub ``FKTabBarFilterExamplesHubViewController``.
