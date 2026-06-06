import FKBusinessKit
import UIKit

/// Demonstrates ``FKBaseScrollViewController`` with scrollable form content, keyboard avoidance,
/// and optional pull-to-refresh.
final class FKBaseScrollViewControllerExampleViewController: FKBusinessKitBase.ScrollViewController {

  private let titleLabel = UILabel()
  private let bodyLabel = UILabel()
  private let nameField = UITextField()
  private let emailField = UITextField()
  private let noteField = UITextView()
  private let refreshStatusLabel = UILabel()

  override init() {
    super.init()
    isPullToRefreshEnabled = true
    contentLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    isPullToRefreshEnabled = true
    contentLayoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
  }

  override func setupUI() {
    super.setupUI()
    title = "FKBaseScrollViewController"

    titleLabel.text = "Scroll + contentView"
    titleLabel.font = .preferredFont(forTextStyle: .title2)
    titleLabel.numberOfLines = 0

    bodyLabel.text =
      "Subviews live in contentView. The scroll view uses keyboardLayoutGuide plus automatic first-responder scrolling so fields (including UITextView) stay above the keyboard."
    bodyLabel.font = .preferredFont(forTextStyle: .body)
    bodyLabel.textColor = .secondaryLabel
    bodyLabel.numberOfLines = 0

    nameField.placeholder = "Name"
    nameField.borderStyle = .roundedRect
    nameField.autocapitalizationType = .words

    emailField.placeholder = "Email"
    emailField.borderStyle = .roundedRect
    emailField.keyboardType = .emailAddress
    emailField.autocapitalizationType = .none

    noteField.font = .preferredFont(forTextStyle: .body)
    noteField.layer.borderColor = UIColor.separator.cgColor
    noteField.layer.borderWidth = 1.0 / UIScreen.main.scale
    noteField.layer.cornerRadius = 8.0
    noteField.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    noteField.text = "Pull down to refresh. Tap outside or drag the scroll view to dismiss the keyboard."

    refreshStatusLabel.font = .preferredFont(forTextStyle: .footnote)
    refreshStatusLabel.textColor = .tertiaryLabel
    refreshStatusLabel.numberOfLines = 0
    refreshStatusLabel.text = "Pull-to-refresh not triggered yet."

    [titleLabel, bodyLabel, nameField, emailField, noteField, refreshStatusLabel].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview($0)
    }

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

      bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

      nameField.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 20),
      nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      nameField.heightAnchor.constraint(equalToConstant: 44),

      emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
      emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      emailField.heightAnchor.constraint(equalToConstant: 44),

      noteField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
      noteField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      noteField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      noteField.heightAnchor.constraint(equalToConstant: 120),

      refreshStatusLabel.topAnchor.constraint(equalTo: noteField.bottomAnchor, constant: 20),
      refreshStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      refreshStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      refreshStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

  override func performPullToRefresh() {
    refreshStatusLabel.text = "Refreshing…"
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      let formatter = DateFormatter()
      formatter.timeStyle = .medium
      self.refreshStatusLabel.text = "Last refreshed at \(formatter.string(from: Date()))."
      self.endPullToRefresh(success: true)
    }
  }
}
