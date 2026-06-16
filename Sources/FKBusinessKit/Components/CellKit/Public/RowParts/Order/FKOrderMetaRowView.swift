import UIKit
import FKUIKit

/// Horizontal ``FKCopyChip`` + ``FKStatusPill`` row used by ``FKOrderListCell``.
@MainActor
public final class FKOrderMetaRowView: UIView {
  private var copyChip: FKCopyChip?
  private let statusPill = FKStatusPill()
  private let stack = UIStackView()

  /// Creates an order metadata trailing row.
  public init() {
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Binds copy chip and status pill content.
  public func apply(
    displayOrderNumber: String,
    fullOrderNumber: String?,
    statusPill model: FKStatusPillDisplayModel,
    showsCopyChip: Bool
  ) {
    if showsCopyChip, !displayOrderNumber.isEmpty {
      let chip = ensureCopyChip()
      chip.text = displayOrderNumber
      chip.copyText = fullOrderNumber ?? displayOrderNumber
    } else {
      releaseCopyChip()
    }

    statusPill.title = model.title
    statusPill.style = model.style
    statusPill.showsDot = model.showsDot
  }

  /// Clears widgets during reuse.
  public func prepareForReuse() {
    releaseCopyChip()
    statusPill.title = ""
    statusPill.showsDot = false
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    setContentHuggingPriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .horizontal)

    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.addArrangedSubview(statusPill)

    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  @discardableResult
  private func ensureCopyChip() -> FKCopyChip {
    if let copyChip { return copyChip }

    let chip = FKCopyChip()
    copyChip = chip
    stack.insertArrangedSubview(chip, at: 0)
    return chip
  }

  private func releaseCopyChip() {
    guard let copyChip else { return }
    copyChip.text = ""
    stack.removeArrangedSubview(copyChip)
    copyChip.removeFromSuperview()
    self.copyChip = nil
  }
}
