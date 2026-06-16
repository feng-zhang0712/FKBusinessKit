import FKUIKit
import ObjectiveC
import UIKit

/// Handler registry for CellKit custom-row value changes (quantity, rating, chip selection, share).
@MainActor
public final class FKCellKitValueHandlerRegistry {
  public init() {}

  private var quantityHandlers: [String: @MainActor @Sendable (FKListItemID, Int) -> Void] = [:]
  private var ratingHandlers: [String: @MainActor @Sendable (FKListItemID, Double) -> Void] = [:]
  private var chipSelectionHandlers: [String: @MainActor @Sendable (FKListItemID, Set<String>) -> Void] = [:]
  private var shareHandlers: [String: @MainActor @Sendable (FKListItemID) -> Void] = [:]

  /// Registers a quantity stepper handler keyed by ``FKCartQuantityItem/quantityHandlerID``.
  public func registerQuantity(
    id: String,
    handler: @escaping @MainActor @Sendable (FKListItemID, Int) -> Void
  ) {
    quantityHandlers[id] = handler
  }

  /// Registers a rating input handler keyed by ``FKRatingInputItem/ratingHandlerID``.
  public func registerRating(
    id: String,
    handler: @escaping @MainActor @Sendable (FKListItemID, Double) -> Void
  ) {
    ratingHandlers[id] = handler
  }

  /// Registers a chip selection handler keyed by ``FKTagPickerItem/chipHandlerID``.
  public func registerChipSelection(
    id: String,
    handler: @escaping @MainActor @Sendable (FKListItemID, Set<String>) -> Void
  ) {
    chipSelectionHandlers[id] = handler
  }

  /// Registers a share affordance handler keyed by ``FKInviteCodeItem/shareHandlerID``.
  public func registerShare(
    id: String,
    handler: @escaping @MainActor @Sendable (FKListItemID) -> Void
  ) {
    shareHandlers[id] = handler
  }

  func quantityHandler(for id: String) -> (@MainActor @Sendable (FKListItemID, Int) -> Void)? {
    quantityHandlers[id]
  }

  func ratingHandler(for id: String) -> (@MainActor @Sendable (FKListItemID, Double) -> Void)? {
    ratingHandlers[id]
  }

  func chipSelectionHandler(for id: String) -> (@MainActor @Sendable (FKListItemID, Set<String>) -> Void)? {
    chipSelectionHandlers[id]
  }

  func shareHandler(for id: String) -> (@MainActor @Sendable (FKListItemID) -> Void)? {
    shareHandlers[id]
  }
}

extension FKDiffableTableViewController {
  private enum AssociatedKeys {
    nonisolated(unsafe) static var valueHandlers = "fk.cellKit.valueHandlers"
  }

  /// Optional registry for CellKit interactive custom rows on this controller.
  public var cellKitValueHandlers: FKCellKitValueHandlerRegistry {
    if let existing = objc_getAssociatedObject(self, &AssociatedKeys.valueHandlers)
      as? FKCellKitValueHandlerRegistry {
      return existing
    }
    let registry = FKCellKitValueHandlerRegistry()
    objc_setAssociatedObject(
      self,
      &AssociatedKeys.valueHandlers,
      registry,
      .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
    return registry
  }
}

enum FKCellKitResponderLookup {
  @MainActor
  static func diffableTableController(from view: UIView) -> FKDiffableTableViewController? {
    var responder: UIResponder? = view
    while let current = responder {
      if let controller = current as? FKDiffableTableViewController {
        return controller
      }
      responder = current.next
    }
    return nil
  }
}
