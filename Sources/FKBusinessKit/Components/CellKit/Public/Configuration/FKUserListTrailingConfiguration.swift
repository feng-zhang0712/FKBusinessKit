import UIKit

/// Appearance tokens for ``FKUserListTrailingView``.
public struct FKUserListTrailingConfiguration: Equatable {
  /// Timestamp label text style.
  public var timestampTextStyle: UIFont.TextStyle
  /// Timestamp label color.
  public var timestampColor: UIColor
  /// Maximum number of lines for the timestamp label.
  public var timestampNumberOfLines: Int

  /// Creates trailing layout configuration.
  public init(
    timestampTextStyle: UIFont.TextStyle = .caption1,
    timestampColor: UIColor = .secondaryLabel,
    timestampNumberOfLines: Int = 1
  ) {
    self.timestampTextStyle = timestampTextStyle
    self.timestampColor = timestampColor
    self.timestampNumberOfLines = timestampNumberOfLines
  }
}

/// Display payload for ``FKUserListTrailingView/apply(_:)``.
public struct FKUserListTrailingDisplayModel: Equatable, Sendable {
  public var timestampText: String?
  public var roleTag: FKTagDisplayModel?

  public init(timestampText: String? = nil, roleTag: FKTagDisplayModel? = nil) {
    self.timestampText = timestampText
    self.roleTag = roleTag
  }
}
