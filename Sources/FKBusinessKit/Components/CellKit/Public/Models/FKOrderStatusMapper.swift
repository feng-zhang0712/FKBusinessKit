import FKUIKit

/// Maps common backend status keys to ``FKStatusPillStyle`` and localized titles.
public enum FKOrderStatusMapper {
  /// Returns a workflow pill style for a normalized status key.
  public static func statusPillStyle(for statusKey: String) -> FKStatusPillStyle {
    switch statusKey.lowercased() {
    case "pending", "processing", "awaiting_payment":
      return .warning
    case "paid", "shipped", "delivered", "completed", "success":
      return .success
    case "cancelled", "canceled", "failed", "refunded":
      return .error
    case "in_transit", "shipping", "info":
      return .info
    default:
      return .neutral
    }
  }

  /// Returns a display title for a normalized status key.
  ///
  /// Host apps with domain-specific copy should map enums locally and pass ``FKStatusPillDisplayModel/title`` directly.
  public static func localizedTitle(for statusKey: String) -> String {
    switch statusKey.lowercased() {
    case "pending": return "Pending"
    case "processing": return "Processing"
    case "awaiting_payment": return "Awaiting payment"
    case "paid": return "Paid"
    case "shipped": return "Shipped"
    case "delivered": return "Delivered"
    case "completed": return "Completed"
    case "cancelled", "canceled": return "Cancelled"
    case "failed": return "Failed"
    case "refunded": return "Refunded"
    case "in_transit", "shipping": return "In transit"
    default:
      return statusKey.replacingOccurrences(of: "_", with: " ").capitalized
    }
  }

  /// Builds a display model from a backend status key.
  public static func displayModel(for statusKey: String, showsDot: Bool = true) -> FKStatusPillDisplayModel {
    FKStatusPillDisplayModel(
      title: localizedTitle(for: statusKey),
      style: statusPillStyle(for: statusKey),
      showsDot: showsDot
    )
  }
}
