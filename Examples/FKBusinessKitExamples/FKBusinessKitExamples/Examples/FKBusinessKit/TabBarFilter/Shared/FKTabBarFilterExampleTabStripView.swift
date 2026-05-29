import UIKit
import FKUIKit
import FKBusinessKit

/// Chrome for Filter examples: **top-aligned** tab row; bottom edge uses ``FKTabBar``’s built-in divider from configuration.
///
/// Use as ``FKTabBarFilterTabBarHost`` so items align to the top when titles wrap to two lines.
final class FKTabBarFilterExampleTabStripView: UIView, FKTabBarFilterTabBarHost {
  /// When `true`, chrome fills through the home-indicator region while tab items stay above the bottom safe area.
  var extendsChromeThroughBottomSafeArea = false

  let tabBar: FKTabBar = {
    let bar = FKTabBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    return bar
  }()

  private let chromeBar: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .systemBackground
    return v
  }()

  var view: UIView { self }

  private var tabBarBottomConstraint: NSLayoutConstraint?

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { nil }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateTabBarBottomConstraint()
  }

  private func commonInit() {
    backgroundColor = .clear

    addSubview(chromeBar)
    chromeBar.addSubview(tabBar)

    NSLayoutConstraint.activate([
      chromeBar.topAnchor.constraint(equalTo: topAnchor),
      chromeBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      chromeBar.trailingAnchor.constraint(equalTo: trailingAnchor),
      chromeBar.bottomAnchor.constraint(equalTo: bottomAnchor),

      tabBar.topAnchor.constraint(equalTo: chromeBar.topAnchor),
      tabBar.leadingAnchor.constraint(equalTo: chromeBar.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: chromeBar.trailingAnchor),
      tabBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
    ])
    updateTabBarBottomConstraint()
  }

  private func updateTabBarBottomConstraint() {
    tabBarBottomConstraint?.isActive = false
    if extendsChromeThroughBottomSafeArea, window != nil {
      tabBarBottomConstraint = tabBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
    } else {
      tabBarBottomConstraint = tabBar.bottomAnchor.constraint(equalTo: chromeBar.bottomAnchor)
    }
    tabBarBottomConstraint?.isActive = true
  }
}
