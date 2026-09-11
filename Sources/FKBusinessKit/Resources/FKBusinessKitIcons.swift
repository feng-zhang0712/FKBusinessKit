import UIKit

/// Shared icon catalog shipped with FKBusinessKit (`Resources/Assets.xcassets`).
///
/// Prefer these assets over SF Symbols so apps and future components share one visual set.
public enum FKBusinessKitIcon: String, Equatable, Sendable, CaseIterable {
  /// Outline heart (like / unliked).
  case heartOutline = "fk_heart_outline"
  /// Filled heart (liked).
  case heartFill = "fk_heart_fill"
  /// Chat bubble (reply / comment).
  case chat = "fk_chat"
  /// Horizontal more (⋯).
  case moreHorizontal = "fk_more_horizontal"
  /// Chevron pointing right (reply-to separator).
  case chevronRight = "fk_chevron_right"
  /// Chevron pointing down (expand).
  case chevronDown = "fk_chevron_down"
  /// Chevron pointing up (collapse).
  case chevronUp = "fk_chevron_up"
  /// Image / gallery accessory.
  case image = "fk_image"
  /// Mention (@) accessory.
  case mention = "fk_mention"
  /// Smile / emoji accessory.
  case smile = "fk_smile"
}

/// Loads ``FKBusinessKitIcon`` images from the package resource bundle.
@MainActor
public enum FKBusinessKitIcons {
  /// Bundle that contains ``Assets.xcassets``.
  public static var bundle: Bundle {
    #if SWIFT_PACKAGE
    Bundle.module
    #else
    if
      let url = Bundle(for: FKBusinessKitBundleToken.self).url(
        forResource: "FKBusinessKit",
        withExtension: "bundle"
      ),
      let bundle = Bundle(url: url)
    {
      return bundle
    }
    return Bundle(for: FKBusinessKitBundleToken.self)
    #endif
  }

  /// Returns a template image sized to `pointSize` × `pointSize`.
  public static func image(
    _ icon: FKBusinessKitIcon,
    pointSize: CGFloat = 14
  ) -> UIImage? {
    image(named: icon.rawValue, pointSize: pointSize)
  }

  /// Returns a template image by asset catalog name.
  public static func image(
    named name: String,
    pointSize: CGFloat = 14
  ) -> UIImage? {
    guard
      let base = UIImage(named: name, in: bundle, compatibleWith: nil)?
        .withRenderingMode(.alwaysTemplate)
    else {
      return nil
    }
    let side = max(8, pointSize)
    let size = CGSize(width: side, height: side)
    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { _ in
      base.draw(in: CGRect(origin: .zero, size: size))
    }.withRenderingMode(.alwaysTemplate)
  }
}

private final class FKBusinessKitBundleToken: NSObject {}
