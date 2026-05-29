import Foundation
import FKUIKit
import FKBusinessKit

/// Mutable filter models for examples; paired with ``FKTabBarFilterExamplePanelFactoryBuilder``.
@MainActor
final class FKTabBarFilterExampleState {
  var knowledgeModel: FKTabBarFilterTwoColumnModel?
  var courseModel: FKTabBarFilterTwoColumnModel?
  var fileTypeSections: [FKTabBarFilterSection] = []
  var platformSections: [FKTabBarFilterSection] = []
  var tagsSections: [FKTabBarFilterSection] = []
  var sortSection: FKTabBarFilterSection?

  init() {}

  /// All six panels populated (scrollable strip example).
  static func presetFullHub() -> FKTabBarFilterExampleState {
    let s = FKTabBarFilterExampleState()
    s.knowledgeModel = FKTabBarFilterExampleStaticData.catalogTwoColumn
    s.courseModel = FKTabBarFilterExampleStaticData.trainingTwoColumn
    s.fileTypeSections = FKTabBarFilterExampleStaticData.fileTypeSections
    s.platformSections = FKTabBarFilterExampleStaticData.platformSections
    s.tagsSections = FKTabBarFilterExampleStaticData.tagsSections
    s.sortSection = FKTabBarFilterExampleStaticData.sortSection
    return s
  }

  /// Equal-width strip: scope · training grid · tags.
  static func presetEqualBusiness() -> FKTabBarFilterExampleState {
    let s = FKTabBarFilterExampleState()
    s.courseModel = FKTabBarFilterExampleStaticData.trainingTwoColumn
    s.platformSections = FKTabBarFilterExampleStaticData.platformSections
    s.tagsSections = FKTabBarFilterExampleStaticData.tagsSections
    return s
  }

  /// Equal-width strip: browse list · formats · sort.
  static func presetEqualKnowledge() -> FKTabBarFilterExampleState {
    let s = FKTabBarFilterExampleState()
    s.knowledgeModel = FKTabBarFilterExampleStaticData.catalogTwoColumn
    s.fileTypeSections = FKTabBarFilterExampleStaticData.fileTypeSections
    s.sortSection = FKTabBarFilterExampleStaticData.sortSection
    return s
  }
}
