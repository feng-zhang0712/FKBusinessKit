# FKBusinessKit × FKUIKit Widgets — 组合用法设计片段

FKBusinessKit 如何**组合** FKKit **FKUIKit Widgets**（小组件库）的指导片段：界定边界、推荐集成模式、可选薄封装与 Examples 约定。

**文档类型：** 设计片段（对 FKBusinessKit 实现者具有规范约束力；**非** Widgets 本体 API 规范）  
**状态：** 草案  
**Widgets 本体规范：** [FKKit `FKSmallComponents_DESIGN.md`](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKSmallComponents_DESIGN.md) 及下属模块设计文档  
**FKBusinessKit 前提：** `import FKBusinessKit`（re-export `FKCoreKit` + `FKUIKit`）

---

## 目录

- [1. 定位与边界](#1-定位与边界)
- [2. 依赖与版本](#2-依赖与版本)
- [3. 分层模型](#3-分层模型)
- [4. 与现有 BusinessKit 组件的关系](#4-与现有-businesskit-组件的关系)
- [5. 推荐组合模式](#5-推荐组合模式)
- [6. 可选薄封装（BusinessKit 新增）](#6-可选薄封装businesskit-新增)
- [7. 反模式（禁止）](#7-反模式禁止)
- [8. FKCoreKit 复用（强制）](#8-fkcorekit-复用强制)
- [9. 建议目录与命名](#9-建议目录与命名)
- [10. FKBusinessKitExamples 场景](#10-fkbusinesskitexamples-场景)
- [11. 待决问题](#11-待决问题)
- [12. 修订历史](#12-修订历史)

---

## 1. 定位与边界

### 1.1 一句话

**Widgets 在 FKUIKit 实现；FKBusinessKit 只做「屏幕级/流程级」编排与业务预设，不复制胶囊/头像/状态点源码。**

### 1.2 职责对照

| 层级 | 仓库 / 模块 | 职责 | Widgets 相关 |
|------|-------------|------|--------------|
| 基础 | FKCoreKit | Extension、Async、I18n、Network… | 禁止在 Business 重复 |
| UI 原子 | **FKUIKit / Widgets** | `FKChip`、`FKTag`、`FKAvatar`、`FKStatusPill`… | **唯一实现处** |
| 业务复合 | **FKBusinessKit** | `Base` VC、`TabBarFilter`、（可选）行模板/筛选预设 | **import + 布局 + 状态绑定** |
| App | 宿主工程 | 页面 VM、路由、领域枚举 | 映射到 Widget 配置 |

### 1.3 何时在 BusinessKit 加代码 vs 直接用 FKUIKit

| 场景 | 做法 |
|------|------|
| 列表 Cell 里一个 Avatar + 两行标题 | 宿主或 Cell 内直接 `FKAvatar` + `UIStackView` |
| 全 App 统一的「用户行 leading」外观 | BusinessKit **`FKUserListLeadingView`**（薄封装，见 §6.1） |
| 筛选：行内多选 Chip | 直接 `FKChipGroup` |
| 筛选：Tab 条 + 锚点弹出复杂面板 | **`FKTabBarFilter`**；面板**内**可再放 `FKChipGroup` |
| 订单详情「单号 + 复制」 | 直接 `FKCopyChip` |
| 首页公告滚动条 | 直接 `FKMarqueeLabel` |

**判定启发式：** 若封装仅转发 FKUIKit API、无 Business 特有状态机 → **不必**进 BusinessKit；若 ≥2 个 Widget + Base/Filter 生命周期绑定且全 App 复用 → **值得**薄封装。

---

## 2. 依赖与版本

### 2.1 依赖方向（不可反转）

```text
FKCoreKit ← FKUIKit ← FKBusinessKit ← App
```

- FKBusinessKit **不得**新增依赖让 FKUIKit 引用 BusinessKit。
- Widgets 实现 **仅**出现在 `FKKit/Sources/FKUIKit/`。

### 2.2 版本对齐

| 包 | 说明 |
|----|------|
| **FKKit** | Widgets 落地后，`Package.swift` / podspec **最低版本**随 adopted API bump（与 TabBarFilter 对 `FKSheetPresentationController` 的做法一致） |
| **FKBusinessKit** | `from: "0.x.0"` 声明所需最低 FKKit；README 维护对照表 |

BusinessKit 薄封装应通过 **FKUIKit 公开配置**（`FKChipDefaults`、`FKAvatarDefaults` 等）做全局 preset，**避免** subclass FKUIKit Internal 类型。

---

## 3. 分层模型

```text
┌─────────────────────────────────────────────────────────────┐
│ App ViewController / ViewModel                               │
│  业务枚举 → 映射为 FKChipItem / FKTagVariant / FKStatusPillStyle │
└────────────────────────────┬────────────────────────────────┘
                             │ 绑定 selectedIDs、imageURL…
┌────────────────────────────▼────────────────────────────────┐
│ FKBusinessKit（可选）                                        │
│  FKUserListLeadingView · FKInlineFilterBar · FKOrderMetaRow   │
│  FKBaseTableViewController + supplementary ChipGroup         │
│  FKTabBarFilter 面板内容 VC                                   │
└────────────────────────────┬────────────────────────────────┘
                             │ 持有、约束、组合
┌────────────────────────────▼────────────────────────────────┐
│ FKUIKit Widgets                                              │
│  FKAvatar · FKChipGroup · FKTag · FKStatusPill · FKCopyChip… │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│ FKCoreKit + 邻域 FKUIKit（FKImageView · FKBadge · FKToast）  │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. 与现有 BusinessKit 组件的关系

### 4.1 `Base`（`FKBaseViewController` 族）

| 能力 | 与 Widgets 组合方式 |
|------|---------------------|
| 列表 + 空态/骨架 | `FKBaseTableViewController` / `FKBaseCollectionViewController`；Cell 内嵌 Widgets，**不**在 Base 内硬编码 Widget 类型 |
| 下拉刷新 / 加载更多 | 刷新完成后更新 VM → 驱动 `FKChipGroup.chips` / 列表 diff |
| 搜索 | `FKBaseSearchIntegration` + 搜索框下方 **`FKChipGroup`（suggestion/input 模式）** 作快捷筛选 |
| 导航栏头像 | `viewWillAppear` 中配置 `navigationItem.leftBarButtonItem` + 容器内 **`FKAvatar` `.s`** |

Base **不提供** Widget 工厂方法；仅在 Examples 演示「Base 子类 + Widget 子视图」标准布局。

### 4.2 `TabBarFilter`

| 维度 | TabBarFilter | FKChipGroup |
|------|--------------|-------------|
| UX | Tab 条 + **锚点 Sheet 面板** | **行内**胶囊，无 Sheet |
| 数据 | `FKTabBarFilterTab` + PanelFactory | `[FKChipItem]` + `selectedIDs` |
| 典型 | 多维度筛选（价格区间表单、Sort 列表） | 快速标签筛选（「包邮」「新品」） |

**推荐并存（同一列表页）：**

```text
┌──────────────────────────────────────┐
│ FKTabBarFilter（排序 · 价格 · 更多） │  ← BusinessKit
├──────────────────────────────────────┤
│ FKChipGroup 横滚（包邮 / 现货 / VIP）│  ← FKUIKit Widgets
├──────────────────────────────────────┤
│ 列表                                  │
└──────────────────────────────────────┘
```

**面板内：** `FKTabBarFilter` 自定义 Panel VC 的 `view` 中可嵌入 `FKChipGroup`（多选属性）+ `FKButton`（确定），面板工厂留在 BusinessKit `Public/Panels/`，Chip 仍来自 FKUIKit。

### 4.3 与未来 `FKListKit` 的关系

ListKit 落地后，BusinessKit 列表页优先：

- **Preset row**：ListKit leading/trailing 槽位填 Widgets；
- **Base 子类**：在 `cellForRow` / ListKit preset 配置里组合 `FKAvatar` + `FKTag`。

BusinessKit **不** fork ListKit Cell 渲染器。

---

## 5. 推荐组合模式

### 5.1 用户列表行（IM / 通讯录 / 评论）

```swift
// 宿主 Cell 或 BusinessKit FKUserListLeadingView
let avatar = FKAvatar(configuration: .presets.listRow) // FKUIKit preset
avatar.setDisplayName(user.name)
avatar.setImageURL(user.avatarURL, placeholder: nil)
// presence、badge 经 FKAvatar configuration + FKBadgeController

let stack = UIStackView(arrangedSubviews: [avatar, titleLabel, subtitleLabel])
```

- Trailing：`FKTag`（角色）或 `FKStatusPill`（订单态）二选一，遵循 Widgets 决策树。
- **禁止**在 BusinessKit 重写首字母/圆角/加载逻辑。

### 5.2 商品/内容卡片

```swift
let tagRow = UIStackView()
tags.forEach { model in
  let tag = FKTag()
  tag.title = model.title
  tag.variant = model.isPromo ? .brand : .neutral
  tagRow.addArrangedSubview(tag)
}
```

促销与分类只用 **`FKTag`**；库存/物流状态用 **`FKStatusPill`**，不混用语义色。

### 5.3 行内筛选条 + 列表刷新

```swift
final class CatalogViewController: FKBaseCollectionViewController {
  private let filterBar = FKChipGroup()
  private var selectedFilters: Set<String> = []

  override func setupUI() {
    filterBar.selectionMode = .multiple(max: 5)
    filterBar.chips = viewModel.chipItems
    filterBar.onSelectionChange = { [weak self] ids in
      self?.selectedFilters = ids
      self?.viewModel.applyFilters(ids)
      self?.triggerRefresh() // Base 刷新协调器
    }
    // 约束：filterBar 在 collectionView 上方
  }
}
```

VM → `[FKChipItem]` 映射放 App 或 BusinessKit **Mapper**（纯 Swift、无 UIKit 时可测）。

### 5.4 订单/工单详情元信息行

```swift
let orderIdChip = FKCopyChip()
orderIdChip.text = viewModel.displayOrderNo   // 截断展示
orderIdChip.copyText = viewModel.fullOrderNo  // 完整复制
// feedback.toast 走 FKCopyChip 配置 → FKToast
```

### 5.5 资料页头（Profile）

```swift
let avatar = FKAvatar(configuration: .presets.profileHeader)
avatar.configuration.layout.size = .xl(72)
// showsPresenceIndicator + presenceState
// Story 环、verified badge 经 FKAvatar 配置 + FKBadge

let group = FKAvatarGroup()
group.avatars = viewModel.collaborators.map { .init(id: $0.id, ...) }
group.onOverflowTap = { [weak self] in self?.showMemberList() }
```

### 5.6 首页公告

```swift
let marquee = FKMarqueeLabel()
marquee.text = announcement.title
// 尊重 Reduce Motion；BusinessKit 不负责滚动驱动，仅布局
```

---

## 6. 可选薄封装（BusinessKit 新增）

> v1 **不强制**交付以下类型；当 ≥2 个 App 重复同一布局时再提取。提取时仍 **只组合 FKUIKit 公开 API**。

### 6.1 `FKUserListLeadingView`（建议）

| 项 | 说明 |
|----|------|
| **路径** | `Sources/FKBusinessKit/Components/ListWidgets/Public/` |
| **职责** | 固定布局：`FKAvatar`（`.s`）+ 主/副标题 `UILabel` 栈 |
| **配置** | `FKUserListLeadingConfiguration`：间距、是否显示 presence、标题样式 token |
| **非目标** | 不内置 URL 加载策略（交给 `FKAvatar`）；不做 trailing Tag |

### 6.2 `FKInlineFilterBar`（建议）

| 项 | 说明 |
|----|------|
| **职责** | 包装 `FKChipGroup` + 默认 `horizontalScroll` + 与 `FKBaseRefreshCoordinator` 的「筛选变更 → 刷新」胶水 |
| **API** | `chips`、`selectedIDs` 转发；`onFilterChange: (Set<String>) -> Void` |
| **非目标** | 不替代 `FKTabBarFilter` |

### 6.3 `FKOrderMetaRow`（可选，领域较强）

| 项 | 说明 |
|----|------|
| **职责** | `FKCopyChip` + 可选 `FKStatusPill` 水平排列 |
| **注意** | 若仅单一 App 使用，放 App 模块即可，**不必**进 BusinessKit |

### 6.4 业务枚举映射（推荐模式，非必须新类型）

```swift
// BusinessKit 或 App — 纯 Swift
enum OrderStatus: String {
  case pending, shipped, failed
  func statusPillStyle() -> FKStatusPillStyle { ... }
  func localizedTitle() -> String { FKI18n... }
}
```

映射函数 **不得**复制 Widget 渲染；只产出 FKUIKit 已有 enum/配置。

---

## 7. 反模式（禁止）

| 反模式 | 原因 |
|--------|------|
| 在 BusinessKit 复制 `FKChip` / `FKAvatar` 源码 | 双份维护、FKCoreKit 复用失效 |
| Subclass `FKChip` 改绘制 | 破坏 Widget 配置契约；用 `configuration` + App 主题 |
| 在 `FKTabBarFilter` 内 reimplement 胶囊筛选 | 应用 `FKChipGroup` |
| BusinessKit 依赖 App 模块 | 依赖方向错误 |
| 为 Widget 单独 re-export 新 module | `import FKBusinessKit` 已 re-export FKUIKit |
| 在 BusinessKit 写 `URLSession` 拉头像 | 必须 `FKImageView` / `FKAvatar.setImageURL` |

---

## 8. FKCoreKit 复用（强制）

BusinessKit 组合层同样遵守：

- 字符串 / 日期 / 防抖：**FKCoreKit Extension、FKDebouncer**
- 文案：**FKI18n**（业务键可放 App bundle，通用键走 FKUIKitI18n）
- **禁止**在 BusinessKit 为 Widget 已有能力再写一套 helper

Widgets 模块设计文档中的「FKCoreKit 复用要求」在 Business 层 **同样适用**于胶水代码。

---

## 9. 建议目录与命名

```text
Sources/FKBusinessKit/Components/
├── Base/                    # 已有
├── TabBarFilter/            # 已有
└── ListWidgets/             # 可选：Widgets 薄封装（v1.1+）
    ├── README.md
    ├── Public/
    │   ├── FKUserListLeadingView.swift
    │   ├── FKInlineFilterBar.swift
    │   └── Configuration/
    └── Internal/
        └── FKWidgetLayoutPresets.swift   # 仅 Business 侧间距，非 Widget 渲染
```

- 组件名前缀仍 **`FK`**；领域词放中间（`UserList`、`InlineFilter`）。
- 每个薄封装一份 **英文** README（仓库规范）+ 链到本中文设计片段。

---

## 10. FKBusinessKitExamples 场景

路径建议：`Examples/.../FKBusinessKit/WidgetsIntegration/`

| # | 场景 | 验证点 |
|---|------|--------|
| 1 | `BaseTableWithChipFilter` | Base 表 + 顶部 ChipGroup + 刷新 |
| 2 | `TabBarFilterPlusInlineChips` | TabBarFilter 与 ChipGroup 同屏 |
| 3 | `FilterPanelWithChipGroup` | Panel VC 内 ChipGroup 多选 |
| 4 | `UserRowLeading` | Avatar + Presence + 双行标题 |
| 5 | `OrderDetailMeta` | CopyChip + StatusPill |
| 6 | `ProfileHeaderComposite` | XL Avatar + AvatarGroup |

Examples **必须** `import FKBusinessKit`，演示 Business 编排而非复制 Widget。

---

## 11. 待决问题

| ID | 问题 | 建议 |
|----|------|------|
| Q1 | v1 是否交付 ListWidgets 目录？ | 否；先 Examples 直组合，重复后再提取 |
| Q2 | 业务 I18n 键放哪？ | 领域文案 App；通用 Widget 文案 FKUIKit |
| Q3 | TabBarFilter 与 ChipGroup 选中态同步？ | 宿主 VM 单一数据源，禁止双写 |
| Q4 | ListKit 预设是否进 BusinessKit？ | ListKit 稳定后做 `FKBusinessListPresets` 再议 |

---

## 12. 修订历史

| 日期 | 变更 |
|------|------|
| 2026-06-10 | 初版组合用法设计片段 |

---

## 相关文档（FKKit 仓库）

- [FKSmallComponents_DESIGN.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKSmallComponents_DESIGN.md)
- [FKChip-FKTag-FKChipGroup_DESIGN.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKChip-FKTag-FKChipGroup_DESIGN.md)
- [FKAvatar-FKAvatarGroup-FKPresenceIndicator_DESIGN.md](https://github.com/feng-zhang0712/FKKit/blob/develop/docs/FKAvatar-FKAvatarGroup-FKPresenceIndicator_DESIGN.md)
- [FKBusinessKit Base README](../Sources/FKBusinessKit/Components/Base/README.md)
- [FKBusinessKit TabBarFilter README](../Sources/FKBusinessKit/Components/TabBarFilter/README.md)
