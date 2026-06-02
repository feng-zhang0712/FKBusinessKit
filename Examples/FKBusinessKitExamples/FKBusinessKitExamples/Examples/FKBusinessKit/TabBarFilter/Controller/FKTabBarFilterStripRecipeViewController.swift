import UIKit
import FKUIKit
import FKBusinessKit

/// Hosts ``FKTabBarFilterController`` for one ``FKTabBarFilterStripRecipe``.
final class FKTabBarFilterStripRecipeViewController: UIViewController {
  private let recipe: FKTabBarFilterStripRecipe
  private let filterState: FKTabBarFilterExampleState
  private let tabStrip = FKTabBarFilterExampleTabStripView()
  private var tagsTabTitle = "Topics"
  private var filterHost: FKTabBarFilterController<String>!

  init(recipe: FKTabBarFilterStripRecipe) {
    self.recipe = recipe
    self.filterState = recipe.initialState
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = recipe.screenTitle
    view.backgroundColor = .systemBackground

    let panelFactory = FKTabBarFilterExamplePanelFactoryBuilder.makeFactory(
      bindingTo: filterState,
      wrapsPanelWithTopHairline: true,
      onTagsSelectionEmptied: recipe.usesTagsTitleCallback ? { [weak self] in
        guard let self else { return }
        self.tagsTabTitle = "Topics"
        self.filterHost.reloadTabBarItems()
      } : nil,
      includesCustomPromoPanel: recipe.includesCustomPromoPanel
    )

    let tabs = recipe.makeTabs(tagsTitle: { [weak self] in self?.tagsTabTitle ?? "Topics" })
    filterHost = FKTabBarFilterController(
      tabs: tabs,
      configuration: recipe.configuration,
      panelFactory: panelFactory,
      tabBarHost: tabStrip
    )

    guard let strip = FKTabBarFilterExampleChrome.embed(
      filterHost: filterHost,
      in: self,
      topAnchor: view.safeAreaLayoutGuide.topAnchor,
      overlayHost: view,
      logSelection: true
    ) else { return }
    _ = FKTabBarFilterExampleChrome.installBodyPlaceholder(below: strip.bottomAnchor, in: self)
  }
}
