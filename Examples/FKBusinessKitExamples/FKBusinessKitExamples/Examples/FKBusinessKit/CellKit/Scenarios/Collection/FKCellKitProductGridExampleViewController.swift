import FKBusinessKit
import FKUIKit
import UIKit

/// Demonstrates ``FKProductGridCell`` in a two-column grid with image prefetch.
final class FKCellKitProductGridExampleViewController: FKDiffableCollectionViewController, FKListDataProviding, FKListCollectionDelegate {
  init() {
    var config = FKListDefaults.defaultConfiguration
    config.refresh.loadMorePreloadOffset = 120
    super.init(configuration: config, layoutPreset: .grid(columns: 2, spacing: 12))
    dataProvider = self
    delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    title = "Product Grid"
    FKCellKitListRegistration.registerProductGridCell(on: self)
    super.viewDidLoad()
  }

  func fetchInitial(page: Int) async throws -> FKListFetchResult {
    let products = try await FKCellKitExampleSampleData.delayed(FKCellKitExampleSampleData.products)
    FKCellKitListItemFactory.storeProductGridPayloads(products, on: self)
    return FKListFetchResult(
      snapshot: FKListSnapshot(items: products.map(FKCellKitListItemFactory.productGrid)),
      hasMorePages: true
    )
  }

  func fetchNextPage(after pagination: FKRefreshPagination) async throws -> FKListFetchResult {
    let extra = FKProductListItem(
      id: "product.page.\(pagination.nextPage)",
      title: "Load-more item \(pagination.nextPage)",
      priceText: "$9.99",
      imageURL: FKCellKitExampleSampleData.remoteImageURL(id: 210 + pagination.nextPage, width: 320, height: 320),
      tags: [FKTagDisplayModel(title: "More", variant: .neutral)]
    )
    let products = FKCellKitExampleSampleData.products + [extra]
    FKCellKitListItemFactory.storeProductGridPayloads(products, on: self)
    return FKListFetchResult(
      snapshot: FKListSnapshot(items: products.map(FKCellKitListItemFactory.productGrid)),
      hasMorePages: pagination.nextPage < 2
    )
  }

  func fetchRefresh(page: Int) async throws -> FKListFetchResult {
    let products = try await FKCellKitExampleSampleData.delayed(FKCellKitExampleSampleData.products, seconds: 0.45)
    FKCellKitListItemFactory.storeProductGridPayloads(products, on: self)
    return FKListFetchResult(
      snapshot: FKListSnapshot(items: products.map(FKCellKitListItemFactory.productGrid)),
      hasMorePages: true
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
