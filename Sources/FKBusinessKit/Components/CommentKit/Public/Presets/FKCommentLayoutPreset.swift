import Foundation

/// Named row / list layout skeletons for CommentKit.
///
/// Presets own Auto Layout structure; ``FKCommentKitConfiguration`` owns tokens and feature flags
/// within a preset. See `docs/FKCommentKit_DESIGN.md` §7.
public enum FKCommentLayoutPreset: String, Equatable, Sendable, CaseIterable {
  /// Feed-style row: avatar, author + timestamp header, body, bottom action stripe (like / reply / more).
  case standard
  /// Compact social-style row: author + trailing time → body → meta (like · Reply · more),
  /// indented replies with author ▸ reply-to composition. Product-agnostic (feeds, detail pages, sheets, …).
  case compact
}

extension FKCommentKitConfiguration {
  /// Builds a configuration with defaults matched to `preset`.
  ///
  /// - Parameter layoutPreset: Layout skeleton to apply.
  /// - Returns: A configuration whose ``layoutPreset`` and nested tokens match the skeleton.
  public static func configuration(for layoutPreset: FKCommentLayoutPreset) -> FKCommentKitConfiguration {
    switch layoutPreset {
    case .standard:
      var configuration = FKCommentKitConfiguration()
      configuration.layoutPreset = .standard
      return configuration
    case .compact:
      return FKCommentCompactDefaults.makeConfiguration()
    }
  }
}
