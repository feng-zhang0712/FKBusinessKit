import UIKit
import FKUIKit

/// Builds filter panels from model providers so screens only hold state and callbacks.
@MainActor
public final class FKTabBarFilterPanelFactory {
  /// How a ``FKTabBarFilterPanelKind`` is constructed and persisted.
  public enum PanelSource {
    case twoColumnList(
      model: () -> FKTabBarFilterTwoColumnModel?,
      onChange: (FKTabBarFilterTwoColumnModel) -> Void,
      configuration: FKTabBarFilterTwoColumnListViewController.Configuration = .init()
    )
    case twoColumnGrid(
      model: () -> FKTabBarFilterTwoColumnModel?,
      onChange: (FKTabBarFilterTwoColumnModel) -> Void,
      configuration: FKTabBarFilterTwoColumnGridViewController.Configuration = .init()
    )
    case chips(
      sections: () -> [FKTabBarFilterSection],
      onChange: ([FKTabBarFilterSection]) -> Void,
      configuration: FKTabBarFilterChipsViewController.Configuration = .init()
    )
    case singleList(
      section: () -> FKTabBarFilterSection?,
      onChange: (FKTabBarFilterSection) -> Void,
      configuration: FKTabBarFilterSingleListViewController.Configuration = .init()
    )
    /// App-provided panel (e.g. knowledge catalog with a custom layout).
    case custom(
      make: @MainActor (_ allowsMultipleSelection: Bool, _ onSelection: @escaping (FKTabBarFilterPanelSelection) -> Void) -> UIViewController?
    )
  }

  public var sourcesByPanelKind: [FKTabBarFilterPanelKind: PanelSource]
  public var loadingTitle: String
  /// When true, panel controllers are wrapped with a one-pixel top hairline under the tab strip.
  public var wrapsPanelWithTopHairline: Bool

  public init(
    sourcesByPanelKind: [FKTabBarFilterPanelKind: PanelSource],
    loadingTitle: String = "Loading...",
    wrapsPanelWithTopHairline: Bool = true
  ) {
    self.sourcesByPanelKind = sourcesByPanelKind
    self.loadingTitle = loadingTitle
    self.wrapsPanelWithTopHairline = wrapsPanelWithTopHairline
  }

  /// Builds the panel for `kind` and forwards taps to `onSelection`.
  ///
  /// `allowsMultipleSelection` is combined with each section’s ``FKTabBarFilterSection/selectionMode`` (single wins unless both allow multiple).
  public func makePanel(
    for kind: FKTabBarFilterPanelKind,
    allowsMultipleSelection: Bool,
    onSelection: @escaping (FKTabBarFilterPanelSelection) -> Void
  ) -> UIViewController? {
    guard let source = sourcesByPanelKind[kind] else { return nil }
    let panel: UIViewController
    switch source {
    case let .twoColumnList(model, onChange, configuration):
      guard let model = model() else { return loadingPanel() }
      panel = FKTabBarFilterTwoColumnListViewController(
        model: model,
        configuration: configuration,
        onChange: onChange,
        onSelection: { selection in
          onSelection(selection)
        },
        allowsMultipleSelection: allowsMultipleSelection
      )
    case let .twoColumnGrid(model, onChange, configuration):
      guard let model = model() else { return loadingPanel() }
      panel = FKTabBarFilterTwoColumnGridViewController(
        model: model,
        configuration: configuration,
        onChange: onChange,
        onSelection: { selection in
          onSelection(selection)
        },
        allowsMultipleSelection: allowsMultipleSelection
      )
    case let .chips(sections, onChange, configuration):
      let sections = sections()
      guard sections.isEmpty == false else { return loadingPanel() }
      panel = FKTabBarFilterChipsViewController(
        sections: sections,
        configuration: configuration,
        onChange: onChange,
        onSelection: { selection in
          onSelection(selection)
        },
        allowsMultipleSelection: allowsMultipleSelection
      )
    case let .singleList(section, onChange, configuration):
      guard let section = section() else { return loadingPanel() }
      panel = FKTabBarFilterSingleListViewController(
        section: section,
        configuration: configuration,
        onChange: onChange,
        onSelection: { selection in
          onSelection(selection)
        },
        allowsMultipleSelection: allowsMultipleSelection
      )
    case let .custom(make):
      guard let custom = make(allowsMultipleSelection, onSelection) else { return loadingPanel() }
      panel = custom
    }
    return wrapsPanelWithTopHairline
      ? FKTabBarFilterTopHairlineWrapperViewController(contentVC: panel)
      : panel
  }

  private func loadingPanel() -> UIViewController {
    let vc = UIViewController()
    vc.preferredContentSize = CGSize(width: 0, height: 72)
    vc.view.backgroundColor = .systemBackground
    let label = UILabel()
    label.text = loadingTitle
    label.textColor = .secondaryLabel
    label.font = .preferredFont(forTextStyle: .body)
    label.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 20),
      label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
      label.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -20),
    ])
    return wrapsPanelWithTopHairline
      ? FKTabBarFilterTopHairlineWrapperViewController(contentVC: vc)
      : vc
  }
}
