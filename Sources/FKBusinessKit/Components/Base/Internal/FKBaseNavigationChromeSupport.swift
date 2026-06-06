import UIKit

// MARK: - Snapshot

/// Captured navigation bar state used to restore system chrome when a controller exits.
struct FKBaseNavigationChromeSnapshot {
  let wasNavigationBarHidden: Bool
  let standardAppearance: UINavigationBarAppearance
  let scrollEdgeAppearance: UINavigationBarAppearance?
  let compactAppearance: UINavigationBarAppearance?
  let compactScrollEdgeAppearance: UINavigationBarAppearance?
  let prefersLargeTitles: Bool
  let isTranslucent: Bool
}

// MARK: - Appearance copying

enum FKBaseNavigationChromeAppearanceCopying {
  static func capture(from navigationController: UINavigationController) -> FKBaseNavigationChromeSnapshot {
    let bar = navigationController.navigationBar
    return FKBaseNavigationChromeSnapshot(
      wasNavigationBarHidden: navigationController.isNavigationBarHidden,
      standardAppearance: copied(bar.standardAppearance),
      scrollEdgeAppearance: copiedIfPresent(bar.scrollEdgeAppearance),
      compactAppearance: copiedIfPresent(bar.compactAppearance),
      compactScrollEdgeAppearance: copiedCompactScrollEdgeIfPresent(from: bar),
      prefersLargeTitles: bar.prefersLargeTitles,
      isTranslucent: bar.isTranslucent
    )
  }

  static func restore(
    _ snapshot: FKBaseNavigationChromeSnapshot,
    on navigationController: UINavigationController,
    animated: Bool
  ) {
    let bar = navigationController.navigationBar
    navigationController.setNavigationBarHidden(snapshot.wasNavigationBarHidden, animated: animated)
    bar.standardAppearance = copied(snapshot.standardAppearance)
    bar.scrollEdgeAppearance = copiedIfPresent(snapshot.scrollEdgeAppearance)
    bar.compactAppearance = copiedIfPresent(snapshot.compactAppearance)
    if #available(iOS 15.0, *) {
      bar.compactScrollEdgeAppearance = copiedIfPresent(snapshot.compactScrollEdgeAppearance)
    }
    bar.prefersLargeTitles = snapshot.prefersLargeTitles
    bar.isTranslucent = snapshot.isTranslucent
  }

  static func copied(_ appearance: UINavigationBarAppearance) -> UINavigationBarAppearance {
    guard let copy = appearance.copy() as? UINavigationBarAppearance else { return appearance }
    return copy
  }

  static func copiedIfPresent(_ appearance: UINavigationBarAppearance?) -> UINavigationBarAppearance? {
    guard let appearance else { return nil }
    return copied(appearance)
  }

  static func copiedCompactScrollEdgeIfPresent(from bar: UINavigationBar) -> UINavigationBarAppearance? {
    if #available(iOS 15.0, *) {
      return copiedIfPresent(bar.compactScrollEdgeAppearance)
    }
    return nil
  }
}

// MARK: - Style application

enum FKBaseNavigationChromeApplicator {
  static func applyConfiguration(
    visibility: FKBaseViewController.NavigationBarVisibility,
    style: FKBaseViewController.NavigationBarStyle,
    prefersLargeTitlesWhileVisible: Bool?,
    snapshot: FKBaseNavigationChromeSnapshot?,
    navigationController: UINavigationController,
    navigationItem: UINavigationItem,
    animated: Bool
  ) {
    navigationController.setNavigationBarHidden(visibility == .hidden, animated: animated)
    if let prefersLargeTitlesWhileVisible {
      navigationController.navigationBar.prefersLargeTitles = prefersLargeTitlesWhileVisible
    } else if let snapshot {
      navigationController.navigationBar.prefersLargeTitles = snapshot.prefersLargeTitles
    }
    applyStyle(style, snapshot: snapshot, navigationController: navigationController, navigationItem: navigationItem)
  }

  static func applyStyle(
    _ style: FKBaseViewController.NavigationBarStyle,
    snapshot: FKBaseNavigationChromeSnapshot?,
    navigationController: UINavigationController,
    navigationItem: UINavigationItem
  ) {
    let bar = navigationController.navigationBar
    switch style {
    case .system:
      clearPerItemAppearances(on: navigationItem)
      guard let snapshot else { return }
      bar.standardAppearance = FKBaseNavigationChromeAppearanceCopying.copied(snapshot.standardAppearance)
      bar.scrollEdgeAppearance = FKBaseNavigationChromeAppearanceCopying.copiedIfPresent(snapshot.scrollEdgeAppearance)
      bar.compactAppearance = FKBaseNavigationChromeAppearanceCopying.copiedIfPresent(snapshot.compactAppearance)
      if #available(iOS 15.0, *) {
        bar.compactScrollEdgeAppearance = FKBaseNavigationChromeAppearanceCopying.copiedIfPresent(
          snapshot.compactScrollEdgeAppearance
        )
      }
      bar.isTranslucent = snapshot.isTranslucent
    case .opaqueDefault:
      let appearance = UINavigationBarAppearance()
      appearance.configureWithDefaultBackground()
      applyPerItemChrome(bar: bar, item: navigationItem, appearance: appearance, translucent: false)
    case .transparent:
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      applyPerItemChrome(bar: bar, item: navigationItem, appearance: appearance, translucent: true)
    case let .gradient(colors, locations, startPoint, endPoint):
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      appearance.backgroundImage = FKBaseNavigationGradientImage.make(
        colors: colors,
        locations: locations,
        size: FKBaseUIConstants.navigationBarGradientSize,
        startPoint: startPoint,
        endPoint: endPoint
      )
      applyPerItemChrome(bar: bar, item: navigationItem, appearance: appearance, translucent: true)
    }
  }

  /// Per-`UINavigationItem` chrome lets `UINavigationController` interpolate styles during interactive pops.
  private static func applyPerItemChrome(
    bar: UINavigationBar,
    item: UINavigationItem,
    appearance: UINavigationBarAppearance,
    translucent: Bool
  ) {
    item.standardAppearance = appearance
    item.scrollEdgeAppearance = appearance
    item.compactAppearance = appearance
    if #available(iOS 15.0, *) {
      item.compactScrollEdgeAppearance = appearance
    }
    bar.isTranslucent = translucent
  }

  private static func clearPerItemAppearances(on item: UINavigationItem) {
    item.standardAppearance = nil
    item.scrollEdgeAppearance = nil
    item.compactAppearance = nil
    if #available(iOS 15.0, *) {
      item.compactScrollEdgeAppearance = nil
    }
  }
}

// MARK: - Constants & gradient

enum FKBaseUIConstants {
  static let navigationBarGradientSize = CGSize(width: 4.0, height: 88.0)
  static let backButtonContentInsets = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0, right: 0.0)
}

enum FKBaseNavigationGradientImage {
  static func make(
    colors: [UIColor],
    locations: [NSNumber]?,
    size: CGSize,
    startPoint: CGPoint,
    endPoint: CGPoint
  ) -> UIImage? {
    guard size.width > 0.0, size.height > 0.0, !colors.isEmpty else { return nil }
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
      let layer = CAGradientLayer()
      layer.frame = CGRect(origin: .zero, size: size)
      layer.colors = colors.map(\.cgColor)
      layer.locations = locations
      layer.startPoint = startPoint
      layer.endPoint = endPoint
      layer.render(in: context.cgContext)
    }
  }
}
