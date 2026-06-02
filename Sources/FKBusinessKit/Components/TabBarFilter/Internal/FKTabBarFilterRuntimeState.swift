import UIKit

@MainActor
final class FKTabBarFilterRuntimeState<TabID: Hashable> {
  weak var controller: FKTabBarFilterController<TabID>?
  var onSelection: FKTabBarFilterSelectionHandler<TabID>?
  private var titleOverrides: [TabID: String] = [:]

  func displayTitle(for id: TabID, fallback: @escaping () -> String) -> String {
    titleOverrides[id] ?? fallback()
  }

  func setTitleOverride(_ title: String, for id: TabID) {
    titleOverrides[id] = title
  }

  func removeTitleOverride(for id: TabID) {
    titleOverrides[id] = nil
  }

  func removeAllTitleOverrides() {
    titleOverrides.removeAll(keepingCapacity: false)
  }

  func dismissIfSingleSelect(mode: FKTabBarFilterSelectionMode) {
    guard mode == .single else { return }
    controller?.collapsePanel(animated: true)
  }
}
