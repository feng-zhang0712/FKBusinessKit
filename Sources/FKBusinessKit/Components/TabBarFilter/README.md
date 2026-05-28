# Tab bar filter (`FKTabBarFilter`)

Composite UIKit component: **`FKTabBar`** strip + **anchor-embedded panels** via **`FKSheetPresentationController`**, with optional **filter panel** factories and chrome.

Combines the former **AnchoredDropdownController** (generic tab + anchored panel hosting) and **Filter** (filter strip, panel kinds, selection handling) into one module folder.

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
- Tap **another** tab to **switch** (in-place animation or dismiss-then-present, configurable).
- Dismiss via **backdrop / swipe** when enabled on `presentationConfiguration.dismissBehavior`.

Panel content is **your** `UIViewController` (or hosted `UIView`) per tab — use ``FKTabBarFilterDropdownController`` directly.

### Filter strip

- Same anchored-dropdown behavior with **filter-specific** tab chrome (chevron titles, title overrides on single-select).
- Built-in panel kinds via ``FKTabBarFilterPanelFactory`` — use ``FKTabBarFilterController`` or ``FKTabBarFilterHosting`` for layout.

## Anchor

Default: source = ``FKTabBarFilterTabBarHost/tabBar``, overlay = the host’s `view`.

Custom: assign ``FKTabBarFilterDropdownConfiguration/anchorPlacement`` or call ``FKTabBarFilterDropdownController/setAnchor(source:overlayHost:)``. Adjust geometry with ``updateAnchorPlacement(...)``; ``resetAnchorToDefault()`` clears placement.

Choose `overlayHost` as an ancestor of `source` when possible so mask and layout bounds match the screen region you expect.

## Main types

| Type | Role |
|------|------|
| ``FKTabBarFilterDropdownController`` | Child-friendly `UIViewController`; generic `TabID: Hashable`. |
| ``FKTabBarFilterController`` | Filter strip built on ``FKTabBarFilterDropdownController`` + ``FKTabBarFilterPanelFactory``. |
| ``FKTabBarFilterHosting`` | Embed strip under a top anchor and pin presentation overlay to a host view. |
| ``FKTabBarFilterDropdownTab`` / ``FKTabBarFilterTab`` | Tab id, bar item, and content / panel kind. |
| ``FKTabBarFilterDropdownConfiguration`` / ``FKTabBarFilterConfiguration`` | Tab bar + sheet presentation, switch animation, caching, events. |
| ``FKTabBarFilterPanelFactory`` | Creates panel VCs for ``FKTabBarFilterPanelKind`` values. |
| ``FKTabBarFilterTabBarHost`` | Custom chrome around `FKTabBar`; default type ``FKTabBarFilterDefaultTabBarHost``. |

## Dependencies

- **FKUIKit**: `FKTabBar`, `FKSheetPresentationController`, anchor types.
- **FKCoreKit**: optional for your own panel code.

Integration: build tabs, pick configuration, optionally `events`, then ``embed(in:pinTo:)`` / ``FKTabBarFilterHosting/embedStrip(...)`` or add as a child view controller.

## Examples

See `Examples/FKBusinessKitExamples/FKBusinessKitExamples/Examples/FKBusinessKit/TabBarFilter/` — entry hub ``FKTabBarFilterExamplesHubViewController``.
