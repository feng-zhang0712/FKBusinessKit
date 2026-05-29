import UIKit
import FKBusinessKit

/// Preset equal-width tab strips used by playground and anchored examples.
enum FKTabBarFilterEqualWidthTabSet: Int, CaseIterable {
  case commerce
  case library

  var menuTitle: String {
    switch self {
    case .commerce: return "Commerce"
    case .library: return "Library"
    }
  }

  var subtitle: String {
    switch self {
    case .commerce:
      return "Scope · catalog grid · multi-select tags."
    case .library:
      return "Browse · formats chips · sort list."
    }
  }

  func initialState() -> FKTabBarFilterExampleState {
    switch self {
    case .commerce: return FKTabBarFilterExampleState.presetEqualBusiness()
    case .library: return FKTabBarFilterExampleState.presetEqualKnowledge()
    }
  }

  func makeTabs() -> [FKTabBarFilterTab<String>] {
    switch self {
    case .commerce:
      return [
        .init(id: "scope", panelKind: .gridSecondary, title: "Scope"),
        .init(id: "catalog", panelKind: .dualHierarchy, title: "Catalog"),
        .init(
          id: "tags",
          panelKind: .tags,
          title: "Topics",
          subtitle: "Optional multi-select",
          allowsMultipleSelection: true
        ),
      ]
    case .library:
      return [
        .init(id: "browse", panelKind: .hierarchy, title: "Browse"),
        .init(id: "formats", panelKind: .gridPrimary, title: "Formats"),
        .init(id: "sort", panelKind: .singleList, title: "Sort"),
      ]
    }
  }
}
