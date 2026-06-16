import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates CellKit skeleton table and collection cells before real payloads arrive.
final class FKCellKitSkeletonExampleViewController: UIViewController {
  private let modeControl = UISegmentedControl(items: ["Table", "Collection"])
  private var embeddedController: UIViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Skeleton Placeholders"
    view.backgroundColor = .systemBackground

    modeControl.selectedSegmentIndex = 0
    modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
    navigationItem.titleView = modeControl

    showTableSkeleton()
  }

  @objc private func modeChanged() {
    switch modeControl.selectedSegmentIndex {
    case 1:
      showCollectionSkeleton()
    default:
      showTableSkeleton()
    }
  }

  private func showTableSkeleton() {
    swapEmbedded(FKCellKitSkeletonTableDemoViewController())
  }

  private func showCollectionSkeleton() {
    swapEmbedded(FKCellKitSkeletonCollectionDemoViewController())
  }

  private func swapEmbedded(_ controller: UIViewController) {
    embeddedController?.willMove(toParent: nil)
    embeddedController?.view.removeFromSuperview()
    embeddedController?.removeFromParent()

    addChild(controller)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(controller.view)
    NSLayoutConstraint.activate([
      controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    controller.didMove(toParent: self)
    embeddedController = controller
  }
}

// MARK: - Table skeleton

private final class FKCellKitSkeletonTableDemoViewController: FKDiffableTableViewController {
  private var pendingSnapshot: FKListSnapshot?

  init() {
    var configuration = FKListDefaults.defaultConfiguration
    configuration.loading.usesSkeletonForInitialLoad = false
    configuration.layout.rowHeightPolicy = .fixed(FKCellKitUserListSkeletonTableCell.preferredRowHeight)
    configuration.layout.estimatedRowHeight = FKCellKitUserListSkeletonTableCell.preferredRowHeight
    super.init(configuration: configuration)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    FKCellKitListRegistration.registerUserListSkeletonCell(on: self)

    let skeletonIDs = (0 ..< 6).map { FKListItemID("skeleton.user.\($0)") }
    skeletonIDs.forEach { id in
      FKCellKitListItemFactory.storeUserListSkeletonPayload(id: id, on: self)
    }
    super.viewDidLoad()
    pendingSnapshot = FKListSnapshot(items: skeletonIDs.map(FKCellKitListItemFactory.userListSkeleton))

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Load",
      style: .plain,
      target: self,
      action: #selector(loadRealUsers)
    )
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let pendingSnapshot else { return }
    self.pendingSnapshot = nil
    applySnapshot(pendingSnapshot, animatingDifferences: false)
  }

  @objc private func loadRealUsers() {
    let users = FKCellKitExampleSampleData.users
    FKCellKitListRegistration.registerUserListCell(on: self)
    FKCellKitExampleSampleData.storeUserListPayloads(users, on: self)
    applySnapshot(
      FKCellKitExampleSampleData.makeUserListSnapshot(users),
      animatingDifferences: true
    )
  }
}

// MARK: - Collection skeleton

private final class FKCellKitSkeletonCollectionDemoViewController: FKDiffableCollectionViewController {
  private var pendingSnapshot: FKListSnapshot?

  init() {
    var configuration = FKListDefaults.defaultConfiguration
    configuration.loading.usesSkeletonForInitialLoad = false
    configuration.layout.estimatedCollectionItemHeight = FKCellKitMediaTileSkeletonCollectionCell.preferredItemSize.height
    super.init(configuration: configuration, layoutPreset: .grid(columns: 3, spacing: 4))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    FKCellKitListRegistration.registerMediaTileSkeletonCell(on: self)
    let skeletonIDs = (0 ..< 9).map { FKListItemID("skeleton.tile.\($0)") }
    skeletonIDs.forEach { id in
      FKCellKitListItemFactory.storeMediaTileSkeletonPayload(id: id, on: self)
    }
    super.viewDidLoad()
    pendingSnapshot = FKListSnapshot(items: skeletonIDs.map(FKCellKitListItemFactory.mediaTileSkeleton))

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Load",
      style: .plain,
      target: self,
      action: #selector(loadRealTiles)
    )
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let pendingSnapshot else { return }
    self.pendingSnapshot = nil
    applySnapshot(pendingSnapshot, animatingDifferences: false)
  }

  @objc private func loadRealTiles() {
    let tiles = FKCellKitExampleSampleData.mediaTiles
    FKCellKitListRegistration.registerMediaTileCell(on: self)
    FKCellKitListItemFactory.storeMediaTilePayloads(tiles, on: self)
    applySnapshot(
      FKListSnapshot(items: tiles.map(FKCellKitListItemFactory.mediaTile)),
      animatingDifferences: true
    )
  }
}
