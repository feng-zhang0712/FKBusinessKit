import UIKit
import FKUIKit

/// Vertical connector column (top line + node + bottom line) for timeline list rows.
@MainActor
public final class FKTimelineConnectorView: UIView {
  /// Connector layout tokens.
  public struct Configuration: Equatable, Sendable {
    public var nodeDiameter: CGFloat
    public var appearance: FKFlowAppearanceConfiguration

    public init(
      nodeDiameter: CGFloat = FKFlowNodeSize.medium.diameter,
      appearance: FKFlowAppearanceConfiguration = .init()
    ) {
      self.nodeDiameter = nodeDiameter
      self.appearance = appearance
    }
  }

  public var configuration: Configuration = .init() {
    didSet { setNeedsLayout() }
  }

  private let topConnector = UIView()
  private let bottomConnector = UIView()
  private let nodeView = UIView()
  private let nodeIconView = UIImageView()
  private var nodeWidthConstraint: NSLayoutConstraint?
  private var nodeHeightConstraint: NSLayoutConstraint?
  private var topConnectorWidthConstraint: NSLayoutConstraint?
  private var bottomConnectorWidthConstraint: NSLayoutConstraint?
  private var topConnectorTopConstraint: NSLayoutConstraint?
  private var bottomConnectorBottomConstraint: NSLayoutConstraint?

  /// Overlap past the connector column bounds so lines meet across adjacent table rows.
  private var connectorRowOverlap: CGFloat = FKCellKitLayoutMetrics.verticalInset

  /// Creates a timeline connector column.
  public init(configuration: Configuration = .init()) {
    self.configuration = configuration
    super.init(frame: .zero)
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Applies node state and connector visibility for a timeline row.
  public func apply(
    state: FKFlowStepState,
    stepIndex: Int,
    showsTopConnector: Bool,
    showsBottomConnector: Bool,
    topConnectorCompleted: Bool,
    bottomConnectorCompleted: Bool
  ) {
    let appearance = configuration.appearance.appearance(for: state)
    nodeView.backgroundColor = appearance.fillColor
    applyBorder(appearance.border, to: nodeView)

    let icon = Self.symbolImage(for: state, stepIndex: stepIndex)
    nodeIconView.image = icon
    nodeIconView.tintColor = appearance.iconTint
    nodeIconView.isHidden = icon == nil

    topConnector.isHidden = !showsTopConnector
    bottomConnector.isHidden = !showsBottomConnector
    topConnectorTopConstraint?.constant = showsTopConnector ? -connectorRowOverlap : 0
    bottomConnectorBottomConstraint?.constant = showsBottomConnector ? connectorRowOverlap : 0
    topConnector.backgroundColor = connectorColor(isCompleted: topConnectorCompleted)
    bottomConnector.backgroundColor = connectorColor(isCompleted: bottomConnectorCompleted)

    nodeWidthConstraint?.constant = configuration.nodeDiameter
    nodeHeightConstraint?.constant = configuration.nodeDiameter
    nodeView.layer.cornerRadius = configuration.nodeDiameter / 2

    let connectorThickness = configuration.appearance.connector.thickness
    topConnectorWidthConstraint?.constant = connectorThickness
    bottomConnectorWidthConstraint?.constant = connectorThickness
  }

  /// Resets connector views during reuse.
  public func prepareForReuse() {
    nodeIconView.image = nil
    topConnector.isHidden = true
    bottomConnector.isHidden = true
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    clipsToBounds = false
    setContentHuggingPriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .horizontal)

    [topConnector, nodeView, bottomConnector].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      addSubview($0)
    }

    nodeIconView.translatesAutoresizingMaskIntoConstraints = false
    nodeIconView.contentMode = .scaleAspectFit
    nodeView.addSubview(nodeIconView)

    nodeWidthConstraint = nodeView.widthAnchor.constraint(equalToConstant: configuration.nodeDiameter)
    nodeHeightConstraint = nodeView.heightAnchor.constraint(equalToConstant: configuration.nodeDiameter)
    let connectorThickness = configuration.appearance.connector.thickness
    topConnectorWidthConstraint = topConnector.widthAnchor.constraint(equalToConstant: connectorThickness)
    bottomConnectorWidthConstraint = bottomConnector.widthAnchor.constraint(equalToConstant: connectorThickness)

    topConnectorTopConstraint = topConnector.topAnchor.constraint(
      equalTo: topAnchor,
      constant: -connectorRowOverlap
    )
    bottomConnectorBottomConstraint = bottomConnector.bottomAnchor.constraint(
      equalTo: bottomAnchor,
      constant: connectorRowOverlap
    )

    NSLayoutConstraint.activate([
      topConnectorTopConstraint!,
      topConnector.centerXAnchor.constraint(equalTo: centerXAnchor),
      topConnectorWidthConstraint!,
      topConnector.bottomAnchor.constraint(equalTo: nodeView.topAnchor),

      nodeView.centerXAnchor.constraint(equalTo: centerXAnchor),
      nodeView.centerYAnchor.constraint(equalTo: centerYAnchor),
      nodeWidthConstraint!,
      nodeHeightConstraint!,

      bottomConnector.topAnchor.constraint(equalTo: nodeView.bottomAnchor),
      bottomConnector.centerXAnchor.constraint(equalTo: centerXAnchor),
      bottomConnectorWidthConstraint!,
      bottomConnectorBottomConstraint!,

      nodeIconView.centerXAnchor.constraint(equalTo: nodeView.centerXAnchor),
      nodeIconView.centerYAnchor.constraint(equalTo: nodeView.centerYAnchor),
      nodeIconView.widthAnchor.constraint(lessThanOrEqualTo: nodeView.widthAnchor, multiplier: 0.55),
      nodeIconView.heightAnchor.constraint(lessThanOrEqualTo: nodeView.heightAnchor, multiplier: 0.55),
    ])
  }

  private func connectorColor(isCompleted: Bool) -> UIColor {
    isCompleted ? configuration.appearance.connector.completedColor : configuration.appearance.connector.upcomingColor
  }

  private func applyBorder(_ border: FKLayerBorderStyle, to view: UIView) {
    switch border {
    case .none:
      view.layer.borderWidth = 0
      view.layer.borderColor = nil
    case .custom(let color, let width):
      view.layer.borderWidth = width
      view.layer.borderColor = color.cgColor
    }
  }

  private static func symbolImage(for state: FKFlowStepState, stepIndex: Int) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
    switch state {
    case .completed:
      return UIImage(systemName: "checkmark", withConfiguration: config)
    case .current:
      return UIImage(systemName: "\(min(stepIndex + 1, 50)).circle.fill", withConfiguration: config)
        ?? UIImage(systemName: "circle.fill", withConfiguration: config)
    case .error:
      return UIImage(systemName: "xmark", withConfiguration: config)
    case .upcoming, .skipped, .disabled:
      return nil
    }
  }
}
