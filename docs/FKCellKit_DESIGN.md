# FKCellKit — 设计需求文档

FKBusinessKit **业务复合 Cell 组件库**的实现指导文档：规范业务行模板、与 **FKUIKit ListKit** / **Base** / **Widgets** 的组合边界、ListKit 自定义 Cell 接入契约，以及 v1 预设行目录与分阶段交付计划。

**文档类型：** 设计需求（对 FKBusinessKit 实现者具有规范约束力）  
**状态：** 草案  
**最低 FKKit：** `0.71.0`（ListKit v4、Pluggable Cell 协议、Widgets 预设）  
**FKBusinessKit 前提：** `import FKBusinessKit`（re-export `FKCoreKit` + `FKUIKit`）  
**关联文档：** [FKWidgets-Integration_DESIGN.md](FKWidgets-Integration_DESIGN.md)、[FKKit FKListKit_DESIGN.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKListKit_DESIGN.md)

---

## 目录

- [1. 概述](#1-概述)
- [2. 目标、非目标与成功标准](#2-目标非目标与成功标准)
- [3. 背景与问题陈述](#3-背景与问题陈述)
- [4. 架构总览](#4-架构总览)
- [5. 模块边界与职责对照](#5-模块边界与职责对照)
- [6. 核心概念与数据模型](#6-核心概念与数据模型)
- [7. Cell 基类与复用契约](#7-cell-基类与复用契约)
- [8. 与 FKUIKit ListKit 集成](#8-与-fkuikit-listkit-集成)
- [9. 与 FKBusinessKit Base 集成](#9-与-fkbusinesskit-base-集成)
- [10. 与 FKUIKit Widgets 组合](#10-与-fkuikit-widgets-组合)
- [11. 与 TabBarFilter / 筛选面板](#11-与-tabbarfilter--筛选面板)
- [12. v1 预设 Cell 目录](#12-v1-预设-cell-目录)
- [13. 行内子视图（Row Parts）](#13-行内子视图row-parts)
- [14. 配置、主题与外观 Preset](#14-配置主题与外观-preset)
- [15. 生命周期、可见性与性能](#15-生命周期可见性与性能)
- [16. 骨架屏与空态协同](#16-骨架屏与空态协同)
- [17. 无障碍与 Dynamic Type](#17-无障碍与-dynamic-type)
- [18. 业务枚举映射模式](#18-业务枚举映射模式)
- [19. 源码目录结构](#19-源码目录结构)
- [20. FKBusinessKitExamples 场景](#20-fkbusinesskitexamples-场景)
- [21. 分阶段交付计划](#21-分阶段交付计划)
- [22. 反模式（禁止）](#22-反模式禁止)
- [23. FKCoreKit 复用要求](#23-fkcorekit-复用要求)
- [24. 待决问题](#24-待决问题)
- [25. 修订历史](#25-修订历史)

---

## 1. 概述

### 1.1 一句话

**ListKit 管「列表怎么跑」；Widgets 管「原子怎么画」；CellKit 管「业务行怎么拼」。**

FKBusinessKit **CellKit**（`Sources/FKBusinessKit/Components/CellKit/`）交付 **可复用的 UITableViewCell / UICollectionViewCell 业务行模板** 与 **行内复合子视图**，供信息流、通讯录、订单、商品卡片等场景直接使用或经 ListKit 自定义 Cell 路径挂载。

### 1.2 在 FK 生态中的位置

```text
┌─────────────────────────────────────────────────────────────────┐
│ App — ViewModel、领域模型、路由、网络映射                          │
└────────────────────────────┬────────────────────────────────────┘
                             │ Payload / configure(with:)
┌────────────────────────────▼────────────────────────────────────┐
│ FKBusinessKit CellKit                                            │
│  FKUserListCell · FKOrderListCell · FKProductGridCell · RowParts │
│  FKCellKitListRegistration（ListKit 胶水）                          │
└────────────┬───────────────────────────────┬────────────────────┘
             │ 继承 / 组合                      │ FKListItem.custom
┌────────────▼──────────────┐    ┌─────────────▼────────────────────┐
│ FKBusinessKit Base        │    │ FKUIKit ListKit                   │
│ FKBaseTableViewCell         │    │ FKDiffableTableViewController     │
│ FKBaseTableViewController   │    │ FKListItem / Snapshot / Preset    │
└────────────┬──────────────┘    └─────────────┬────────────────────┘
             │                                  │
┌────────────▼──────────────────────────────────▼────────────────────┐
│ FKUIKit Widgets + FKImageView + FKDivider + FKSkeleton …           │
└────────────────────────────┬───────────────────────────────────────┘
                             │
┌────────────────────────────▼───────────────────────────────────────┐
│ FKCoreKit — Pluggable、Async、FKI18n、Extension …                    │
└────────────────────────────────────────────────────────────────────┘
```

### 1.3 与现有 FKBusinessKit 组件关系

| 已有组件 | 与 CellKit 关系 |
|----------|----------------|
| **Base / Cell** | CellKit Cell **继承** `FKBaseTableViewCell` / `FKBaseCollectionViewCell`；不 fork 其 container/shadow 逻辑 |
| **Base / Controller** | 传统 `FKBaseTableViewController` 子类可直接 dequeue CellKit Cell；ListKit 路径优先 `FKDiffableTableViewController` |
| **TabBarFilter** | 筛选面板内 UITableView **不**强制 CellKit；简单文本行继续用 Filter 内置 CellStyle；复杂行可选 CellKit |
| **Widgets 组合片段** | §6 中 `FKUserListLeadingView` 等 **并入 CellKit RowParts** 或作为 Cell 内部实现细节 |

---

## 2. 目标、非目标与成功标准

### 2.1 目标

1. **消除业务行 UI 重复** — IM 用户行、订单行、商品卡片等在多 App / 多模块间复用同一套 Cell 与 RowPart。
2. **ListKit 一等公民** — 每个 v1 预设 Cell 提供 `Item` 模型、`cellTypeIdentifier`、`FKListTableCellConfigurable` / `FKListCollectionCellConfigurable` Conformance，以及 `register` 辅助。
3. **Widgets 组合而非复制** — Leading/trailing 槽位使用 `FKAvatar`、`FKTag`、`FKStatusPill`、`FKCopyChip` 等公开 API。
4. **Base 双路径兼容** — 同一 Cell 可在 ListKit Diffable 与传统 `cellForRow` 中共用。
5. **复用友好** — `prepareForReuse` / `resetCellContent` 取消图片与异步；对齐 ListKit `willDisplay` / `didEndDisplaying` 与 `FKListImagePrefetchProviding`。
6. **FKKit 一致性** — `@MainActor`、英文公开 API 与 DocComment、Swift 6 `Sendable` Item 模型、Examples 全覆盖。

### 2.2 非目标

| 排除项 | 原因 |
|--------|------|
| Diffable DataSource / 快照 / 刷新分页 | **ListKit** 职责 |
| 通用设置页 preset 行（text/subtitle/switch） | **ListKit `FKListPresetItem`** 已覆盖 |
| Widget 渲染实现 | **FKUIKit Widgets** |
| 完整 MVVM / 网络层 | App 层 |
| SwiftUI Cell 本体（v1） | v2+ 可选 `UIViewRepresentable` 包装；ListKit 已有 SwiftUI bridge |
| macOS / tvOS | 仅 iOS 15+ UIKit |
| 替代 `FKTabBarFilter` 面板 Cell | 面板保持轻量；仅文档化可选组合 |
| 拖拽排序 Cell 动画 | ListKit Deferred |

### 2.3 成功标准（v1 验收）

- [ ] `Components/CellKit/` 目录与 README（英文）就绪。
- [ ] 至少 **4 个** v1 预设 Cell（§12）实现并注册 ListKit。
- [ ] 至少 **1 个** Collection 网格 Cell（商品卡片）。
- [ ] `FKCellKitListRegistration`（或等价 API）一行注册 Cell + Payload 类型到 `FKDiffableTableViewController`。
- [ ] Examples：ListKit feed + CellKit 自定义 Cell、Base Table 传统路径、Widgets 组合行各 1 场景。
- [ ] 每个 Cell 演示 `prepareForReuse` 取消 `FKImageView` 加载。
- [ ] `xcodebuild FKBusinessKit` **BUILD SUCCEEDED**（`SWIFT_STRICT_CONCURRENCY=complete`）。

---

## 3. 背景与问题陈述

### 3.1 现有能力矩阵

| 层级 | 模块 | Cell 相关能力 | 缺口 |
|------|------|---------------|------|
| FKCoreKit | Pluggable | `FKListTableCellConfigurable`、`FKListCollectionCellConfigurable`、`FKCellReusable` | 仅协议，无业务行 |
| FKUIKit | ListKit | Diffable VC、通用 preset 行、Payload store、prefetch/visibility | **无** Avatar+双行+Tag 等业务模板 |
| FKUIKit | Widgets | Avatar、Tag、StatusPill、CopyChip… | 需宿主/layout 组合 |
| FKBusinessKit | Base/Cell | `FKBaseTableViewCell` 容器/卡片/shadow | **无** 业务 content 预设 |
| FKBusinessKit | TabBarFilter | `FKTabBarFilterListCellStyle` 文本行 | 非通用业务 Cell |

### 3.2 典型痛点

| 痛点 | 影响 | CellKit 回应 |
|------|------|--------------|
| 每个 feed 手写 Avatar + 标题栈 + Tag | 布局 drift、reuse bug | `FKUserListCell` + `FKUserListRowPart` |
| ListKit 自定义 Cell 注册样板多 | 集成摩擦 | `FKCellKitListRegistration.register(_:on:)` |
| 订单态/角色 Tag 语义色不统一 | 设计不一致 | RowPart + 业务 enum → Widget 配置映射（§18） |
| 商品列表 Table/Collection 两套 UI | 重复维护 | 共享 `FKProductRowModel` + Table/Grid 两种 Cell |
| 图片列表 prefetch 与 Cell 脱节 | 滚动卡顿 | Conform `FKListImagePrefetchProviding` |

### 3.3 设计原则（判定启发式）

**何时进 CellKit vs App vs ListKit preset：**

| 场景 | 归属 |
|------|------|
| 单行标题 + 副标题 + 箭头 | ListKit `FKListPresetItem.disclosure` |
| 用户头像 + 双行 + 在线态 + 未读角标 | **CellKit `FKUserListCell`** |
| 仅 leading 头像+标题（无 trailing）可嵌入多处 | **CellKit RowPart** `FKUserListLeadingView` |
| 仅某一 App 独有、含大量领域 UI | **App 模块** 继承 `FKBaseTableViewCell` |
| 全 App 统一订单行 | **CellKit `FKOrderListCell`** |

---

## 4. 架构总览

### 4.1 分层模型

```text
┌──────────────────────────────────────────────────────────────┐
│ Layer A — List 编排（二选一或组合）                            │
│  FKDiffableTableViewController / FKBaseTableViewController    │
│  + FKTabBarFilter / FKChipGroup（列表外 chrome）               │
└────────────────────────────┬─────────────────────────────────┘
                             │ dequeue / Diffable configure
┌────────────────────────────▼─────────────────────────────────┐
│ Layer B — CellKit Cell（UITableViewCell / UICollectionViewCell）│
│  FKUserListCell · FKOrderListCell · FKProductGridCell …       │
│  继承 FKBase*Cell；实现 Pluggable configure 协议               │
└────────────────────────────┬─────────────────────────────────┘
                             │ 持有、约束
┌────────────────────────────▼─────────────────────────────────┐
│ Layer C — RowParts（可选 UIView 子组件）                       │
│  FKUserListLeadingView · FKOrderMetaTrailingView · FKTagRow   │
└────────────────────────────┬─────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────┐
│ Layer D — FKUIKit Widgets + FKImageView + UILabel …           │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 数据流（ListKit 路径）

1. App VM 拉取领域模型 → 映射为 CellKit **`Item` struct**（`Sendable`）。
2. 构建 `FKListItem.custom(id:cellTypeIdentifier:)` 快照项。
3. `setPayload(FKListItemPayload(item), for: itemID)` 写入 ListKit store。
4. ListKit DataSource 出队 → Cell `configure(with: item)`。
5. 局部刷新：`FKListSnapshotMutation.reconfigureItems`（点赞数、已读态）— Cell `configure` 须幂等。

### 4.3 数据流（Base 传统路径）

1. 子类 `FKBaseTableViewController` 在 `cellForRow` 中 `fk_dequeueCell(FKUserListCell.self, …)`。
2. 直接 `cell.configure(with: viewModel.rows[indexPath.row])`。
3. 刷新：`reloadRows` 或迁移至 ListKit（推荐新页 ListKit）。

---

## 5. 模块边界与职责对照

| 关注点 | FKUIKit ListKit | FKBusinessKit CellKit | App |
|--------|-----------------|----------------------|-----|
| Diffable 快照 | ✓ | ✗ | 构建 snapshot |
| 通用 settings 行 | ✓ preset | ✗ | — |
| 业务 composite 行 | ✗ | ✓ | — |
| 领域 enum / API | ✗ | 映射 helper（可选） | ✓ 源码 |
| Payload 存储 | ✓ `FKListItemStore` | 使用，不复制 | — |
| Cell 注册表 | ✓ `FKListTableCellRegistry` | 提供 register 胶水 | — |
| 图片 prefetch | ✓ helper + 协议 | Cell conform 协议 | — |
| 行高估算 | ✓ `estimatedRowHeight` / cache | 提供 per-Cell 常量或 provider | 可 override |

**依赖方向（不可反转）：**

```text
FKCoreKit ← FKUIKit ← FKBusinessKit (CellKit) ← App
```

CellKit **不得** 新增依赖导致 FKUIKit 引用 FKBusinessKit。

---

## 6. 核心概念与数据模型

### 6.1 命名约定

| 后缀 | 含义 | 示例 |
|------|------|------|
| `*Cell` | 完整 Table/Collection Cell | `FKUserListCell` |
| `*RowPart` / `*View` | 可嵌入 Cell 的 composite 子视图 | `FKUserListLeadingView` |
| `*Item` | Cell 的配置模型（ListKit Payload） | `FKUserListItem` |
| `*Configuration` | 外观/布局 token，与业务数据分离 | `FKUserListCellConfiguration` |
| `*Defaults` | 全局 preset | `FKCellKitDefaults.userList` |

### 6.2 Item 模型规范

每个 CellKit Cell 的 **`Item`** 须：

- `Sendable` struct（或 class + `@unchecked Sendable` 若含 UIImage 等，**尽量避免**）。
- `Equatable` — 支持 ListKit diff 与 `reconfigureItems` 比较。
- **不含** `UIView` / 闭包；交互通过 **handler ID** 或 VC 层 `didSelectItem` 处理。
- 远程资源用 `URL?` / `String`（URL 字符串），由 Cell 内 `FKImageView` / `FKAvatar` 加载。

```swift
// 规范示例（公开 API 为英文）
public struct FKUserListItem: Equatable, Sendable {
  public var id: String
  public var displayName: String
  public var subtitle: String?
  public var avatarURL: URL?
  public var presenceState: FKPresenceState?
  public var unreadCount: Int
  public var roleTag: FKTagDisplayModel?
  public var isVerified: Bool
}
```

### 6.3 DisplayModel（Widget 桥接）

CellKit 定义 **与 UIKit 无关** 的 lightweight display model，在 Cell 内映射为 Widget 配置：

```swift
public struct FKTagDisplayModel: Equatable, Sendable {
  public var title: String
  public var variant: FKTagVariant  // FKUIKit 类型；CellKit import FKUIKit
}
```

**禁止** 在 Item 中直接携带 `FKTag` 实例。

### 6.4 Cell 类型标识符

ListKit 自定义项使用稳定 string identifier：

```swift
extension FKUserListCell {
  public static let listKitCellTypeIdentifier = "FKBusinessKit.CellKit.UserList"
}
```

- 前缀 **`FKBusinessKit.CellKit.`** 避免与 App / FKUIKit 冲突。
- 与 `FKListItem.custom(id:cellTypeIdentifier:)` 中 identifier **一致**。

---

## 7. Cell 基类与复用契约

### 7.1 继承关系

```text
UITableViewCell
  └── FKBaseTableViewCell          (Base/Cell)
        └── FKCellKitTableCell      (CellKit 可选中间层 — 若需要共享 metrics)
              └── FKUserListCell
              └── FKOrderListCell

UICollectionViewCell
  └── FKBaseCollectionViewCell
        └── FKCellKitCollectionCell
              └── FKProductGridCell
```

**`FKCellKitTableCell`（可选）：** 若 v1 多个 Cell 共享相同 `containerInsets`、分隔线、选中背景，可提取薄中间类；**禁止** 为单一 Cell 过度抽象。

### 7.2 必须实现的钩子

| 钩子 | 职责 |
|------|------|
| `setupUI()` | 添加 RowParts / Widgets / 约束 |
| `setupStyle()` | 字体、颜色 token |
| `configure(with: Item)` | 绑定模型；**同步**；禁止网络 |
| `resetCellContent()` | 取消图片、清空 Tag、重置 accessibility |
| `traitConfigurationDidChange` | 刷新 semantic colors |

### 7.3 Pluggable 协议

Table Cell：

```swift
extension FKUserListCell: FKListTableCellConfigurable {
  public typealias Item = FKUserListItem

  public static var cellTypeIdentifier: String { listKitCellTypeIdentifier }

  public func configure(with item: FKUserListItem) { … }
}
```

Collection Cell 等价使用 `FKListCollectionCellConfigurable`。

### 7.4 Dequeue 辅助

复用 Base 已有扩展：

```swift
let cell = tableView.fk_dequeueCell(FKUserListCell.self, for: indexPath)
cell.configure(with: item)
```

---

## 8. 与 FKUIKit ListKit 集成

### 8.1 推荐路径（新列表页）

**ViewController：** 继承 `FKDiffableTableViewController`（或 Collection 等价物），**而非** 同时继承 `FKBaseTableViewController` 与 ListKit — 二者正交；ListKit 已集成 Refresh / Empty / Skeleton。

**CellKit 职责：** 仅提供 Cell + 注册胶水，**不** 包装整个 ListKit VC。

### 8.2 注册胶水 API（v1 交付）

```swift
public enum FKCellKitListRegistration {
  @MainActor
  public static func registerUserListCell(on controller: FKDiffableTableViewController) {
    controller.register(FKUserListCell.self, forPayloadType: FKUserListItem.self)
  }

  // 泛型形式（推荐最终实现）
  @MainActor
  public static func register<Cell: FKListTableCellConfigurable>(
    _ cellType: Cell.Type,
    on controller: FKDiffableTableViewController
  ) where Cell: FKBaseTableViewCell {
    controller.register(cellType, forPayloadType: Cell.Item.self)
  }
}
```

### 8.3 快照构建辅助（可选）

```swift
public enum FKCellKitListItemFactory {
  public static func userList(_ item: FKUserListItem) -> FKListItem {
    .custom(
      id: .init(item.id),
      cellTypeIdentifier: FKUserListCell.listKitCellTypeIdentifier
    )
  }
}
```

配套：`setPayload(FKListItemPayload(item), for:)` 由 App 或 helper 在 apply 前调用。

### 8.4 与 ListKit v2/v3/v4 能力对齐

| ListKit 能力 | CellKit 配合 |
|--------------|--------------|
| `FKListDefaults.feedConfiguration` | 业务 feed 页 + `FKUserListCell`；`estimatedRowHeight` 按 Cell 文档设置 |
| `FKListDelegate` `willDisplay` / `didEndDisplaying` | Cell 可选 conform **`FKListCellVisibilityHandling`**（CellKit 内部协议）转发给 RowPart |
| `reconfigureItems` | Item 设计为细粒度 `Equatable` |
| `FKListImagePrefetchProviding` | 含远程图的 Cell 在类型 extension 中提供 URLs |
| `FKListHeightCache` | 多行文本 Cell（如 `FKFeedContentCell` v1.1+）提供 height cache key |
| `FKListVideoVisibilityCoordinator` | 视频卡片 Cell（v2）暂停/恢复 |
| Collection swipe | 订单行等可声明 `swipeActions` 于 `FKListItem`，handler 在 VC registry |

### 8.5 ListKit Preset vs CellKit 选型

| 需求 | 使用 |
|------|------|
| 设置页开关行 | `FKListPresetItem.switch` |
| 带 SF Symbol 的说明行 | `FKListPresetItem.icon` |
| 用户消息列表 | **CellKit** |
| 订单列表 + 状态 Pill | **CellKit** |
| 混合页（设置 + 用户） | 同一 snapshot 中 **preset + custom** 并存 |

---

## 9. 与 FKBusinessKit Base 集成

### 9.1 何时仍用 FKBaseTableViewController

- 存量页面尚未迁移 Diffable。
- 极简单列表（&lt;10 行）且无分页。
- Demo / 嵌入式小表（如 Examples 局部）。

**集成方式：** 直接 dequeue CellKit Cell；**不** 要求 `FKListItem`。

### 9.2 与 FKBaseListPresentation 协同

| Base API | CellKit 注意点 |
|----------|----------------|
| `beginSkeletonPlaceholderLoading` | 默认 skeleton 为通用 avatar 行；可 **register** CellKit 专用 skeleton cell（v1.1） |
| `syncListEmptyState` | 与 Cell 无关；VC 层 |
| `performPullToRefresh` | 刷新后重新 `configure` 可见 Cell 或迁移 ListKit apply |

### 9.3 搜索（FKBaseSearchIntegration）

- 搜索结果列表推荐 **FKDiffableTableViewController** + CellKit Cell。
- `FKSearchViewController`（FKUIKit）集成时，CellKit 提供与 ListKit Search 示例相同的 Cell 注册（见 FKListKit Examples cross-link）。

---

## 10. 与 FKUIKit Widgets 组合

### 10.1 组合规则（强制）

遵循 [FKWidgets-Integration_DESIGN.md](FKWidgets-Integration_DESIGN.md)：

- **禁止** 在 CellKit 复制 Widget 绘制代码。
- Tag / Status **语义分离**：角色 → `FKTag`；订单物流态 → `FKStatusPill`。
- 头像 **必须** 使用 `FKAvatar` + `setImageURL`；**禁止** Cell 内裸 `URLSession`。

### 10.2 典型行布局

**用户行（IM / 通讯录）：**

```text
┌────────────────────────────────────────────────────────┐
│ [FKAvatar .s]  Title                           [FKTag] │
│                Subtitle                      time/badge │
└────────────────────────────────────────────────────────┘
```

**订单行：**

```text
┌────────────────────────────────────────────────────────┐
│ [icon/avatar]  Order title              [FKStatusPill] │
│                Meta subtitle          [FKCopyChip]     │
└────────────────────────────────────────────────────────┘
```

### 10.3 RowPart 提取条件

当 **≥2 个** Cell 或 **非 Cell 场景**（如 Header、TabBarFilter 自定义 panel）需要相同 leading 布局时，提取 RowPart：

- `FKUserListLeadingView` — Avatar + 双行标题栈
- `FKOrderMetaTrailingView` — CopyChip + StatusPill 水平栈

RowPart **public** API 与 Cell 共享同一 `Configuration` token。

---

## 11. 与 TabBarFilter / 筛选面板

| 场景 | 建议 |
|------|------|
| TabBarFilter 单列/双列文本选项 | 继续 `FKTabBarFilterListCellStyle` — **不用** CellKit |
| 筛选面板需预览「用户行样式」 | Panel VC 内嵌 `UITableView` + `FKUserListCell` |
| 列表页：TabBarFilter + 业务列表 | 同一 VC：filter 在外层 chrome；列表用 ListKit + CellKit |

**原则：** TabBarFilter **不** 依赖 CellKit；CellKit 文档仅描述 **可选** 组合。

---

## 12. v1 预设 Cell 目录

### 12.1 TableView Cells（P0）

| Cell | 典型场景 | Leading | Center | Trailing | 备注 |
|------|----------|---------|--------|----------|------|
| **`FKUserListCell`** | IM、通讯录、评论作者 | `FKAvatar` + presence | 标题 + 副标题 | 时间 / 未读 / `FKTag` | P0 首发 |
| **`FKOrderListCell`** | 订单列表、工单 | 可选 icon | 单号 + 摘要 | `FKStatusPill` | 支持 copy chip 展开 |
| **`FKNotificationListCell`** | 系统通知、活动 | `FKIconView` / symbol | 标题 + 摘要 + 时间 | 未读点 | 多行摘要 truncate |
| **`FKSettingsProfileCell`** | 设置页头部账号行 | 大 Avatar | 昵称 + 账号 | chevron | 非 ListKit preset 的补充 |

### 12.2 CollectionView Cells（P0）

| Cell | 典型场景 | 布局 |
|------|----------|------|
| **`FKProductGridCell`** | 电商网格 | 图 + 标题 + 价格 + 可选 `FKTag` |
| **`FKMediaTileCell`** | 相册、附件 | 方形图 + 可选时长/选中勾 |

### 12.3 v1.1+ 候选（非 v1 阻塞）

| Cell | 场景 |
|------|------|
| `FKFeedContentCell` | 社交 feed 多行正文 + 九宫格图 |
| `FKCommentThreadCell` | 缩进评论树 |
| `FKAddressListCell` | 收货地址 + 默认 Tag |
| `FKPaymentMethodCell` | 支付方式选择 |

---

## 13. 行内子视图（Row Parts）

### 13.1 v1 RowParts

| 类型 | 路径 | 职责 |
|------|------|------|
| `FKUserListLeadingView` | `RowParts/User/` | Avatar + 主/副标题 |
| `FKUserListTrailingView` | `RowParts/User/` | 时间 label + 未读 badge |
| `FKOrderMetaRowView` | `RowParts/Order/` | CopyChip + StatusPill |
| `FKTagRowView` | `RowParts/Common/` | 水平 `FKTag` 列表（商品标签） |

### 13.2 RowPart API 形状

```swift
public struct FKUserListLeadingConfiguration: Equatable, Sendable {
  public var avatarSize: FKAvatarSize
  public var spacing: CGFloat
  public var showsPresenceIndicator: Bool
  public var titleFont: UIFont
  public var subtitleFont: UIFont
}

@MainActor
public final class FKUserListLeadingView: UIView {
  public var configuration: FKUserListLeadingConfiguration
  public func apply(_ model: FKUserListLeadingDisplayModel)
  public func prepareForReuse()
}
```

---

## 14. 配置、主题与外观 Preset

### 14.1 分层配置

```swift
public struct FKUserListCellConfiguration: Equatable, Sendable {
  public var leading: FKUserListLeadingConfiguration
  public var trailing: FKUserListTrailingConfiguration
  public var contentInsets: UIEdgeInsets
  public var showsSeparator: Bool
  public var selectedBackgroundColor: UIColor
}

public enum FKCellKitDefaults {
  public static var userListCell: FKUserListCellConfiguration { … }
  public static var orderListCell: FKOrderListCellConfiguration { … }
  public static var productGridCell: FKProductGridCellConfiguration { … }
}
```

### 14.2 与 FKTheme 关系

- v1：Cell 使用 **系统动态色** + `FKCellKitDefaults`。
- v1.1+：若 FKTheme 提供 semantic token，Defaults 读取 theme — **不** 在 Cell 内硬编码 brand hex。

### 14.3 卡片 vs 平铺

继承 `FKBaseTableViewCell` 的 `cornerRadius` / `shadow`：

| 模式 | 配置 |
|------|------|
| **Inset 卡片行** | `containerInsets` + `cornerRadius` + 轻 shadow |
| **全宽分隔行** | `containerInsets = .zero`；依赖 `FKDivider` / separator |

每种 Cell 文档化 **推荐** 模式；Defaults 提供两种 preset。

---

## 15. 生命周期、可见性与性能

### 15.1 Reuse 清单（每个 Cell 必须）

- [ ] `FKAvatar` / `FKImageView` 取消进行中的加载
- [ ] 清空 `FKTag` / `FKStatusPill` 动态内容
- [ ] 重置 `accessibilityLabel`
- [ ] 停止 Marquee（若使用 `FKMarqueeLabel`）

### 15.2 可见性（对齐 ListKit v2）

CellKit 定义 **可选** 内部协议：

```swift
@MainActor
public protocol FKListCellVisibilityHandling: AnyObject {
  func cellWillDisplay()
  func cellDidEndDisplaying()
}
```

由 ListKit delegate 转发（App 或 CellKit VC helper）— **v1** 可在 Examples 演示；**v1.1** 提供 `FKCellKitVisibilityForwarder`。

### 15.3 Prefetch

含 `avatarURL` / 商品图的 Cell：

```swift
extension FKUserListCell: FKListImagePrefetchProviding {
  public static func prefetchURLs(for item: FKUserListItem) -> [URL] {
    item.avatarURL.map { [$0] } ?? []
  }
}
```

List 层使用 `FKListImagePrefetchHelper` — CellKit **不** 自建 prefetch 管理器。

### 15.4 高度

| Cell 类型 | 策略 |
|-----------|------|
| 固定高度行 | `static let preferredRowHeight: CGFloat` |
| 动态文本 | Auto Layout + ListKit `estimatedRowHeight`；v1.1 `FKListHeightCache` |
| Grid | Collection layout item size 来自 `FKProductGridCellConfiguration` |

---

## 16. 骨架屏与空态协同

| 阶段 | 行为 |
|------|------|
| ListKit `presetRows` skeleton | 可用 ListKit 通用 skeleton cell |
| CellKit 定制 skeleton（v1.1） | `FKSkeletonTableViewCell` 子类 mimic `FKUserListCell` 布局 |
| 空态 | **VC 层** `FKListEmptyConfiguration` / Base `syncListEmptyState` — Cell **不参与** |

**禁止** Cell 内嵌 empty overlay。

---

## 17. 无障碍与 Dynamic Type

- 每个 Cell 合并 accessibility：标题 + 副标题 + 状态（如未读数）→ 合理 `accessibilityLabel`。
- `FKTag` / Pill 作为 trait `.button` 或 static text 的决策与 Widgets 文档一致。
- 支持 **Dynamic Type**：RowPart 使用 `UIFontMetrics` / preferred font；Avatar size 可随 category 阶梯放大（有上限）。
- 选中/highlight 对比度满足 WCAG — 使用 `FKCellKitDefaults` 动态色。

---

## 18. 业务枚举映射模式

CellKit **可** 提供纯 Swift mapper（无 UIKit），App 复用：

```swift
public enum FKOrderStatusMapper {
  public static func statusPillStyle(for status: String) -> FKStatusPillStyle { … }
  public static func localizedTitle(for status: String) -> String {
    FKI18n…
  }
}
```

- 领域 enum **定义在 App**；CellKit 仅接受 **已映射** 的 DisplayModel 或 string key。
- **禁止** CellKit 依赖 App 模块。

---

## 19. 源码目录结构

```text
Sources/FKBusinessKit/Components/CellKit/
├── README.md                           # 英文：目录图 + ListKit 快速开始
├── Public/
│   ├── Core/
│   │   ├── FKCellKitDefaults.swift
│   │   ├── FKCellKitListRegistration.swift
│   │   ├── FKCellKitListItemFactory.swift
│   │   └── FKListCellVisibilityHandling.swift
│   ├── Configuration/
│   │   ├── FKUserListCellConfiguration.swift
│   │   └── …
│   ├── Models/
│   │   ├── FKUserListItem.swift
│   │   ├── FKOrderListItem.swift
│   │   └── FKTagDisplayModel.swift
│   ├── RowParts/
│   │   ├── User/
│   │   │   ├── FKUserListLeadingView.swift
│   │   │   └── FKUserListTrailingView.swift
│   │   ├── Order/
│   │   │   └── FKOrderMetaRowView.swift
│   │   └── Common/
│   │       └── FKTagRowView.swift
│   ├── Table/
│   │   ├── FKUserListCell.swift
│   │   ├── FKOrderListCell.swift
│   │   └── FKNotificationListCell.swift
│   └── Collection/
│       ├── FKProductGridCell.swift
│       └── FKMediaTileCell.swift
├── Internal/
│   └── FKCellKitLayoutMetrics.swift    # 共享间距常量
└── Extension/
    └── FKListImagePrefetchProviding+CellKit.swift
```

`Package.swift` `exclude:` 加入 `Components/CellKit/README.md`。

---

## 20. FKBusinessKitExamples 场景

路径建议：`Examples/.../FKBusinessKit/CellKit/`

| # | 场景 | 验证点 |
|---|------|--------|
| 1 | **ListKitUserFeed** | `FKDiffableTableViewController` + `FKUserListCell` + refresh/load-more |
| 2 | **ListKitOrderList** | `FKOrderListCell` + `reconfigureItems` 更新状态 Pill |
| 3 | **BaseTableUserList** | `FKBaseTableViewController` 传统 dequeue 路径 |
| 4 | **ProductGrid** | Collection + `FKProductGridCell` + prefetch |
| 5 | **VisibilityAndPrefetch** | `willDisplay` / `FKListImagePrefetchProviding` |
| 6 | **TabBarFilterPlusUserList** | 筛选条 + CellKit 列表同屏 |
| 7 | **MixedPresetAndCustom** | 同一 ListKit snapshot：settings preset + `FKUserListCell` |

Examples **必须** `import FKBusinessKit`；英文 UI 文案。

---

## 21. 分阶段交付计划

### Phase 1 — 基础（v1.0）

| 交付 | 说明 |
|------|------|
| 目录 + README | 骨架与 API 索引 |
| `FKUserListCell` + RowParts | P0 |
| `FKOrderListCell` | P0 |
| `FKProductGridCell` | P0 |
| `FKCellKitListRegistration` | ListKit 胶水 |
| Examples 1–3 | ListKit + Base 路径 |

**FKKit 最低版本：** `0.71.0`

### Phase 2 — 增强（v1.1）

| 交付 | 说明 |
|------|------|
| `FKNotificationListCell` | |
| CellKit skeleton cells | 对齐 ListKit `presetRows` |
| `FKCellKitVisibilityForwarder` | |
| `FKFeedContentCell` 原型 | |
| Examples 4–7 | |

### Phase 3 — 扩展（v2）

| 交付 | 说明 |
|------|------|
| 视频 feed Cell + `FKListVideoVisibilityCoordinator` | |
| SwiftUI wrapper（若需） | 基于 ListKit bridge |
| 更多领域 Cell（地址/支付） | 按 App 需求驱动 |

---

## 22. 反模式（禁止）

| 反模式 | 原因 |
|--------|------|
| 在 CellKit 实现 Diffable DataSource | 与 ListKit 重复 |
| 复制 `FKListPresetTableCell` 逻辑做「另一个 subtitle 行」 | 应用 ListKit preset |
| Subclass `FKChip` / `FKAvatar` 改绘制 | 破坏 Widget 契约 |
| Cell `configure` 内发起网络 | 违反 ListKit / Pluggable 规则 |
| 在 CellKit 放 BusinessKit.shared / 埋点 | 层次污染；由 VC/App 处理 |
| 每个 App 复制粘贴 UserList 布局 | 应提取 CellKit |
| CellKit 依赖 App  target | 依赖方向错误 |
| 为 Cell 单独 SPM module | 保持 `FKBusinessKit` 单 target |

---

## 23. FKCoreKit 复用要求

| 能力 | 必须使用 | 禁止 |
|------|----------|------|
| Cell 协议 | `FKListTableCellConfigurable` 等 | 自定义 configure 协议 |
| 图片 | `FKImageView` / Widget 内置加载 | URLSession in Cell |
| 字符串/日期 | FKCoreKit Extension、`FKI18n` | 硬编码 |
| 防抖/异步 | `FKDebouncer`、取消 token | 裸 Timer |
| 布局 | Auto Layout；复用 `FKBaseReusableCellCore` | 手写 frame 为主 |

---

## 24. 待决问题

| ID | 问题 | 建议 |
|----|------|------|
| Q1 | 是否需要 `FKCellKitTableCell` 中间基类？ | v1 先做 2 个 Cell 后决定；若 metrics 重复再提取 |
| Q2 | RowPart 是否单独对外 vs 仅 Cell 内部？ | Leading/Trailing **public**；仅 Cell 使用的子视图 **internal** |
| Q3 | 订单 enum mapper 放 CellKit 还是 App？ | 通用状态 key → CellKit mapper；领域 enum → App |
| Q4 | 是否与 Widgets 文档 `ListWidgets/` 合并？ | **合并入 CellKit**；废弃独立 `ListWidgets` 目录名 |
| Q5 | Collection compositional layout 谁提供？ | ListKit `FKListCollectionLayoutPreset` + Cell 固定 item size |
| Q6 | 是否在 CellKit 包装 `FKDiffableTableViewController` 子类？ | **否** v1；Examples 演示组合即可 |

---

## 25. 修订历史

| 日期 | 变更 |
|------|------|
| 2026-06-16 | 初版：定位、ListKit/Base/Widgets 集成、v1 Cell 目录、分阶段计划 |

---

## 相关文档

- [FKWidgets-Integration_DESIGN.md](FKWidgets-Integration_DESIGN.md) — Widgets 组合边界
- [FKKit FKListKit_DESIGN.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKListKit_DESIGN.md) — ListKit 本体
- [FKKit FKListKit_ROADMAP.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKListKit_ROADMAP.md) — ListKit v2–v4
- [Base README](../Sources/FKBusinessKit/Components/Base/README.md) — FKBase*Cell / Controller
- [TabBarFilter README](../Sources/FKBusinessKit/Components/TabBarFilter/README.md)
