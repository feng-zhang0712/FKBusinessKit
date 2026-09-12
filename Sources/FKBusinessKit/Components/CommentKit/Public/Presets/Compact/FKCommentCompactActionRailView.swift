import UIKit

/// Left-aligned like · reply · more rail used inside the compact meta stripe.
@MainActor
public final class FKCommentCompactActionRailView: UIView {
  /// Fired when like is tapped.
  public var onLike: (() -> Void)?
  /// Fired when reply is tapped.
  public var onReply: (() -> Void)?
  /// Fired when more is tapped. The argument is the more button (popover anchor).
  public var onMore: ((UIView) -> Void)?

  /// Visual tokens shared with the standard action bar.
  public var configuration: FKCommentActionBarConfiguration = .init() {
    didSet { applyConfiguration() }
  }

  public var strings: FKCommentKitStrings = .init() {
    didSet {
      updateReplyAppearance()
      applyAccessibility()
    }
  }

  public var showsLike: Bool = true {
    didSet { updateButtonVisibility() }
  }

  public var showsReply: Bool = true {
    didSet { updateButtonVisibility() }
  }

  public var showsMore: Bool = true {
    didSet { updateButtonVisibility() }
  }

  /// `true` when at least one action button is visible.
  public var hasVisibleActions: Bool {
    showsLike || showsReply || showsMore
  }

  private let stack = UIStackView()
  private let likeButton = UIButton(type: .system)
  private let replyButton = UIButton(type: .system)
  private let moreButton = UIButton(type: .system)
  private var isLiked = false
  private var likeCount = 0
  private var likeCountText: String?

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  /// Binds like state.
  public func apply(isLiked: Bool, likeCount: Int, likeCountText: String? = nil) {
    self.isLiked = isLiked
    self.likeCount = max(0, likeCount)
    self.likeCountText = likeCountText
    updateLikeAppearance()
    applyAccessibility()
  }

  /// Clears callbacks for cell reuse.
  public func prepareForReuse() {
    onLike = nil
    onReply = nil
    onMore = nil
    isLiked = false
    likeCount = 0
    likeCountText = nil
    updateLikeAppearance()
  }

  public override var intrinsicContentSize: CGSize {
    guard hasVisibleActions else {
      return CGSize(width: UIView.noIntrinsicMetric, height: 0)
    }
    return CGSize(width: UIView.noIntrinsicMetric, height: max(configuration.minimumHeight, 28))
  }

  private func setup() {
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)

    configureButton(likeButton, action: #selector(handleLike))
    configureButton(replyButton, action: #selector(handleReply))
    configureButton(moreButton, action: #selector(handleMore))

    stack.addArrangedSubview(likeButton)
    stack.addArrangedSubview(replyButton)
    stack.addArrangedSubview(moreButton)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
      // Do not pin trailing — buttons stay leading-packed when the rail is given extra width.
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
    ])

    applyConfiguration()
    updateButtonVisibility()
  }

  private func configureButton(_ button: UIButton, action: Selector) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: action, for: .touchUpInside)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private func applyConfiguration() {
    stack.spacing = configuration.spacing
    updateLikeAppearance()
    updateReplyAppearance()
    updateMoreAppearance()
    invalidateIntrinsicContentSize()
  }

  private func updateLikeAppearance() {
    let tint = isLiked ? configuration.likedTintColor : configuration.buttonTintColor
    let title: String?
    if configuration.showsLikeCount {
      if let likeCountText, !likeCountText.isEmpty {
        title = likeCountText
      } else if likeCount > 0 {
        title = Self.compactCount(likeCount)
      } else {
        title = nil
      }
    } else {
      title = nil
    }
    applyPlainConfiguration(
      to: likeButton,
      image: configuration.resolvedLikeImage(isLiked: isLiked),
      title: title,
      tintColor: tint
    )
  }

  private func updateReplyAppearance() {
    applyPlainConfiguration(
      to: replyButton,
      image: configuration.resolvedReplyImage(),
      title: configuration.showsReplyTitle ? strings.reply : nil,
      tintColor: configuration.buttonTintColor
    )
  }

  private func updateMoreAppearance() {
    applyPlainConfiguration(
      to: moreButton,
      image: configuration.resolvedMoreImage(),
      title: nil,
      tintColor: configuration.buttonTintColor
    )
  }

  private func applyPlainConfiguration(
    to button: UIButton,
    image: UIImage?,
    title: String?,
    tintColor: UIColor
  ) {
    var config = UIButton.Configuration.plain()
    config.contentInsets = .zero
    config.imagePadding = title == nil ? 0 : configuration.iconTitleSpacing
    config.image = image
    config.title = title
    config.imagePlacement = .leading
    config.baseForegroundColor = tintColor
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = self.configuration.resolvedContentFont()
      return outgoing
    }
    button.configuration = config
    button.tintColor = tintColor
  }

  private func updateButtonVisibility() {
    likeButton.isHidden = !showsLike
    replyButton.isHidden = !showsReply
    moreButton.isHidden = !showsMore
    isHidden = !hasVisibleActions
    invalidateIntrinsicContentSize()
  }

  private func applyAccessibility() {
    likeButton.accessibilityLabel = isLiked ? strings.unlike : strings.like
    replyButton.accessibilityLabel = strings.reply
    moreButton.accessibilityLabel = strings.more
  }

  /// Compact English count (e.g. `1400` → `1.4k`).
  public static func compactCount(_ value: Int) -> String {
    let absValue = abs(value)
    switch absValue {
    case 1_000_000...:
      let scaled = Double(absValue) / 1_000_000
      return String(format: scaled >= 10 ? "%.0fm" : "%.1fm", locale: Locale(identifier: "en_US_POSIX"), scaled)
    case 1_000...:
      let scaled = Double(absValue) / 1_000
      return String(format: scaled >= 10 ? "%.0fk" : "%.1fk", locale: Locale(identifier: "en_US_POSIX"), scaled)
    default:
      return String(absValue)
    }
  }

  @objc private func handleLike() {
    onLike?()
  }

  @objc private func handleReply() {
    onReply?()
  }

  @objc private func handleMore() {
    onMore?(moreButton)
  }
}
