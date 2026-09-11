import UIKit

/// ListKit registration helpers for CommentKit row cells.
@MainActor
public enum FKCommentListRegistration {
  /// Registers ``FKCommentRowCell`` (``standard`` preset) on a diffable table controller.
  public static func registerCommentRowCell(on controller: FKDiffableTableViewController) {
    controller.register(FKCommentRowCell.self, forPayloadType: FKCommentItem.self)
  }

  /// Registers ``FKCommentCompactRowCell`` (``compact`` preset) on a diffable table controller.
  public static func registerCompactCommentRowCell(on controller: FKDiffableTableViewController) {
    controller.register(FKCommentCompactRowCell.self, forPayloadType: FKCommentItem.self)
  }

  /// Registers the row cell matching `layoutPreset`.
  public static func registerCommentRowCell(
    on controller: FKDiffableTableViewController,
    layoutPreset: FKCommentLayoutPreset
  ) {
    switch layoutPreset {
    case .standard:
      registerCommentRowCell(on: controller)
    case .compact:
      registerCompactCommentRowCell(on: controller)
    }
  }
}
