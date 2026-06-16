import UIKit
import FKUIKit

/// Layout tokens for ``FKFeedImageGridView``.
public struct FKFeedImageGridConfiguration: Equatable {
  /// Maximum number of images rendered in the grid.
  public var maxImageCount: Int
  /// Column count for multi-image layouts (two or more images).
  public var columns: Int
  /// Spacing between grid tiles.
  public var spacing: CGFloat
  /// Corner radius applied to each tile.
  public var imageCornerRadius: CGFloat
  /// Width-to-height ratio for a single-image layout.
  public var singleImageAspectRatio: CGFloat
  /// Maximum height for a single-image layout.
  public var singleImageMaxHeight: CGFloat

  /// Default square tile side used for prefetch sizing.
  public static let defaultTileSide: CGFloat = 108

  /// Default grid configuration aligned with common social feed layouts.
  public static var `default`: FKFeedImageGridConfiguration { .init() }

  /// Creates feed image grid layout configuration.
  public init(
    maxImageCount: Int = 9,
    columns: Int = 3,
    spacing: CGFloat = 4,
    imageCornerRadius: CGFloat = 6,
    singleImageAspectRatio: CGFloat = 0.75,
    singleImageMaxHeight: CGFloat = 220
  ) {
    self.maxImageCount = maxImageCount
    self.columns = max(1, columns)
    self.spacing = spacing
    self.imageCornerRadius = imageCornerRadius
    self.singleImageAspectRatio = singleImageAspectRatio
    self.singleImageMaxHeight = singleImageMaxHeight
  }
}

/// Nine-grid image composite used by ``FKFeedContentCell``.
@MainActor
public final class FKFeedImageGridView: UIView {
  /// Layout tokens for the grid.
  public var configuration: FKFeedImageGridConfiguration {
    didSet {
      applyCornerRadius()
      invalidateIntrinsicContentSize()
      setNeedsLayout()
    }
  }

  private var imageViews: [FKImageView] = []
  private var overflowBadge: UILabel?
  private var imageCount = 0

  /// Creates a feed image grid view.
  public init(configuration: FKFeedImageGridConfiguration = .default) {
    self.configuration = configuration
    super.init(frame: .zero)
    setupUI()
    applyCornerRadius()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Binds remote image URLs to the grid (capped at ``FKFeedImageGridConfiguration/maxImageCount``).
  public func apply(imageURLs: [URL]) {
    imageCount = min(imageURLs.count, configuration.maxImageCount)
    syncImageViews(to: imageCount)

    for index in 0 ..< imageCount {
      let imageView = imageViews[index]
      imageView.isHidden = false
      imageView.load(url: imageURLs[index])
    }

    let overflow = imageURLs.count - configuration.maxImageCount
    if overflow > 0, imageCount > 0 {
      ensureOverflowBadge().text = "+\(overflow)"
    } else {
      releaseOverflowBadge()
    }

    isHidden = imageCount == 0
    invalidateIntrinsicContentSize()
    setNeedsLayout()
  }

  /// Computes the grid height for a given image count and content width.
  public static func preferredHeight(
    imageCount: Int,
    width: CGFloat,
    configuration: FKFeedImageGridConfiguration = .default
  ) -> CGFloat {
    guard imageCount > 0, width > 0 else { return 0 }
    if imageCount == 1 {
      return min(width * configuration.singleImageAspectRatio, configuration.singleImageMaxHeight)
    }
    let columns = configuration.columns
    let tileSide = tileSide(for: width, columns: columns, spacing: configuration.spacing)
    let rows = (imageCount + columns - 1) / columns
    return CGFloat(rows) * tileSide + CGFloat(max(0, rows - 1)) * configuration.spacing
  }

  /// Clears image loads and releases tile views during cell reuse.
  public func prepareForReuse() {
    releaseImageViews(from: 0)
    releaseOverflowBadge()
    imageCount = 0
    isHidden = true
    invalidateIntrinsicContentSize()
  }

  public override var intrinsicContentSize: CGSize {
    let layoutWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
    let height = Self.preferredHeight(
      imageCount: imageCount,
      width: layoutWidth,
      configuration: configuration
    )
    return CGSize(width: UIView.noIntrinsicMetric, height: height)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    guard imageCount > 0, bounds.width > 0 else { return }

    if imageCount == 1 {
      let height = Self.preferredHeight(
        imageCount: 1,
        width: bounds.width,
        configuration: configuration
      )
      imageViews[0].frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
      positionOverflowBadge(on: imageViews[0])
      return
    }

    let columns = configuration.columns
    let tileSide = Self.tileSide(for: bounds.width, columns: columns, spacing: configuration.spacing)
    for index in 0 ..< imageCount {
      let row = index / columns
      let column = index % columns
      let originX = CGFloat(column) * (tileSide + configuration.spacing)
      let originY = CGFloat(row) * (tileSide + configuration.spacing)
      imageViews[index].frame = CGRect(x: originX, y: originY, width: tileSide, height: tileSide)
    }
    if let lastVisible = imageViews[safe: imageCount - 1] {
      positionOverflowBadge(on: lastVisible)
    }
  }

  private static func tileSide(for width: CGFloat, columns: Int, spacing: CGFloat) -> CGFloat {
    (width - spacing * CGFloat(max(0, columns - 1))) / CGFloat(columns)
  }

  private func setupUI() {
    translatesAutoresizingMaskIntoConstraints = false
    clipsToBounds = false
  }

  @discardableResult
  private func ensureOverflowBadge() -> UILabel {
    if let overflowBadge { return overflowBadge }

    let badge = UILabel()
    badge.font = UIFont.preferredFont(forTextStyle: .caption1)
    badge.textColor = .white
    badge.textAlignment = .center
    badge.backgroundColor = UIColor.black.withAlphaComponent(0.55)
    badge.layer.masksToBounds = true
    badge.translatesAutoresizingMaskIntoConstraints = false
    addSubview(badge)
    overflowBadge = badge
    return badge
  }

  private func releaseOverflowBadge() {
    guard let overflowBadge else { return }
    overflowBadge.text = nil
    overflowBadge.removeFromSuperview()
    self.overflowBadge = nil
  }

  private func syncImageViews(to count: Int) {
    ensureImageViews(count: count)
    releaseImageViews(from: count)
  }

  private func ensureImageViews(count: Int) {
    while imageViews.count < count {
      let imageView = FKImageView()
      imageView.clipsToBounds = true
      imageView.contentMode = .scaleAspectFill
      imageView.layer.cornerRadius = configuration.imageCornerRadius
      addSubview(imageView)
      imageViews.append(imageView)
    }
  }

  private func releaseImageViews(from startIndex: Int) {
    guard startIndex < imageViews.count else { return }
    for index in startIndex ..< imageViews.count {
      imageViews[index].resetForReuse()
      imageViews[index].removeFromSuperview()
    }
    imageViews.removeSubrange(startIndex ..< imageViews.count)
  }

  private func applyCornerRadius() {
    imageViews.forEach { $0.layer.cornerRadius = configuration.imageCornerRadius }
  }

  private func positionOverflowBadge(on tile: UIView) {
    guard let overflowBadge else { return }
    let badgeSize = CGSize(width: 36, height: 22)
    overflowBadge.frame = CGRect(
      x: tile.frame.maxX - badgeSize.width - 4,
      y: tile.frame.maxY - badgeSize.height - 4,
      width: badgeSize.width,
      height: badgeSize.height
    )
    overflowBadge.layer.cornerRadius = 4
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    guard indices.contains(index) else { return nil }
    return self[index]
  }
}
