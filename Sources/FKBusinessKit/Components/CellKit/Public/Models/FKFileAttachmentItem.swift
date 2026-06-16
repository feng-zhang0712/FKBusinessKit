import Foundation
import FKUIKit

/// Transfer state for ``FKFileAttachmentCell``.
public enum FKFileAttachmentState: Sendable, Equatable {
  case idle
  case downloading
  case uploaded
  case failed
}

/// View model for ``FKFileAttachmentCell``.
public struct FKFileAttachmentItem: Equatable, Sendable {
  /// Stable row identity.
  public var id: String
  /// Display file name.
  public var fileName: String
  /// Optional formatted size string, e.g. `2.4 MB`.
  public var fileSizeText: String?
  /// Optional SF Symbol override for the leading icon.
  public var symbolName: String?
  /// Optional status pill mapped from ``state``.
  public var statusPill: FKStatusPillDisplayModel?
  /// File transfer state used when ``statusPill`` is nil.
  public var state: FKFileAttachmentState

  /// Creates a file attachment row item.
  public init(
    id: String,
    fileName: String,
    fileSizeText: String? = nil,
    symbolName: String? = nil,
    statusPill: FKStatusPillDisplayModel? = nil,
    state: FKFileAttachmentState = .idle
  ) {
    self.id = id
    self.fileName = fileName
    self.fileSizeText = fileSizeText
    self.symbolName = symbolName
    self.statusPill = statusPill
    self.state = state
  }
}
