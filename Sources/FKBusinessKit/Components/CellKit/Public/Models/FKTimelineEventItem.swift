import Foundation
import FKUIKit

/// Connector position for a single row inside a vertical timeline list.
public enum FKTimelineConnectorPosition: Sendable, Equatable {
  case only
  case first
  case middle
  case last
}

/// View model for ``FKTimelineEventCell`` (logistics / audit trail rows).
public struct FKTimelineEventItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Underlying flow step content.
  public var step: FKFlowStepItem
  /// Zero-based index within the timeline sequence.
  public var stepIndex: Int
  /// Where this row sits in the connector column.
  public var connectorPosition: FKTimelineConnectorPosition
  /// When `true`, paints the connector above the node as completed.
  public var topConnectorCompleted: Bool
  /// When `true`, paints the connector below the node as completed.
  public var bottomConnectorCompleted: Bool

  /// Creates a timeline event row item.
  public init(
    id: String,
    step: FKFlowStepItem,
    stepIndex: Int,
    connectorPosition: FKTimelineConnectorPosition,
    topConnectorCompleted: Bool = false,
    bottomConnectorCompleted: Bool = false
  ) {
    self.id = id
    self.step = step
    self.stepIndex = stepIndex
    self.connectorPosition = connectorPosition
    self.topConnectorCompleted = topConnectorCompleted
    self.bottomConnectorCompleted = bottomConnectorCompleted
  }
}

extension FKTimelineEventItem {
  /// Builds timeline rows with connector position and fill flags derived from ``FKFlowStepItem`` order and state.
  public static func makeList(
    from steps: [FKFlowStepItem],
    treatsSkippedAsCompletedForConnectors: Bool = true
  ) -> [FKTimelineEventItem] {
    guard !steps.isEmpty else { return [] }

    return steps.enumerated().map { index, step in
      let position: FKTimelineConnectorPosition = {
        if steps.count == 1 { return .only }
        if index == 0 { return .first }
        if index == steps.count - 1 { return .last }
        return .middle
      }()

      let previousCompleted = index > 0
        && isCompletedForConnector(
          steps[index - 1].state,
          treatsSkippedAsCompleted: treatsSkippedAsCompletedForConnectors
        )

      return FKTimelineEventItem(
        id: step.id,
        step: step,
        stepIndex: index,
        connectorPosition: position,
        topConnectorCompleted: previousCompleted,
        bottomConnectorCompleted: isCompletedForConnector(
          step.state,
          treatsSkippedAsCompleted: treatsSkippedAsCompletedForConnectors
        )
      )
    }
  }

  private static func isCompletedForConnector(
    _ state: FKFlowStepState,
    treatsSkippedAsCompleted: Bool
  ) -> Bool {
    switch state {
    case .completed:
      return true
    case .skipped:
      return treatsSkippedAsCompleted
    default:
      return false
    }
  }
}
