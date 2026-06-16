import UIKit

/// Leading SF Symbol slot sized to match CellKit list-row ``leadingSymbolSide`` metrics.
///
/// Subclasses ``UIImageView`` directly so the glyph is not wrapped in an extra container view.
@MainActor
public final class FKCellKitLeadingSymbolView: UIImageView {
  /// SF Symbol name rendered in the leading slot.
  public var symbolName: String? {
    didSet {
      guard oldValue != symbolName else { return }
      refreshSymbol()
    }
  }

  /// Square container side length in points.
  public var symbolSide: CGFloat = FKCellKitLayoutMetrics.defaultLeadingSymbolSide {
    didSet {
      guard oldValue != symbolSide else { return }
      invalidateIntrinsicContentSize()
      refreshSymbol()
    }
  }

  /// Template tint; `nil` uses ``UIColor.label``.
  public var iconTintColor: UIColor? {
    didSet {
      guard oldValue != iconTintColor else { return }
      tintColor = iconTintColor ?? .label
    }
  }

  public convenience init() {
    self.init(frame: .zero)
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  public override var intrinsicContentSize: CGSize {
    CGSize(width: symbolSide, height: symbolSide)
  }

  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
      refreshSymbol()
    }
  }

  /// Clears symbol content for reuse.
  public func prepareForReuse() {
    symbolName = nil
  }

  private func commonInit() {
    isUserInteractionEnabled = false
    contentMode = .center
    clipsToBounds = false
    setContentHuggingPriority(.required, for: .horizontal)
    setContentHuggingPriority(.required, for: .vertical)
    setContentCompressionResistancePriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .vertical)
    tintColor = iconTintColor ?? .label
  }

  private func refreshSymbol() {
    guard let symbolName, !symbolName.isEmpty else {
      image = nil
      return
    }
    let pointSize = symbolSide * FKCellKitLayoutMetrics.leadingSymbolPointScale
    let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
    image = UIImage(systemName: symbolName, withConfiguration: config)?
      .withRenderingMode(.alwaysTemplate)
  }
}
