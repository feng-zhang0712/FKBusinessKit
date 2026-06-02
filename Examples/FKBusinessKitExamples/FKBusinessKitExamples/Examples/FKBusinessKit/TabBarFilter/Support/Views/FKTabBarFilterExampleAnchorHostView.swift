import UIKit
import FKUIKit
import FKBusinessKit

/// Shared off-screen ``FKTabBar`` host with a visible anchor control for filter-strip demos.
final class FKTabBarFilterExampleAnchorHostView: UIView, FKTabBarFilterTabBarHost {
  enum Placement {
    /// Interactive custom-anchor demo: divider under the control, safe-area top inset.
    case interactive
    /// Directly under the navigation bar (safe-area top).
    case belowNavigationBar
    /// Top edge of the content (`UIView` top).
    case screenTop
    /// Bottom edge; chrome can extend through the home-indicator safe area.
    case bottomEdge
  }

  static let anchorControlHeight: CGFloat = 48

  let placement: Placement

  let anchorControl: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.titleAlignment = .center
    configuration.baseForegroundColor = .label
    configuration.baseBackgroundColor = .secondarySystemBackground
    configuration.cornerStyle = .fixed
    configuration.background.cornerRadius = 0
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont.preferredFont(forTextStyle: .footnote)
      return outgoing
    }
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let divider: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.separator.withAlphaComponent(0.65)
    return view
  }()

  let tabBar: FKTabBar = {
    let bar = FKTabBar()
    bar.translatesAutoresizingMaskIntoConstraints = false
    bar.isHidden = true
    return bar
  }()

  var view: UIView { self }

  init(placement: Placement, title: String) {
    self.placement = placement
    super.init(frame: .zero)
    anchorControl.configuration?.title = title
    if placement == .interactive {
      anchorControl.configuration?.baseBackgroundColor = .systemBackground
      anchorControl.accessibilityHint = "Toggles the Filters panel anchored below this bar."
    }
    commonInit()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { nil }

  private func commonInit() {
    backgroundColor = .clear
    addSubview(anchorControl)
    addSubview(tabBar)

    if placement == .interactive {
      addSubview(divider)
    }

    NSLayoutConstraint.activate([
      anchorControl.leadingAnchor.constraint(equalTo: leadingAnchor),
      anchorControl.trailingAnchor.constraint(equalTo: trailingAnchor),

      tabBar.leadingAnchor.constraint(equalTo: leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: trailingAnchor),
      tabBar.heightAnchor.constraint(equalToConstant: 44),
    ])

    switch placement {
    case .interactive:
      NSLayoutConstraint.activate([
        anchorControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        anchorControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

        divider.topAnchor.constraint(equalTo: anchorControl.bottomAnchor),
        divider.leadingAnchor.constraint(equalTo: leadingAnchor),
        divider.trailingAnchor.constraint(equalTo: trailingAnchor),
        divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
        divider.bottomAnchor.constraint(equalTo: bottomAnchor),

        tabBar.topAnchor.constraint(equalTo: bottomAnchor, constant: 4000),
      ])

    case .belowNavigationBar, .screenTop:
      NSLayoutConstraint.activate([
        anchorControl.topAnchor.constraint(equalTo: topAnchor),
        anchorControl.heightAnchor.constraint(equalToConstant: Self.anchorControlHeight),
        tabBar.topAnchor.constraint(equalTo: bottomAnchor, constant: 4000),
      ])

    case .bottomEdge:
      NSLayoutConstraint.activate([
        anchorControl.topAnchor.constraint(equalTo: topAnchor),
        anchorControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        tabBar.topAnchor.constraint(equalTo: topAnchor, constant: -4000),
      ])
    }
  }
}
