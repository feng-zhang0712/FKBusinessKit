import UIKit
import FKUIKit
import FKBusinessKit

final class FKTabBarFilterSingleListPanelExampleHubViewController: FKTabBarFilterGroupedListHubViewController {
  init() {
    super.init(title: "Single-list panel examples", sections: Self.sections)
  }

  private static let sections: [FKTabBarFilterExampleListSection] = [
    ("Selection", [FKTabBarFilterSingleListPanelExampleCase.baselineSingle, .multipleSelection]),
    ("Cell content", [.subtitles, .attributedTitle, .disabledRow, .darkCellStyle]),
    ("Layout & hooks", [.showsFooter, .wideSeparatorInset, .configureCellAccessory, .tallRows]),
    ("Height", [.heightFixed, .heightCapped]),
    ("Callbacks", [.onChangeOnlyNoSelection]),
  ].map { title, cases in
    FKTabBarFilterExampleListSection(title: title, rows: cases.map(\.listRow))
  }
}

private extension FKTabBarFilterSingleListPanelExampleCase {
  var listRow: FKTabBarFilterExampleListRow {
    FKTabBarFilterExampleListRow(title: menuTitle, subtitle: menuSubtitle) {
      FKTabBarFilterSingleListPanelExampleDetailViewController(exampleCase: self)
    }
  }
}
