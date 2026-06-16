import UIKit

/// Compact minus / quantity / plus control for cart quantity rows.
@MainActor
public final class FKQuantityStepperView: UIView {
  /// Fires when the user taps increment or decrement.
  public var onValueChanged: ((Int) -> Void)?

  private let decrementButton = UIButton(type: .system)
  private let incrementButton = UIButton(type: .system)
  private let valueLabel = UILabel()
  private let stack = UIStackView()
  private static let buttonSide: CGFloat = 32
  private static let valueColumnWidth: CGFloat = 32
  private static let interItemSpacing: CGFloat = 8
  private static let preferredWidth =
    buttonSide + interItemSpacing + valueColumnWidth + interItemSpacing + buttonSide
  private var currentValue = 1
  private var minValue = 1
  private var maxValue = 99

  /// Creates a quantity stepper row part.
  public init() {
    super.init(frame: .zero)
    setupUI()
    updateButtons()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Binds quantity limits and the current value.
  public func apply(value: Int, minValue: Int, maxValue: Int) {
    self.minValue = minValue
    self.maxValue = max(maxValue, minValue)
    currentValue = min(max(value, minValue), self.maxValue)
    valueLabel.text = "\(currentValue)"
    updateButtons()
  }

  /// Clears callbacks during reuse.
  public func prepareForReuse() {
    onValueChanged = nil
    currentValue = 1
    minValue = 1
    maxValue = 99
    valueLabel.text = "1"
    updateButtons()
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    setContentHuggingPriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .horizontal)

    decrementButton.setImage(UIImage(systemName: "minus"), for: .normal)
    incrementButton.setImage(UIImage(systemName: "plus"), for: .normal)
    decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
    incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)

    [decrementButton, incrementButton].forEach {
      $0.layer.cornerRadius = 6
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.separator.cgColor
      $0.widthAnchor.constraint(equalToConstant: Self.buttonSide).isActive = true
      $0.heightAnchor.constraint(equalToConstant: Self.buttonSide).isActive = true
    }

    valueLabel.font = .preferredFont(forTextStyle: .body)
    valueLabel.textAlignment = .center
    valueLabel.text = "1"
    valueLabel.setContentHuggingPriority(.required, for: .horizontal)
    valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Self.interItemSpacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.addArrangedSubview(decrementButton)
    stack.addArrangedSubview(valueLabel)
    stack.addArrangedSubview(incrementButton)

    addSubview(stack)
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: Self.preferredWidth),
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
      valueLabel.widthAnchor.constraint(equalToConstant: Self.valueColumnWidth),
    ])
  }

  @objc private func decrementTapped() {
    guard currentValue > minValue else { return }
    currentValue -= 1
    valueLabel.text = "\(currentValue)"
    updateButtons()
    onValueChanged?(currentValue)
  }

  @objc private func incrementTapped() {
    guard currentValue < maxValue else { return }
    currentValue += 1
    valueLabel.text = "\(currentValue)"
    updateButtons()
    onValueChanged?(currentValue)
  }

  private func updateButtons() {
    decrementButton.isEnabled = currentValue > minValue
    incrementButton.isEnabled = currentValue < maxValue
  }
}
