import UIKit

/// Like / Reply / More control strip for comment rows.
@MainActor
public final class FKCommentActionBarView: UIView {
  /// Fired when the like control is tapped.
  public var onLike: (() -> Void)?
  /// Fired when the reply control is tapped.
  public var onReply: (() -> Void)?
  /// Fired when the more control is tapped. The argument is the more button (popover anchor).
  public var onMore: ((UIView) -> Void)?

  /// Visual configuration.
  public var configuration: FKCommentActionBarConfiguration = .init() {
    didSet { applyConfiguration() }
  }

  /// Copy tokens for accessibility and optional titles.
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
  private var heightConstraint: NSLayoutConstraint?
  private var isLiked: Bool = false
  private var likeCount: Int = 0

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  /// Binds like state and count.
  public func apply(isLiked: Bool, likeCount: Int) {
    self.isLiked = isLiked
    self.likeCount = max(0, likeCount)
    updateLikeAppearance()
    applyAccessibility()
  }

  /// Clears transient UI for cell reuse.
  public func prepareForReuse() {
    onLike = nil
    onReply = nil
    onMore = nil
    isLiked = false
    likeCount = 0
    updateLikeAppearance()
  }

  public override var intrinsicContentSize: CGSize {
    guard hasVisibleActions else {
      return CGSize(width: UIView.noIntrinsicMetric, height: 0)
    }
    return CGSize(width: UIView.noIntrinsicMetric, height: configuration.minimumHeight)
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

    let height = heightAnchor.constraint(equalToConstant: configuration.minimumHeight)
    heightConstraint = height

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor),
      height,
    ])

    applyConfiguration()
    updateLikeAppearance()
    applyAccessibility()
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
    heightConstraint?.constant = configuration.minimumHeight
    updateLikeAppearance()
    updateReplyAppearance()
    updateMoreAppearance()
    invalidateIntrinsicContentSize()
  }

  private func updateLikeAppearance() {
    let title: String?
    if configuration.showsLikeCount, likeCount > 0 {
      title = String(likeCount)
    } else {
      title = nil
    }
    let tint = isLiked ? configuration.likedTintColor : configuration.buttonTintColor
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
    let visible = hasVisibleActions
    isHidden = !visible
    heightConstraint?.constant = visible ? configuration.minimumHeight : 0
    heightConstraint?.isActive = visible
    invalidateIntrinsicContentSize()
  }

  private func applyAccessibility() {
    likeButton.accessibilityLabel = isLiked ? strings.unlike : strings.like
    replyButton.accessibilityLabel = strings.reply
    moreButton.accessibilityLabel = strings.more
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
