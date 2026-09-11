import UIKit

/// Resolves Dynamic Type fonts with an optional weight override.
enum FKCommentTypography {
  static func font(for textStyle: UIFont.TextStyle, weight: UIFont.Weight?) -> UIFont {
    let preferred = UIFont.preferredFont(forTextStyle: textStyle)
    guard let weight else { return preferred }
    var traits = (preferred.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
    traits[.weight] = weight
    let descriptor = preferred.fontDescriptor.addingAttributes([.traits: traits])
    return UIFont(descriptor: descriptor, size: preferred.pointSize)
  }
}
