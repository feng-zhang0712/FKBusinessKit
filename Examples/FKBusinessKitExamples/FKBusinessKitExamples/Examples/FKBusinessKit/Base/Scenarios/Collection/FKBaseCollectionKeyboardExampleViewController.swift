import FKBusinessKit
import UIKit

/// Exercises keyboard avoidance on ``FKBaseCollectionViewController`` with bottom ``UITextField`` and ``UITextView`` items.
final class FKBaseCollectionKeyboardExampleViewController: FKBusinessKitBase.CollectionViewController {

  private enum ItemKind {
    case intro
    case filler(Int)
    case email
    case note
  }

  private static let introId = "intro"
  private static let fillerId = "filler"
  private static let emailId = "email"
  private static let noteId = "note"

  private var items: [ItemKind] = []
  private let emailField = UITextField()
  private let noteField = UITextView()

  override init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    super.init(collectionViewLayout: layout)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Collection keyboard"
    configureInputFields()
    items = [.intro]
      + (1...12).map { .filler($0) }
      + [.email, .note]
  }

  override func configureCollectionView(_ collectionView: UICollectionView) {
    super.configureCollectionView(collectionView)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.introId)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.fillerId)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.emailId)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.noteId)
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
}

extension FKBaseCollectionKeyboardExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch items[indexPath.item] {
    case .intro:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.introId, for: indexPath)
      configureIntroCell(cell)
      return cell
    case let .filler(index):
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.fillerId, for: indexPath)
      configureFillerCell(cell, index: index)
      return cell
    case .email:
      return emailCell(collectionView: collectionView, indexPath: indexPath)
    case .note:
      return noteCell(collectionView: collectionView, indexPath: indexPath)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let inset = layout.sectionInset.left + layout.sectionInset.right
    let fullWidth = collectionView.bounds.width - inset
    switch items[indexPath.item] {
    case .intro:
      return CGSize(width: fullWidth, height: 96)
    case .filler:
      let spacing = layout.minimumInteritemSpacing
      let columnWidth = (fullWidth - spacing) / 2
      return CGSize(width: max(60, columnWidth), height: 56)
    case .email:
      return CGSize(width: fullWidth, height: 60)
    case .note:
      return CGSize(width: fullWidth, height: 124)
    }
  }

  private func configureIntroCell(_ cell: UICollectionViewCell) {
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    let label = UILabel()
    label.numberOfLines = 0
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = .secondaryLabel
    label.text =
      "Inputs are the last items. FKBaseCollectionViewController uses keyboardLayoutGuide plus keyboardFocusScrollView first-responder scrolling."
    label.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
      label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
      label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
    ])
  }

  private func configureFillerCell(_ cell: UICollectionViewCell, index: Int) {
    cell.contentView.backgroundColor = .secondarySystemGroupedBackground
    cell.contentView.layer.cornerRadius = 8
    cell.contentView.clipsToBounds = true
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .caption1)
    label.textAlignment = .center
    label.text = "Tile \(index)"
    label.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
    ])
  }

  private func emailCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.emailId, for: indexPath)
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    cell.contentView.addSubview(emailField)
    NSLayoutConstraint.activate([
      emailField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
      emailField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
      emailField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
      emailField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
    ])
    return cell
  }

  private func noteCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.noteId, for: indexPath)
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    cell.contentView.addSubview(noteField)
    NSLayoutConstraint.activate([
      noteField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
      noteField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
      noteField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
      noteField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
    ])
    return cell
  }
}
