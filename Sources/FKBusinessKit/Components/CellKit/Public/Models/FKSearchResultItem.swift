import Foundation

/// A contiguous title segment with optional search-hit emphasis.
public struct FKSearchHighlightSegment: Equatable, Sendable {
  /// Segment text.
  public var text: String
  /// When `true`, renders with the highlight text color.
  public var isHighlighted: Bool

  /// Creates a highlight segment.
  public init(text: String, isHighlighted: Bool = false) {
    self.text = text
    self.isHighlighted = isHighlighted
  }
}

/// View model for ``FKSearchResultCell``.
public struct FKSearchResultItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Title segments with optional query-hit emphasis.
  public var titleSegments: [FKSearchHighlightSegment]
  /// Optional breadcrumb or category path.
  public var breadcrumbText: String?
  /// Optional trailing category tag title.
  public var categoryTagTitle: String?

  /// Creates a search result row item.
  public init(
    id: String,
    titleSegments: [FKSearchHighlightSegment],
    breadcrumbText: String? = nil,
    categoryTagTitle: String? = nil
  ) {
    self.id = id
    self.titleSegments = titleSegments
    self.breadcrumbText = breadcrumbText
    self.categoryTagTitle = categoryTagTitle
  }

  /// Convenience initializer for a plain title with one highlighted substring match.
  public init(
    id: String,
    title: String,
    highlightedQuery: String?,
    breadcrumbText: String? = nil,
    categoryTagTitle: String? = nil
  ) {
    self.id = id
    self.breadcrumbText = breadcrumbText
    self.categoryTagTitle = categoryTagTitle
    if let highlightedQuery,
       !highlightedQuery.isEmpty,
       let range = title.range(of: highlightedQuery, options: .caseInsensitive) {
      let before = String(title[..<range.lowerBound])
      let match = String(title[range])
      let after = String(title[range.upperBound...])
      var segments: [FKSearchHighlightSegment] = []
      if !before.isEmpty { segments.append(.init(text: before)) }
      segments.append(.init(text: match, isHighlighted: true))
      if !after.isEmpty { segments.append(.init(text: after)) }
      self.titleSegments = segments
    } else {
      self.titleSegments = [.init(text: title)]
    }
  }
}
