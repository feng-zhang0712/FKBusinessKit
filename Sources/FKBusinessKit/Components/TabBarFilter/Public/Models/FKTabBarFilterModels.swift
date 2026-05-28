import Foundation
import FKUIKit

/// Stable identifier for filter rows, sections, and categories.
public struct FKTabBarFilterID: Hashable, Sendable, RawRepresentable {
  public let rawValue: String
  public init(rawValue: String) { self.rawValue = rawValue }
}

/// Single vs multiple selection for a section.
public enum FKTabBarFilterSelectionMode: Sendable {
  case single
  case multiple

  /// Combines tab-level multi-select with each section’s ``FKTabBarFilterSection/selectionMode``.
  public static func effective(
    requested: FKTabBarFilterSelectionMode,
    allowsMultipleFromTab: Bool
  ) -> FKTabBarFilterSelectionMode {
    (allowsMultipleFromTab && requested == .multiple) ? .multiple : .single
  }
}

/// How taps on a **titled** right-hand section header behave in ``FKTabBarFilterTwoColumnListViewController`` and
/// ``FKTabBarFilterTwoColumnGridViewController``.
///
/// Modes are mutually exclusive: pick exactly one. ``standard`` matches passive UIKit section titles on the list panel
/// (or a non-interactive collection header on the grid).
public enum FKTabBarFilterTwoColumnRightSectionHeaderBehavior: Sendable, Hashable {
  /// Title only; header is not interactive.
  case standard
  /// Tap toggles ``FKTabBarFilterSection/isCollapsed`` for that section.
  case togglesSectionCollapse
  /// Tap selects the section as a header row: clears item selections and forwards ``FKTabBarFilterPanelSelection``.
  case selectableSectionHeader
}

/// Payload emitted by a panel when the user changes the selection (before host adds tab id / panel kind).
public struct FKTabBarFilterPanelSelection: Sendable {
  public let sectionID: FKTabBarFilterID?
  public let item: FKTabBarFilterOptionItem
  public let effectiveSelectionMode: FKTabBarFilterSelectionMode

  public init(sectionID: FKTabBarFilterID?, item: FKTabBarFilterOptionItem, effectiveSelectionMode: FKTabBarFilterSelectionMode) {
    self.sectionID = sectionID
    self.item = item
    self.effectiveSelectionMode = effectiveSelectionMode
  }
}

/// Full selection event for a strip tab (after the panel model has been updated).
public struct FKTabBarFilterSelectionContext<TabID: Hashable> {
  public let tabID: TabID
  public let panelKind: FKTabBarFilterPanelKind
  public let sectionID: FKTabBarFilterID?
  public let item: FKTabBarFilterOptionItem
  public let effectiveSelectionMode: FKTabBarFilterSelectionMode

  public init(tabID: TabID, panelKind: FKTabBarFilterPanelKind, selection: FKTabBarFilterPanelSelection) {
    self.tabID = tabID
    self.panelKind = panelKind
    self.sectionID = selection.sectionID
    self.item = selection.item
    self.effectiveSelectionMode = selection.effectiveSelectionMode
  }
}

/// One selectable row, chip, or grid cell in a filter panel.
public struct FKTabBarFilterOptionItem: Hashable, Sendable {
  public let id: FKTabBarFilterID
  public var title: String
  public var subtitle: String?
  /// Rich text title used when present; plain `title` acts as fallback.
  public var attributedTitle: AttributedString?
  /// Rich text subtitle used when present; plain `subtitle` acts as fallback.
  public var attributedSubtitle: AttributedString?
  public var isSelected: Bool
  public var isEnabled: Bool

  public init(
    id: FKTabBarFilterID,
    title: String,
    subtitle: String? = nil,
    attributedTitle: AttributedString? = nil,
    attributedSubtitle: AttributedString? = nil,
    isSelected: Bool = false,
    isEnabled: Bool = true
  ) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.attributedTitle = attributedTitle
    self.attributedSubtitle = attributedSubtitle
    self.isSelected = isSelected
    self.isEnabled = isEnabled
  }
}

/// A titled group of options inside a panel.
public struct FKTabBarFilterSection: Hashable, Sendable {
  public let id: FKTabBarFilterID
  public var title: String?
  public var selectionMode: FKTabBarFilterSelectionMode
  /// When `true`, two-column list/grid panels hide that section’s option rows until the user expands it from the section header (when ``FKTabBarFilterTwoColumnRightSectionHeaderBehavior/togglesSectionCollapse`` is configured).
  public var isCollapsed: Bool
  public var items: [FKTabBarFilterOptionItem]

  public init(
    id: FKTabBarFilterID,
    title: String? = nil,
    selectionMode: FKTabBarFilterSelectionMode,
    items: [FKTabBarFilterOptionItem],
    isCollapsed: Bool = false
  ) {
    self.id = id
    self.title = title
    self.selectionMode = selectionMode
    self.items = items
    self.isCollapsed = isCollapsed
  }
}

/// Left column categories and right-hand sections keyed by category id.
public struct FKTabBarFilterTwoColumnModel: Hashable, Sendable {
  public struct Category: Hashable, Sendable {
    public let id: FKTabBarFilterID
    public var title: String
    public var isSelected: Bool

    public init(id: FKTabBarFilterID, title: String, isSelected: Bool = false) {
      self.id = id
      self.title = title
      self.isSelected = isSelected
    }
  }

  public var categories: [Category]
  public var sectionsByCategoryID: [FKTabBarFilterID: [FKTabBarFilterSection]]

  public init(categories: [Category], sectionsByCategoryID: [FKTabBarFilterID: [FKTabBarFilterSection]]) {
    self.categories = categories
    self.sectionsByCategoryID = sectionsByCategoryID
  }
}

