import UIKit

/// Root navigation catalog for CommentKit examples.
enum FKCommentKitExampleCatalog {
  static var rootSections: [FKCommentKitExampleListSection] {
    [
      layoutPresetsSection,
      coreSection,
      interactionsSection,
      configurationSection,
      integrationSection,
    ]
  }

  /// Top-level: one cell per layout preset → second-level demo list.
  static var layoutPresetsSection: FKCommentKitExampleListSection {
    FKCommentKitExampleListSection(
      title: "Layout presets",
      rows: [
        FKCommentKitExampleListRow(
          title: "Standard",
          subtitle: "Feed-style row: author + timestamp header, bottom action stripe.",
          makeViewController: {
            FKCommentKitGroupedListHubViewController(
              title: "Standard",
              sections: standardPresetSections
            )
          }
        ),
        FKCommentKitExampleListRow(
          title: "Compact",
          subtitle: "Denser social-style row: author + trailing time, meta like · Reply · more, capsule composer.",
          makeViewController: {
            FKCommentKitGroupedListHubViewController(
              title: "Compact",
              sections: compactPresetSections
            )
          }
        ),
      ]
    )
  }

  static var standardPresetSections: [FKCommentKitExampleListSection] {
    [
      FKCommentKitExampleListSection(
        title: "Demos",
        rows: [
          row(.layoutPresetStandard),
          row(.longListStandard),
          row(.listKitRow),
        ]
      ),
    ]
  }

  static var compactPresetSections: [FKCommentKitExampleListSection] {
    [
      FKCommentKitExampleListSection(
        title: "Demos",
        rows: [
          row(.layoutPresetCompact),
          row(.longListCompact),
          row(.compactInteractions),
          row(.compactMetaComposer),
          row(.compactListKitRow),
        ]
      ),
    ]
  }

  static var coreSection: FKCommentKitExampleListSection {
    FKCommentKitExampleListSection(
      title: "Core flows",
      rows: [
        row(.fullInteractive),
        row(.pagination),
        row(.emptyState),
        row(.loadFailure),
      ]
    )
  }

  static var interactionsSection: FKCommentKitExampleListSection {
    FKCommentKitExampleListSection(
      title: "Interactions",
      rows: [
        row(.likeRollback),
        row(.replyExpand),
        row(.nestedSubReplies),
        row(.replyToDifferentPeople),
        row(.moreActions),
        row(.submitFailure),
        row(.updateRemoveAPI),
      ]
    )
  }

  static var configurationSection: FKCommentKitExampleListSection {
    FKCommentKitExampleListSection(
      title: "Configuration",
      rows: [
        row(.readOnly),
        row(.hiddenActions),
        row(.expandableBody),
        row(.composerLimits),
        row(.customAppearance),
      ]
    )
  }

  static var integrationSection: FKCommentKitExampleListSection {
    FKCommentKitExampleListSection(
      title: "Building blocks & ListKit",
      rows: [
        row(.buildingBlocks),
      ]
    )
  }

  private static func row(_ scenario: FKCommentKitExampleScenario) -> FKCommentKitExampleListRow {
    FKCommentKitExampleListRow(
      title: scenario.title,
      subtitle: scenario.subtitle,
      makeViewController: scenario.makeViewController
    )
  }
}
