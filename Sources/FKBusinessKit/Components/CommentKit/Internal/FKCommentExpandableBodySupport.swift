import UIKit
import FKUIKit

/// Shared expandable-body styling and hit-testing for CommentKit row cells.
@MainActor
enum FKCommentExpandableBodySupport {
  /// Builds an ``FKExpandableTextConfiguration`` using CommentKit strings and row tokens.
  static func makeConfiguration(
    maxLines: Int,
    strings: FKCommentKitStrings,
    rowConfiguration: FKCommentRowCellConfiguration
  ) -> FKExpandableTextConfiguration {
    let font = rowConfiguration.resolvedExpandableBodyActionFont()
    let paragraph = NSMutableParagraphStyle()
    paragraph.paragraphSpacingBefore = rowConfiguration.expandableBodyActionSpacing
    paragraph.paragraphSpacing = rowConfiguration.expandableBodyActionSpacing

    let actionAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: rowConfiguration.expandableBodyActionColor,
      .paragraphStyle: paragraph,
    ]

    var configuration = FKExpandableTextConfiguration(collapseRule: .lines(maxLines))
    configuration.buttonPlacement = .trailingBottom
    configuration.interactionMode = .buttonOnly
    configuration.expandActionText = NSAttributedString(
      string: strings.expandBody,
      attributes: actionAttributes
    )
    configuration.collapseActionText = NSAttributedString(
      string: strings.collapseBody,
      attributes: actionAttributes
    )
    configuration.accessibility = .init(
      expandLabel: strings.expandBody,
      collapseLabel: strings.collapseBody
    )
    return configuration
  }

  /// Body attributes for the comment text (not the expand / collapse action).
  static func bodyAttributes(
    rowConfiguration: FKCommentRowCellConfiguration
  ) -> [NSAttributedString.Key: Any] {
    [
      .font: rowConfiguration.resolvedBodyFont(),
      .foregroundColor: rowConfiguration.bodyTextColor,
    ]
  }

  /// Returns `true` when `touch` lands on the expand / collapse action substring inside `label`.
  static func isTouchOnAction(
    _ touch: UITouch,
    in label: UILabel,
    expandAction: String,
    collapseAction: String
  ) -> Bool {
    guard let attributed = label.attributedText, attributed.length > 0 else { return false }
    let point = touch.location(in: label)
    guard label.bounds.contains(point) else { return false }

    let full = attributed.string as NSString
    var toggleRange = NSRange(location: NSNotFound, length: 0)
    for action in [expandAction, collapseAction] where !action.isEmpty {
      let range = full.range(of: action, options: .backwards)
      if range.location != NSNotFound {
        toggleRange = range
        break
      }
    }
    guard toggleRange.location != NSNotFound else { return false }

    let manager = NSLayoutManager()
    let container = NSTextContainer(size: label.bounds.size)
    container.lineFragmentPadding = 0
    container.maximumNumberOfLines = label.numberOfLines
    container.lineBreakMode = label.lineBreakMode
    manager.addTextContainer(container)
    let storage = NSTextStorage(attributedString: attributed)
    storage.addLayoutManager(manager)

    let glyphIndex = manager.glyphIndex(for: point, in: container)
    return NSLocationInRange(glyphIndex, toggleRange)
  }
}
