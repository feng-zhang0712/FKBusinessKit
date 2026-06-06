import FKBusinessKit
import UIKit

/// Exercises keyboard avoidance on ``FKBaseTableViewController`` with bottom ``UITextField`` and ``UITextView`` rows.
final class FKBaseTableKeyboardExampleViewController: FKBusinessKitBase.TableViewController, UITableViewDataSource {

  private enum Section: Int, CaseIterable {
    case intro
    case filler
    case inputs
  }

  private let fillerRowCount = 14
  private let emailField = UITextField()
  private let noteField = UITextView()

  init() {
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Table keyboard"
    configureInputFields()
  }

  override func configureTableView(_ tableView: UITableView) {
    super.configureTableView(tableView)
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "intro")
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filler")
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "email")
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "note")
  }

  private func configureInputFields() {
    emailField.borderStyle = .roundedRect
    emailField.placeholder = "Email (UITextField)"
    emailField.keyboardType = .emailAddress
    emailField.autocapitalizationType = .none
    emailField.translatesAutoresizingMaskIntoConstraints = false

    noteField.font = .preferredFont(forTextStyle: .body)
    noteField.layer.borderColor = UIColor.separator.cgColor
    noteField.layer.borderWidth = 1.0 / UIScreen.main.scale
    noteField.layer.cornerRadius = 8.0
    noteField.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    noteField.isScrollEnabled = false
    noteField.text = "Note (UITextView) — scroll here first, then focus."
    noteField.translatesAutoresizingMaskIntoConstraints = false
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .intro: return 1
    case .filler: return fillerRowCount
    case .inputs: return 2
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section)! {
    case .intro: return nil
    case .filler: return "Scroll down"
    case .inputs: return "Bottom inputs"
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch Section(rawValue: indexPath.section)! {
    case .intro:
      let cell = tableView.dequeueReusableCell(withIdentifier: "intro", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = "Keyboard test"
      content.secondaryText =
        "Inputs are the last rows. FKBaseTableViewController uses keyboardLayoutGuide plus UITableView editing scroll (keyboardFocusScrollView stays nil)."
      content.secondaryTextProperties.color = .secondaryLabel
      content.secondaryTextProperties.numberOfLines = 0
      cell.contentConfiguration = content
      return cell

    case .filler:
      let cell = tableView.dequeueReusableCell(withIdentifier: "filler", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = "Filler row \(indexPath.row + 1)"
      content.secondaryText = "Keeps the input section off-screen until you scroll."
      content.secondaryTextProperties.color = .secondaryLabel
      cell.contentConfiguration = content
      return cell

    case .inputs:
      if indexPath.row == 0 {
        return emailInputCell(tableView: tableView, indexPath: indexPath)
      }
      return noteInputCell(tableView: tableView, indexPath: indexPath)
    }
  }

  private func emailInputCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath)
    cell.selectionStyle = .none
    cell.contentConfiguration = nil
    if emailField.superview !== cell.contentView {
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }
      cell.contentView.addSubview(emailField)
      NSLayoutConstraint.activate([
        emailField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
        emailField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
        emailField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
        emailField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
        emailField.heightAnchor.constraint(equalToConstant: 44),
      ])
    }
    return cell
  }

  private func noteInputCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
    cell.selectionStyle = .none
    cell.contentConfiguration = nil
    if noteField.superview !== cell.contentView {
      cell.contentView.subviews.forEach { $0.removeFromSuperview() }
      cell.contentView.addSubview(noteField)
      NSLayoutConstraint.activate([
        noteField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
        noteField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
        noteField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
        noteField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
        noteField.heightAnchor.constraint(equalToConstant: 100),
      ])
    }
    return cell
  }
}
