import FKBusinessKit
import UIKit

/// Catalog scenarios for CommentKit demos.
enum FKCommentKitExampleScenario: CaseIterable {
  case fullInteractive
  case pagination
  case emptyState
  case loadFailure
  case likeRollback
  case replyExpand
  case nestedSubReplies
  case replyToDifferentPeople
  case moreActions
  case submitFailure
  case readOnly
  case hiddenActions
  case expandableBody
  case composerLimits
  case updateRemoveAPI
  case customAppearance
  case listKitRow
  case buildingBlocks
  case layoutPresetStandard
  case layoutPresetCompact
  case longListStandard
  case longListCompact
  case compactInteractions
  case compactMetaComposer
  case compactListKitRow

  var title: String {
    switch self {
    case .fullInteractive: return "Full interactive thread"
    case .pagination: return "Refresh & load-more"
    case .emptyState: return "Empty state"
    case .loadFailure: return "Load failure & retry"
    case .likeRollback: return "Like + rollback"
    case .replyExpand: return "Reply & expand replies"
    case .nestedSubReplies: return "Nested sub-reply floors"
    case .replyToDifferentPeople: return "Reply to different people"
    case .moreActions: return "More: copy / report / delete"
    case .submitFailure: return "Submit failure"
    case .readOnly: return "Read-only (no composer)"
    case .hiddenActions: return "Hidden row actions"
    case .expandableBody: return "Expandable body"
    case .composerLimits: return "Composer limits"
    case .updateRemoveAPI: return "updateComment / removeComment"
    case .customAppearance: return "Custom strings & chrome"
    case .listKitRow: return "ListKit row registration"
    case .buildingBlocks: return "Action bar & composer views"
    case .layoutPresetStandard: return "Interactive list"
    case .layoutPresetCompact: return "Interactive list"
    case .longListStandard: return "Long list (scroll stress)"
    case .longListCompact: return "Long list (scroll stress)"
    case .compactInteractions: return "Like / expand / accessories"
    case .compactMetaComposer: return "Meta & composer flags"
    case .compactListKitRow: return "ListKit row"
    }
  }

  var subtitle: String {
    switch self {
    case .fullInteractive:
      return "DataSource/Delegate, likes, reply, row-tap reply, expand, composer send, author tap."
    case .pagination:
      return "Pull-to-refresh first page and load-more second page with id dedupe."
    case .emptyState:
      return "Successful empty page drives Base empty presentation."
    case .loadFailure:
      return "Transport failure with empty-state retry calling reloadComments()."
    case .likeRollback:
      return "Optimistic like then simulated failure + rollbackLike."
    case .replyExpand:
      return "Reply target banner, cancel reply, view/hide replies."
    case .nestedSubReplies:
      return "Deep chain floors 1→5 via nested View replies; indent capped by maxDepth=4."
    case .replyToDifferentPeople:
      return "replyTo chips for parent, sibling, and deeper floors that reply back to the root."
    case .moreActions:
      return "Copy pasteboard, report toast, delete → removeComment(id:)."
    case .submitFailure:
      return "Composer sending state then didFailSubmit keeps draft text."
    case .readOnly:
      return "showsComposer = false; reply still notifies delegate."
    case .hiddenActions:
      return "Hide like / reply / more; beginsReplyOnRowTap = false."
    case .expandableBody:
      return "Long body with FKExpandableText and row height updates."
    case .composerLimits:
      return "maxCharacterCount and maxContentHeight scrolling."
    case .updateRemoveAPI:
      return "Toolbar mutates first row via updateComment and removeComment."
    case .customAppearance:
      return "Custom FKCommentKitStrings, action bar colors, and avatar size."
    case .listKitRow:
      return "FKCommentListRegistration + FKCommentRowCell on Diffable ListKit (like + tap feedback)."
    case .buildingBlocks:
      return "Standalone action bar, compact like rail, and composer views."
    case .layoutPresetStandard:
      return "configuration(for: .standard) — feed-style skeleton."
    case .layoutPresetCompact:
      return "configuration(for: .compact) — meta time · Reply · like, capsule composer."
    case .longListStandard:
      return "200 mixed-length Standard rows for scroll jank checks (delay 0)."
    case .longListCompact:
      return "200 mixed-length Compact rows for scroll jank checks (delay 0)."
    case .compactInteractions:
      return "Row-tap reply, expand replies, avatar/author/long-press callbacks under compact."
    case .compactMetaComposer:
      return "Toggle showsMetaReplyButton / showsReplyTargetBanner / send chrome."
    case .compactListKitRow:
      return "FKCommentCompactRowCell registered on Diffable ListKit (like + tap feedback)."
    }
  }

  func makeViewController() -> UIViewController {
    switch self {
    case .listKitRow:
      return FKCommentKitListKitRowExampleViewController(layoutPreset: .standard)
    case .compactListKitRow:
      return FKCommentKitListKitRowExampleViewController(layoutPreset: .compact)
    case .buildingBlocks:
      return FKCommentKitBuildingBlocksExampleViewController()
    default:
      return FKCommentKitScenarioExampleViewController(scenario: self)
    }
  }
}
