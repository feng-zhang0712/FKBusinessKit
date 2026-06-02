# Tab bar filter (`FKTabBarFilter`)

Composite UIKit component: **`FKTabBar`** strip + **anchor-embedded panels** via **`FKSheetPresentationController`**, with optional **filter panel** factories and chevron tab chrome.

## Layout

| Location | Role |
|----------|------|
| **`Public/Core/`** | ``FKTabBarFilterController``, configuration, tabs, appearance, hosting, panel factory. |
| **`Internal/`** | Resolved tabs, tab resolver, controller presentation/tab-bar extensions. |
| **`Public/Panels/`** | Built-in filter panel view controllers. |
| **`Public/Appearance/`** | Panel chrome styles. |
| **`Public/Models/`** | Filter selection and panel data models. |
| **`Extension/`** | ``FKTabBarFilterConfiguration`` presets. |

## Main types

| Type | Role |
|------|------|
| ``FKTabBarFilterController`` | Tab strip, expand/collapse, anchor presentation; optional ``FKTabBarFilterPanelFactory``. |
| ``FKTabBarFilterTab`` | Tab id, panel content, optional per-tab ``appearance``. |
| ``FKTabBarFilterConfiguration`` | Tab bar, sheet, anchor, caching, ``events``, default ``tabAppearance``. |
| ``FKTabBarFilterTabAppearance`` | Chevron title typography and normal/expanded colors. |

## Integration

```swift
let filter = FKTabBarFilterController(
  tabs: tabs,
  configuration: config,
  panelFactory: factory, // nil only when every tab uses .view / .viewController
  tabBarHost: host
)
filter.configuration = updatedConfig // re-resolves tab items
```

**Anchoring:** prefer ``FKTabBarFilterController/setAnchor(source:overlayHost:)`` and ``updateAnchorPlacement`` over mutating ``FKTabBarFilterConfiguration/anchorPlacement`` in place (tab strip items are not rebuilt for in-place placement edits).

See `Examples/FKBusinessKitExamples/.../TabBarFilter/`.
