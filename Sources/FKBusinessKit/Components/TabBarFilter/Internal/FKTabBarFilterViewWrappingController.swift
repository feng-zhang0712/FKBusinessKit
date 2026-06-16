import UIKit
import FKUIKit

@MainActor
internal final class FKTabBarFilterViewWrappingController: UIViewController {
  private let makeView: () -> UIView
  private var contentView: UIView?

  init(makeView: @escaping () -> UIView) {
    self.makeView = makeView
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .clear
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let content = makeView()
    content.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(content)
    contentView = content
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: view.topAnchor),
      content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    publishPreferredContentSizeIfNeeded()
  }

  /// Publishes intrinsic height so ``FKSheetPresentationAnchorContentHostViewController`` can size the anchor panel.
  private func publishPreferredContentSizeIfNeeded() {
    let width = view.bounds.width
    guard width > 0 else { return }

    let measured = view.systemLayoutSizeFitting(
      CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    let target = CGSize(width: UIView.noIntrinsicMetric, height: max(44, measured.height))
    guard preferredContentSize != target else { return }
    preferredContentSize = target
  }
}
