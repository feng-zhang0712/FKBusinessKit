import UIKit
import FKUIKit

/// Compact layout skeleton for CommentKit: author + trailing time → body → meta (like · Reply · more), expand row.
@MainActor
public final class FKCommentCompactRowCell: FKBaseTableViewCell, FKListTableCellConfigurable {
  public typealias Item = FKCommentItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Fallback estimated height before measurement.
  public static let preferredRowHeight: CGFloat = 88

  public var rowConfiguration: FKCommentRowCellConfiguration = FKCommentCompactDefaults.makeRowConfiguration() {
    didSet { applyRowConfiguration() }
  }

  public var strings: FKCommentKitStrings = FKCommentCompactDefaults.makeStrings() {
    didSet { updateExpandButtonTitle() }
  }

  public var actionBarConfiguration: FKCommentActionBarConfiguration =
    FKCommentCompactDefaults.makeActionBarConfiguration()
  {
    didSet { actionRail.configuration = actionBarConfiguration }
  }

  public var showsLikeAction: Bool = true {
    didSet { syncActionRailVisibility() }
  }

  public var showsReplyAction: Bool = true {
    didSet { syncActionRailVisibility() }
  }

  public var showsMoreAction: Bool = true {
    didSet { syncActionRailVisibility() }
  }

  public var showsCopyAction: Bool = true
  public var showsReportAction: Bool = true
  /// Mirrors ``FKCommentKitConfiguration/presentsDefaultMoreMenu`` for more-button visibility.
  public var presentsDefaultMoreMenu: Bool = true
  /// When `true`, More stays available even if built-in copy / report / delete are hidden.
  public var hasAdditionalMoreActions: Bool = false

  public var expandAffordanceMinimumReplyCount: Int = 1

  public var beginsReplyOnRowTap: Bool = true

  public var onLike: ((FKCommentItem) -> Void)?
  public var onReply: ((FKCommentItem) -> Void)?
  /// Fired when more is tapped. Second argument is the more control (popover / menu anchor).
  public var onMore: ((FKCommentItem, UIView) -> Void)?
  public var onAvatar: ((FKCommentItem) -> Void)?
  public var onAuthor: ((FKCommentItem) -> Void)?
  public var onComment: ((FKCommentItem) -> Void)?
  public var onLongPress: ((FKCommentItem) -> Void)?
  public var onToggleExpand: ((FKCommentItem) -> Void)?
  public var onBodyExpansionChange: (() -> Void)?
  /// Fired when the content area is tapped and ``beginsReplyOnRowTap`` is `true`.
  public var onRowTap: ((FKCommentItem) -> Void)?

  private let avatar = FKAvatar()
  private var avatarWidthConstraint: NSLayoutConstraint?
  private var authorHeightConstraint: NSLayoutConstraint?
  private let authorLabel = UILabel()
  private let replyToChevron = UIImageView()
  private let replyToLabel = UILabel()
  private let authorRow = UIStackView()
  private var bodyLabel: UILabel?
  private let metaStack = UIStackView()
  private let metaLabel = UILabel()
  private let actionRail = FKCommentCompactActionRailView()
  private let expandRow = UIStackView()
  private let expandButton = UIButton(type: .system)
  private let expandSpinner = UIActivityIndicatorView(style: .medium)
  private let expandSpinnerSlot = UIView()
  private let textStack = UIStackView()
  private let contentRow = UIStackView()
  private var contentRowLeadingConstraint: NSLayoutConstraint?
  private var boundItem: FKCommentItem?
  private var isExpandLoading = false
  private let rowTapGestureDelegate = FKCommentCompactRowTapGestureDelegate()
  private lazy var rowTapGesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(handleRowTap))
    gesture.cancelsTouchesInView = false
    gesture.delegate = rowTapGestureDelegate
    return gesture
  }()

  private lazy var longPressGesture: UILongPressGestureRecognizer = {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    gesture.cancelsTouchesInView = true
    return gesture
  }()

  /// Binds a comment item to the compact row UI.
  public func configure(with item: FKCommentItem) {
    boundItem = item
    let cappedDepth = min(max(0, item.depth), rowConfiguration.maxDepth)
    let indent = CGFloat(cappedDepth) * rowConfiguration.indentWidth
    contentRowLeadingConstraint?.constant = indent

    let avatarSize = cappedDepth > 0
      ? (rowConfiguration.replyAvatarSize ?? rowConfiguration.avatarSize)
      : rowConfiguration.avatarSize
    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCommentAvatarSupport.applyListRowChrome(
      to: avatar,
      size: avatarSize,
      isVerified: item.isVerified
    )
    avatar.isUserInteractionEnabled = true
    avatarWidthConstraint?.constant = avatarSize.diameter

    authorLabel.text = item.authorName
    if let replyTo = item.replyTo, cappedDepth > 0 {
      replyToChevron.isHidden = false
      replyToLabel.isHidden = false
      replyToLabel.text = replyTo.displayName
    } else {
      replyToChevron.isHidden = true
      replyToLabel.isHidden = true
      replyToLabel.text = nil
    }

    if item.body.isEmpty {
      releaseBodyLabel()
    } else {
      applyBodyText(item.body, to: ensureBodyLabel())
    }

    updateTimestampAppearance(for: item)
    actionRail.strings = strings
    actionRail.configuration = actionBarConfiguration
    actionRail.apply(
      isLiked: item.isLiked,
      likeCount: item.likeCount,
      likeCountText: item.likeCountText
    )
    actionRail.onLike = { [weak self] in
      guard let self, let boundItem = self.boundItem else { return }
      self.onLike?(boundItem)
    }
    actionRail.onReply = { [weak self] in
      guard let self, let boundItem = self.boundItem else { return }
      self.onReply?(boundItem)
    }
    actionRail.onMore = { [weak self] sourceView in
      guard let self, let boundItem = self.boundItem else { return }
      self.onMore?(boundItem, sourceView)
    }
    syncActionRailVisibility()
    updateMetaStackVisibility()

    let shouldShowExpand = item.replyCount >= expandAffordanceMinimumReplyCount
    expandRow.isHidden = !shouldShowExpand
    if shouldShowExpand {
      updateExpandButtonTitle()
    }
    applyExpandLoadingAppearance()
    updateAccessibility(for: item)
  }

  /// Applies kit-level configuration tokens onto the row.
  public func apply(kitConfiguration: FKCommentKitConfiguration) {
    rowConfiguration = kitConfiguration.row
    strings = kitConfiguration.strings
    actionBarConfiguration = kitConfiguration.actionBar
    showsLikeAction = kitConfiguration.showsLikeAction
    showsReplyAction = kitConfiguration.showsReplyAction
    showsMoreAction = kitConfiguration.showsMoreAction
    showsCopyAction = kitConfiguration.showsCopyAction
    showsReportAction = kitConfiguration.showsReportAction
    presentsDefaultMoreMenu = kitConfiguration.presentsDefaultMoreMenu
    hasAdditionalMoreActions = !kitConfiguration.additionalMoreActions.isEmpty
    expandAffordanceMinimumReplyCount = kitConfiguration.expandAffordanceMinimumReplyCount
    beginsReplyOnRowTap = kitConfiguration.beginsReplyOnRowTap
    syncActionRailVisibility()
    updateMetaStackVisibility()
  }

  /// Applies like fields without rebuilding the whole row.
  ///
  /// Pass `likeCountText: nil` to clear a display override and fall back to formatting `likeCount`.
  public func applyLikeState(isLiked: Bool, likeCount: Int, likeCountText: String? = nil) {
    guard var boundItem else { return }
    boundItem.isLiked = isLiked
    boundItem.likeCount = max(0, likeCount)
    boundItem.likeCountText = likeCountText
    self.boundItem = boundItem
    actionRail.apply(
      isLiked: isLiked,
      likeCount: likeCount,
      likeCountText: likeCountText
    )
  }

  /// Shows a spinner while replies load.
  public func setExpandLoading(_ loading: Bool) {
    isExpandLoading = loading
    applyExpandLoadingAppearance()
  }

  /// Whether the more menu would show at least one action for `item`.
  public func hasAvailableMoreActions(for item: FKCommentItem) -> Bool {
    if !presentsDefaultMoreMenu { return true }
    if hasAdditionalMoreActions { return true }
    return (showsCopyAction && !item.body.isEmpty) || showsReportAction || item.isDeletable
  }

  public override func setupUI() {
    selectionStyle = .none
    rowTapGestureDelegate.cell = self
    containerView.addGestureRecognizer(rowTapGesture)
    containerView.addGestureRecognizer(longPressGesture)

    avatar.translatesAutoresizingMaskIntoConstraints = false
    let avatarTap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
    avatar.addGestureRecognizer(avatarTap)

    authorLabel.numberOfLines = 1
    authorLabel.lineBreakMode = .byTruncatingTail
    authorLabel.clipsToBounds = false
    authorLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    authorLabel.setContentHuggingPriority(.required, for: .vertical)
    authorLabel.isUserInteractionEnabled = true
    let authorTap = UITapGestureRecognizer(target: self, action: #selector(handleAuthorTap))
    authorLabel.addGestureRecognizer(authorTap)

    replyToChevron.contentMode = .scaleAspectFit
    replyToChevron.setContentHuggingPriority(.required, for: .horizontal)
    replyToChevron.setContentCompressionResistancePriority(.required, for: .vertical)
    replyToChevron.isHidden = true

    replyToLabel.numberOfLines = 1
    replyToLabel.lineBreakMode = .byTruncatingTail
    replyToLabel.clipsToBounds = false
    replyToLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    replyToLabel.isHidden = true

    authorRow.axis = .horizontal
    authorRow.alignment = .center
    authorRow.spacing = rowConfiguration.headerInlineSpacing
    authorRow.clipsToBounds = false
    authorRow.addArrangedSubview(authorLabel)
    authorRow.addArrangedSubview(replyToChevron)
    authorRow.addArrangedSubview(replyToLabel)
    let authorSpacer = UIView()
    authorSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    authorSpacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    authorRow.addArrangedSubview(authorSpacer)

    metaLabel.numberOfLines = 1
    metaLabel.textAlignment = .right
    metaLabel.setContentHuggingPriority(.required, for: .horizontal)
    metaLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    authorRow.addArrangedSubview(metaLabel)

    actionRail.setContentHuggingPriority(.required, for: .horizontal)
    actionRail.setContentCompressionResistancePriority(.required, for: .horizontal)

    metaStack.axis = .horizontal
    metaStack.alignment = .center
    metaStack.spacing = rowConfiguration.metaInlineSpacing
    // like · reply · more (leading) · spacer — keeps the rail left-aligned in the filled text column.
    metaStack.addArrangedSubview(actionRail)
    let metaSpacer = UIView()
    metaSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    metaStack.addArrangedSubview(metaSpacer)

    expandButton.contentHorizontalAlignment = .leading
    expandButton.addTarget(self, action: #selector(handleExpandTap), for: .touchUpInside)
    expandSpinner.translatesAutoresizingMaskIntoConstraints = false
    expandSpinner.hidesWhenStopped = true
    expandSpinner.setContentHuggingPriority(.required, for: .horizontal)
    expandSpinner.setContentCompressionResistancePriority(.required, for: .horizontal)
    // Slot is hidden until loading so Expand title stays left-aligned with the parent body.
    // Medium indicator is ~20pt; keep the slot matching to avoid Autolayout conflicts.
    expandSpinnerSlot.translatesAutoresizingMaskIntoConstraints = false
    expandSpinnerSlot.isHidden = true
    expandSpinnerSlot.addSubview(expandSpinner)
    NSLayoutConstraint.activate([
      expandSpinnerSlot.widthAnchor.constraint(equalToConstant: 20),
      expandSpinnerSlot.heightAnchor.constraint(equalToConstant: 20),
      expandSpinner.centerXAnchor.constraint(equalTo: expandSpinnerSlot.centerXAnchor),
      expandSpinner.centerYAnchor.constraint(equalTo: expandSpinnerSlot.centerYAnchor),
    ])

    expandRow.axis = .horizontal
    expandRow.alignment = .center
    expandRow.spacing = rowConfiguration.expandRowSpacing
    expandRow.isHidden = true
    expandRow.addArrangedSubview(expandSpinnerSlot)
    expandRow.addArrangedSubview(expandButton)
    let expandSpacer = UIView()
    expandSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    expandRow.addArrangedSubview(expandSpacer)

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = rowConfiguration.sectionSpacing
    textStack.addArrangedSubview(authorRow)
    textStack.addArrangedSubview(metaStack)
    textStack.addArrangedSubview(expandRow)

    contentRow.axis = .horizontal
    contentRow.alignment = .top
    contentRow.spacing = rowConfiguration.contentRowSpacing
    contentRow.translatesAutoresizingMaskIntoConstraints = false
    contentRow.addArrangedSubview(avatar)
    contentRow.addArrangedSubview(textStack)

    containerView.addSubview(contentRow)
    contentRowLeadingConstraint = contentRow.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
    let avatarWidth = avatar.widthAnchor.constraint(equalToConstant: rowConfiguration.avatarSize.diameter)
    avatarWidthConstraint = avatarWidth
    let avatarHeight = avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor)
    avatarHeight.priority = UILayoutPriority(999)
    let contentBottom = contentRow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    contentBottom.priority = UILayoutPriority(999)

    NSLayoutConstraint.activate([
      contentRowLeadingConstraint!,
      avatarWidth,
      avatarHeight,
      contentRow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      contentRow.topAnchor.constraint(equalTo: containerView.topAnchor),
      contentBottom,
    ])
  }

  public override func setupStyle() {
    super.setupStyle()
    applyRowConfiguration()
  }

  public override func resetCellContent() {
    super.resetCellContent()
    boundItem = nil
    onLike = nil
    onReply = nil
    onMore = nil
    onAvatar = nil
    onAuthor = nil
    onComment = nil
    onLongPress = nil
    onToggleExpand = nil
    onBodyExpansionChange = nil
    onRowTap = nil
    isExpandLoading = false
    avatar.resetForReuse()
    authorLabel.text = nil
    replyToLabel.text = nil
    replyToChevron.isHidden = true
    replyToLabel.isHidden = true
    metaLabel.text = nil
    actionRail.prepareForReuse()
    expandSpinner.stopAnimating()
    expandButton.isEnabled = true
    expandRow.isHidden = true
    expandSpinnerSlot.isHidden = true
    releaseBodyLabel()
    contentRowLeadingConstraint?.constant = 0
    accessibilityLabel = nil
  }

  public override func traitConfigurationDidChange(from previousTraitCollection: UITraitCollection?) {
    super.traitConfigurationDidChange(from: previousTraitCollection)
    applyRowConfiguration()
  }

  private func applyRowConfiguration() {
    containerInsets = rowConfiguration.table.contentInsets
    textStack.spacing = rowConfiguration.sectionSpacing
    authorRow.spacing = rowConfiguration.headerInlineSpacing
    metaStack.spacing = rowConfiguration.metaInlineSpacing
    contentRow.spacing = rowConfiguration.contentRowSpacing
    expandRow.spacing = rowConfiguration.expandRowSpacing
    authorLabel.font = rowConfiguration.resolvedAuthorFont()
    authorLabel.textColor = rowConfiguration.authorTextColor
    // Keep a full line-height so Dynamic Type ascenders are not clipped in the horizontal stack.
    // Priority below required so temporary UITableView encapsulated heights can compress first.
    let authorLineHeight = ceil(authorLabel.font.lineHeight)
    if authorHeightConstraint == nil {
      let constraint = authorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: authorLineHeight)
      constraint.priority = UILayoutPriority(750)
      constraint.isActive = true
      authorHeightConstraint = constraint
    } else {
      authorHeightConstraint?.constant = authorLineHeight
    }
    replyToLabel.font = rowConfiguration.resolvedReplyToFont()
    replyToLabel.textColor = rowConfiguration.authorTextColor
    replyToChevron.image = FKBusinessKitIcons.image(
      rowConfiguration.replyToChevronIcon,
      pointSize: rowConfiguration.chevronIconPointSize
    )
    replyToChevron.tintColor = rowConfiguration.metaTextColor
    metaLabel.font = rowConfiguration.resolvedTimestampFont()
    metaLabel.textColor = rowConfiguration.metaTextColor
    // Do not assign bodyLabel.textColor here — it flattens expandable action colors to body color.
    if let boundItem, !boundItem.body.isEmpty, let bodyLabel {
      applyBodyText(boundItem.body, to: bodyLabel)
    }
    expandButton.titleLabel?.font = rowConfiguration.resolvedExpandFont()
    expandButton.tintColor = rowConfiguration.expandTextColor
    avatarWidthConstraint?.constant = rowConfiguration.avatarSize.diameter
    if let boundItem {
      updateTimestampAppearance(for: boundItem)
    }
    syncActionRailVisibility()
    updateMetaStackVisibility()
    updateExpandButtonTitle()
  }

  @objc private func handleAvatarTap() {
    guard let boundItem else { return }
    onAvatar?(boundItem)
  }

  @objc private func handleAuthorTap() {
    guard let boundItem else { return }
    onAuthor?(boundItem)
  }

  @objc private func handleRowTap() {
    guard let boundItem else { return }
    onComment?(boundItem)
    if beginsReplyOnRowTap {
      onRowTap?(boundItem)
    }
  }

  @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began, let boundItem else { return }
    onLongPress?(boundItem)
  }

  @objc private func handleExpandTap() {
    guard !isExpandLoading, let boundItem else { return }
    onToggleExpand?(boundItem)
  }

  fileprivate func shouldRowTapGesture(
    _ gestureRecognizer: UIGestureRecognizer,
    receive touch: UITouch
  ) -> Bool {
    guard gestureRecognizer === rowTapGesture else { return false }
    guard let touched = touch.view else { return false }
    if touched is UIControl { return false }
    if touched.isDescendant(of: actionRail) { return false }
    if touched.isDescendant(of: expandRow) { return false }
    if touched === avatar || touched.isDescendant(of: avatar) { return false }
    if touched === authorLabel || touched === replyToLabel { return false }
    if let bodyLabel, touched === bodyLabel || touched.isDescendant(of: bodyLabel) {
      // Expand / collapse action must not also begin a reply.
      if FKCommentExpandableBodySupport.isTouchOnAction(
        touch,
        in: bodyLabel,
        expandAction: strings.expandBody,
        collapseAction: strings.collapseBody
      ) {
        return false
      }
    }
    return true
  }

  fileprivate func shouldRowTapGesture(
    _ gestureRecognizer: UIGestureRecognizer,
    requireFailureOf otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    // Do not wait on expandable-body gestures — that blocked reply/keyboard on body taps.
    _ = otherGestureRecognizer
    return false
  }

  fileprivate func shouldRowTapGesture(
    _ gestureRecognizer: UIGestureRecognizer,
    recognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    guard gestureRecognizer === rowTapGesture else { return false }
    guard let bodyLabel else { return false }
    let otherView = otherGestureRecognizer.view
    return otherView === bodyLabel || (otherView?.isDescendant(of: bodyLabel) ?? false)
  }

  private func updateExpandButtonTitle() {
    guard let boundItem else { return }
    let title: String
    let icon: FKBusinessKitIcon
    // Keep title stable while loading to avoid parent-row height jitter.
    if boundItem.areRepliesExpanded {
      title = strings.hideReplies
      icon = rowConfiguration.expandLessIcon
    } else if boundItem.replyCount > 0 {
      title = strings.viewRepliesText(count: boundItem.replyCount)
      icon = rowConfiguration.expandMoreIcon
    } else {
      title = strings.expandMore
      icon = rowConfiguration.expandMoreIcon
    }

    var config = UIButton.Configuration.plain()
    config.contentInsets = .zero
    config.imagePadding = 2
    config.imagePlacement = .trailing
    config.baseForegroundColor = rowConfiguration.expandTextColor
    config.title = title
    config.image = FKBusinessKitIcons.image(icon, pointSize: rowConfiguration.chevronIconPointSize)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [rowConfiguration] incoming in
      var outgoing = incoming
      outgoing.font = rowConfiguration.resolvedExpandFont()
      return outgoing
    }
    expandButton.configuration = config
  }

  private func applyExpandLoadingAppearance() {
    expandButton.isEnabled = !isExpandLoading
    // Do not rebuild the title while loading — text length changes jitter the parent row.
    if !isExpandLoading {
      updateExpandButtonTitle()
    }
    let wasHidden = expandSpinnerSlot.isHidden
    UIView.performWithoutAnimation {
      self.expandSpinnerSlot.isHidden = !self.isExpandLoading
      if self.isExpandLoading {
        self.expandSpinner.startAnimating()
      } else {
        self.expandSpinner.stopAnimating()
      }
    }
    if wasHidden != expandSpinnerSlot.isHidden {
      onBodyExpansionChange?()
    }
  }

  private func syncActionRailVisibility() {
    let moreVisible = showsMoreAction && (boundItem.map(hasAvailableMoreActions(for:)) ?? true)
    actionRail.showsLike = showsLikeAction
    actionRail.showsReply = showsReplyAction && rowConfiguration.showsMetaReplyButton
    actionRail.showsMore = moreVisible
    updateMetaStackVisibility()
  }

  private func updateTimestampAppearance(for item: FKCommentItem) {
    let text = item.timestampText
    let hasText = text?.isEmpty == false
    metaLabel.text = hasText ? text : nil
    metaLabel.isHidden = !(rowConfiguration.showsTimestamp && hasText)
  }

  private func updateMetaStackVisibility() {
    let stripeEnabled = rowConfiguration.showsMetaStripe
    metaStack.isHidden = !(stripeEnabled && actionRail.hasVisibleActions)
  }

  @discardableResult
  private func ensureBodyLabel() -> UILabel {
    if let bodyLabel { return bodyLabel }
    let label = UILabel()
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.textColor = rowConfiguration.bodyTextColor
    label.font = rowConfiguration.resolvedBodyFont()
    label.isUserInteractionEnabled = true
    bodyLabel = label
    if let metaIndex = textStack.arrangedSubviews.firstIndex(of: metaStack) {
      textStack.insertArrangedSubview(label, at: metaIndex)
    } else {
      textStack.insertArrangedSubview(label, at: 1)
    }
    return label
  }

  private func applyBodyText(_ text: String, to label: UILabel) {
    if rowConfiguration.usesExpandableBody, let maxLines = rowConfiguration.bodyMaxLines, maxLines > 0 {
      let configuration = FKCommentExpandableBodySupport.makeConfiguration(
        maxLines: maxLines,
        strings: strings,
        rowConfiguration: rowConfiguration
      )
      label.fk_setExpandableText(
        text,
        attributes: FKCommentExpandableBodySupport.bodyAttributes(rowConfiguration: rowConfiguration),
        configuration: configuration
      ) { [weak self] _ in
        self?.onBodyExpansionChange?()
      }
    } else {
      label.attributedText = nil
      label.text = text
      label.textColor = rowConfiguration.bodyTextColor
      label.font = rowConfiguration.resolvedBodyFont()
      label.numberOfLines = rowConfiguration.bodyMaxLines ?? 0
      label.lineBreakMode = .byTruncatingTail
    }
  }

  private func releaseBodyLabel() {
    guard let bodyLabel else { return }
    bodyLabel.text = nil
    bodyLabel.attributedText = nil
    textStack.removeArrangedSubview(bodyLabel)
    bodyLabel.removeFromSuperview()
    self.bodyLabel = nil
  }

  private func updateAccessibility(for item: FKCommentItem) {
    var components = [item.authorName]
    if let replyTo = item.replyTo {
      components.append(replyTo.displayName)
    }
    if !item.body.isEmpty {
      components.append(item.body)
    }
    if rowConfiguration.showsTimestamp, let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKCommentCompactRowCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
  }
}

@MainActor
private final class FKCommentCompactRowTapGestureDelegate: NSObject, UIGestureRecognizerDelegate {
  weak var cell: FKCommentCompactRowCell?

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    cell?.shouldRowTapGesture(gestureRecognizer, receive: touch) ?? false
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    cell?.shouldRowTapGesture(gestureRecognizer, requireFailureOf: otherGestureRecognizer) ?? false
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    cell?.shouldRowTapGesture(gestureRecognizer, recognizeSimultaneouslyWith: otherGestureRecognizer) ?? false
  }
}
