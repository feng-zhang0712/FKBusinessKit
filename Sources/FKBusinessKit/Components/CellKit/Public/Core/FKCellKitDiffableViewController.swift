import FKUIKit

/// Diffable table controller with all CellKit table cells pre-registered.
@MainActor
open class FKCellKitDiffableTableViewController: FKDiffableTableViewController {
  /// When `true`, registers every CellKit table cell before `super.viewDidLoad()`.
  public var registersAllCellKitTableCells: Bool = true

  open override func viewDidLoad() {
    if registersAllCellKitTableCells {
      FKCellKitListRegistration.registerAllTableCells(on: self)
    }
    super.viewDidLoad()
  }
}

/// Diffable collection controller with all CellKit collection cells pre-registered.
@MainActor
open class FKCellKitDiffableCollectionViewController: FKDiffableCollectionViewController {
  /// When `true`, registers every CellKit collection cell before `super.viewDidLoad()`.
  public var registersAllCellKitCollectionCells: Bool = true

  open override func viewDidLoad() {
    if registersAllCellKitCollectionCells {
      FKCellKitListRegistration.registerAllCollectionCells(on: self)
    }
    super.viewDidLoad()
  }
}
