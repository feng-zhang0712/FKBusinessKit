import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKMediaTileCell`` duration badge, selection overlay, and prefetch.
final class FKCellKitMediaTileExampleViewController: FKDiffableCollectionViewController, FKListCollectionDelegate {
  init() {
    super.init(configuration: FKListDefaults.defaultConfiguration, layoutPreset: .grid(columns: 3, spacing: 4))
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Media Tiles"
    FKCellKitListRegistration.registerMediaTileCell(on: self)
    let tiles = FKCellKitExampleSampleData.mediaTiles
    FKCellKitListItemFactory.storeMediaTilePayloads(tiles, on: self)
    super.viewDidLoad()
    applySnapshot(
      FKListSnapshot(items: tiles.map(FKCellKitListItemFactory.mediaTile)),
      animatingDifferences: false
    )
  }

  func list(_ list: FKDiffableCollectionViewController, prefetchItems ids: [FKListItemID]) {
    FKListImagePrefetchHelper.prefetchImages(
      for: ids,
      in: currentSnapshot,
      payloadProvider: { [weak self] id in self?.payload(for: id) }
    )
  }

  func list(_ list: FKDiffableCollectionViewController, cancelPrefetching ids: [FKListItemID]) {
    FKListImagePrefetchHelper.cancelPrefetchImages(
      for: ids,
      in: currentSnapshot,
      payloadProvider: { [weak self] id in self?.payload(for: id) }
    )
  }
}
