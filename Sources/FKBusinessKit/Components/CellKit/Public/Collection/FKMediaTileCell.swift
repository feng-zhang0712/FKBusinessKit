import UIKit
import FKUIKit

/// Square media tile with optional duration badge and selection overlay.
@MainActor
public final class FKMediaTileCell: FKCellKitCollectionCell, FKListCollectionCellConfigurable {
  public typealias Item = FKMediaTileItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Recommended square tile size for photo grids.
  public static var preferredItemSize: CGSize { FKMediaTileCellConfiguration.defaultItemSize }

  /// Tile-specific configuration.
  public var mediaTileConfiguration: FKMediaTileCellConfiguration = FKCellKitDefaults.mediaTileCell {
    didSet { applyMediaTileConfiguration() }
  }

  private let coverImageView = FKImageView()
  private var durationBackground: UIView?
  private var durationLabel: UILabel?
  private var selectionImageView: UIImageView?
  private var durationLabelConstraints: [NSLayoutConstraint] = []
  private var durationBackgroundConstraints: [NSLayoutConstraint] = []
  private var selectionConstraints: [NSLayoutConstraint] = []

  /// Binds a media tile item to the cell UI.
  public func configure(with item: FKMediaTileItem) {
    coverImageView.load(url: item.imageURL)

    if let duration = item.durationText, !duration.isEmpty {
      ensureDurationBadge().label.text = duration
    } else {
      releaseDurationBadge()
    }

    if item.isSelected {
      ensureSelectionImageView()
    } else {
      releaseSelectionImageView()
    }

    updateAccessibility(for: item)
  }

  public override func setupUI() {
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    coverImageView.clipsToBounds = true

    containerView.addSubview(coverImageView)

    NSLayoutConstraint.activate([
      coverImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
      coverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      coverImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      coverImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyMediaTileConfiguration()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    durationBackground?.layer.cornerRadius = 4
  }

  public override func resetCellContent() {
    super.resetCellContent()
    coverImageView.resetForReuse()
    releaseDurationBadge()
    releaseSelectionImageView()
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyMediaTileConfiguration()
  }

  private func applyMediaTileConfiguration() {
    containerInsets = mediaTileConfiguration.contentInsets
    cornerRadius = mediaTileConfiguration.cornerRadius
    coverImageView.layer.cornerRadius = mediaTileConfiguration.imageCornerRadius
    durationLabel?.font = UIFont.preferredFont(forTextStyle: mediaTileConfiguration.durationTextStyle)
    durationBackground?.backgroundColor = mediaTileConfiguration.durationBackgroundColor
    durationLabel?.textColor = mediaTileConfiguration.durationTextColor
    selectionImageView?.tintColor = mediaTileConfiguration.selectionTintColor
    selectionImageView?.image = UIImage(systemName: mediaTileConfiguration.selectionSymbolName)
    applyCellConfiguration()
  }

  private struct DurationBadge {
    let background: UIView
    let label: UILabel
  }

  @discardableResult
  private func ensureDurationBadge() -> DurationBadge {
    if let durationBackground, let durationLabel {
      return DurationBadge(background: durationBackground, label: durationLabel)
    }

    let background = UIView()
    background.layer.masksToBounds = true
    background.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.textColor = mediaTileConfiguration.durationTextColor
    label.textAlignment = .center
    label.font = UIFont.preferredFont(forTextStyle: mediaTileConfiguration.durationTextStyle)
    label.translatesAutoresizingMaskIntoConstraints = false
    background.addSubview(label)

    containerView.addSubview(background)
    durationBackground = background
    durationLabel = label

    durationBackgroundConstraints = [
      background.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
      background.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
    ]
    durationLabelConstraints = [
      label.topAnchor.constraint(equalTo: background.topAnchor, constant: 2),
      label.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -2),
      label.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 6),
      label.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -6),
    ]
    background.backgroundColor = mediaTileConfiguration.durationBackgroundColor
    NSLayoutConstraint.activate(durationBackgroundConstraints + durationLabelConstraints)
    return DurationBadge(background: background, label: label)
  }

  private func releaseDurationBadge() {
    guard durationBackground != nil || durationLabel != nil else { return }
    NSLayoutConstraint.deactivate(durationBackgroundConstraints + durationLabelConstraints)
    durationBackgroundConstraints = []
    durationLabelConstraints = []
    durationLabel?.removeFromSuperview()
    durationBackground?.removeFromSuperview()
    durationLabel = nil
    durationBackground = nil
  }

  private func ensureSelectionImageView() {
    guard selectionImageView == nil else { return }

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = mediaTileConfiguration.selectionTintColor
    imageView.image = UIImage(systemName: mediaTileConfiguration.selectionSymbolName)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(imageView)
    selectionImageView = imageView

    selectionConstraints = [
      imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
      imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
      imageView.widthAnchor.constraint(equalToConstant: 24),
      imageView.heightAnchor.constraint(equalToConstant: 24),
    ]
    NSLayoutConstraint.activate(selectionConstraints)
  }

  private func releaseSelectionImageView() {
    guard let selectionImageView else { return }
    NSLayoutConstraint.deactivate(selectionConstraints)
    selectionConstraints = []
    selectionImageView.removeFromSuperview()
    self.selectionImageView = nil
  }

  private func updateAccessibility(for item: FKMediaTileItem) {
    var label = "Media"
    if let duration = item.durationText, !duration.isEmpty {
      label += ", duration \(duration)"
    }
    if item.isSelected {
      label += ", selected"
    }
    accessibilityLabel = label
  }
}

extension FKMediaTileCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    coverImageView.resetForReuse()
  }
}
