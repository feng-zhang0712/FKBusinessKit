import UIKit
import FKUIKit
import FKBusinessKit

/// Builds a ``FKTabBarFilterPanelFactory`` bound to a shared ``FKTabBarFilterExampleState`` (no per-kind no-op parameters at call sites).
enum FKTabBarFilterExamplePanelFactoryBuilder {
  @MainActor
  static func makeFactory(
    bindingTo state: FKTabBarFilterExampleState,
    filterConfiguration: FKTabBarFilterConfiguration<String>,
    onTagsSelectionEmptied: (() -> Void)? = nil
  ) -> FKTabBarFilterPanelFactory {
    FKTabBarFilterPanelFactory(
      sourcesByPanelKind: [
        .hierarchy: .twoColumnList(
          model: { state.knowledgeModel },
          onChange: { state.knowledgeModel = $0 },
          configuration: .init(
            leftCellStyle: FKTabBarFilterExampleAppearance.panelSidebarListCellStyle,
            rightCellStyle: FKTabBarFilterExampleAppearance.panelListCellStyle
          )
        ),
        .dualHierarchy: .twoColumnGrid(
          model: { state.courseModel },
          onChange: { state.courseModel = $0 },
          configuration: .init(
            itemHeight: 36,
            itemColumns: 2,
            pillStyle: FKTabBarFilterExampleAppearance.panelPillStyle,
            rightSectionHeaderBehavior: .selectableSectionHeader
          )
        ),
        .gridPrimary: .chips(
          sections: { state.fileTypeSections },
          onChange: { state.fileTypeSections = $0 },
          configuration: .init(
            columns: 4,
            interitemSpacing: 8,
            lineSpacing: 10,
            contentInsets: .init(top: 10, left: 10, bottom: 10, right: 10),
            itemRowHeight: 38,
            pillStyle: FKTabBarFilterExampleAppearance.panelPillStyle
          )
        ),
        .gridSecondary: .chips(
          sections: { state.platformSections },
          onChange: { state.platformSections = $0 },
          configuration: .init(
            columns: 2,
            interitemSpacing: 8,
            lineSpacing: 10,
            contentInsets: .init(top: 10, left: 10, bottom: 10, right: 10),
            itemRowHeight: 38,
            pillStyle: FKTabBarFilterExampleAppearance.panelPillStyle
          )
        ),
        .tags: .chips(
          sections: { state.tagsSections },
          onChange: { newSections in
            state.tagsSections = newSections
            let selectedCount = newSections.flatMap(\.items).filter(\.isSelected).count
            if selectedCount == 0 {
              onTagsSelectionEmptied?()
            }
          },
          configuration: .init(
            columns: 2,
            interitemSpacing: 8,
            lineSpacing: 10,
            contentInsets: .init(top: 10, left: 10, bottom: 10, right: 10),
            itemRowHeight: 38,
            heightBehavior: .capped(maximum: 320, minimum: 80),
            pillStyle: FKTabBarFilterExampleAppearance.panelPillStyle
          )
        ),
        .singleList: .singleList(
          section: { state.sortSection },
          onChange: { state.sortSection = $0 },
          configuration: .init(
            rowHeight: 44,
            cellStyle: FKTabBarFilterListCellStyle(
              textAlignment: .center
            )
          )
        ),
      ],
      loadingTitle: filterConfiguration.panelLoadingTitle,
      wrapsPanelWithTopHairline: filterConfiguration.wrapsPanelWithTopHairline
    )
  }
}
