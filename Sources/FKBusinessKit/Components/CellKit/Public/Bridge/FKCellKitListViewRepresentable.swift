#if canImport(SwiftUI)
import SwiftUI
import UIKit
import FKUIKit

/// Embeds ``FKCellKitDiffableTableViewController`` in SwiftUI with CellKit cells pre-registered.
public struct FKCellKitDiffableTableViewRepresentable: UIViewControllerRepresentable {
  public var configuration: FKListConfiguration
  public var style: UITableView.Style
  public var registersAllCellKitTableCells: Bool
  public var makeViewController: ((FKListConfiguration, UITableView.Style) -> FKCellKitDiffableTableViewController)?

  /// Creates a SwiftUI bridge for a CellKit-enabled diffable table controller.
  public init(
    configuration: FKListConfiguration = FKListDefaults.defaultConfiguration,
    style: UITableView.Style = .plain,
    registersAllCellKitTableCells: Bool = true,
    makeViewController: ((FKListConfiguration, UITableView.Style) -> FKCellKitDiffableTableViewController)? = nil
  ) {
    self.configuration = configuration
    self.style = style
    self.registersAllCellKitTableCells = registersAllCellKitTableCells
    self.makeViewController = makeViewController
  }

  public func makeUIViewController(context: Context) -> FKCellKitDiffableTableViewController {
    let controller = makeViewController?(configuration, style)
      ?? FKCellKitDiffableTableViewController(configuration: configuration, style: style)
    controller.registersAllCellKitTableCells = registersAllCellKitTableCells
    return controller
  }

  public func updateUIViewController(_ uiViewController: FKCellKitDiffableTableViewController, context: Context) {
    if uiViewController.configuration != configuration {
      uiViewController.configuration = configuration
    }
    uiViewController.registersAllCellKitTableCells = registersAllCellKitTableCells
  }
}

/// Embeds ``FKCellKitDiffableCollectionViewController`` in SwiftUI with CellKit cells pre-registered.
public struct FKCellKitDiffableCollectionViewRepresentable: UIViewControllerRepresentable {
  public var configuration: FKListConfiguration
  public var layoutPreset: FKListCollectionLayoutPreset
  public var registersAllCellKitCollectionCells: Bool
  public var makeViewController: (
    (FKListConfiguration, FKListCollectionLayoutPreset) -> FKCellKitDiffableCollectionViewController
  )?

  /// Creates a SwiftUI bridge for a CellKit-enabled diffable collection controller.
  public init(
    configuration: FKListConfiguration = FKListDefaults.defaultConfiguration,
    layoutPreset: FKListCollectionLayoutPreset = .list,
    registersAllCellKitCollectionCells: Bool = true,
    makeViewController: (
      (FKListConfiguration, FKListCollectionLayoutPreset) -> FKCellKitDiffableCollectionViewController
    )? = nil
  ) {
    self.configuration = configuration
    self.layoutPreset = layoutPreset
    self.registersAllCellKitCollectionCells = registersAllCellKitCollectionCells
    self.makeViewController = makeViewController
  }

  public func makeUIViewController(context: Context) -> FKCellKitDiffableCollectionViewController {
    let controller = makeViewController?(configuration, layoutPreset)
      ?? FKCellKitDiffableCollectionViewController(configuration: configuration, layoutPreset: layoutPreset)
    controller.registersAllCellKitCollectionCells = registersAllCellKitCollectionCells
    return controller
  }

  public func updateUIViewController(
    _ uiViewController: FKCellKitDiffableCollectionViewController,
    context: Context
  ) {
    if uiViewController.configuration != configuration {
      uiViewController.configuration = configuration
    }
    if uiViewController.layoutPreset != layoutPreset {
      uiViewController.layoutPreset = layoutPreset
    }
    uiViewController.registersAllCellKitCollectionCells = registersAllCellKitCollectionCells
  }
}
#endif
