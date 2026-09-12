import UIKit
import FKUIKit

/// Interactive comment row with avatar, body, reply-to chip, action bar, and expand affordance.
///
/// Built on ``FKBaseTableViewCell`` (not CellKit row chrome) so CommentKit owns spacing and collapse behavior.
@MainActor
public final class FKCommentRowCell: FKBaseTableViewCell, FKListTableCellConfigurable {
  public typealias Item = FKCommentItem

  /// Registry key for ListKit custom items.
  public nonisolated static var listKitCellTypeIdentifier: String { String(describing: Self.self) }

  /// Fallback estimated height before measurement.
  public static let preferredRowHeight: CGFloat = 96

  /// Row-specific configuration.
  public var rowConfiguration: FKCommentRowCellConfiguration = .init() {
    didSet { applyRowConfiguration() }
  }

  /// Shared strings for expand / accessibility.
  public var strings: FKCommentKitStrings = .init() {
    didSet { updateExpandButtonTitle() }
  }

  /// Feature visibility for the action bar.
  public var showsLikeAction: Bool = true {
    didSet { syncActionBarVisibility() }
  }

  public var showsReplyAction: Bool = true {
    didSet { syncActionBarVisibility() }
  }

  public var showsMoreAction: Bool = true {
    didSet { syncActionBarVisibility() }
  }

  public var showsCopyAction: Bool = true
  public var showsReportAction: Bool = true
  /// Mirrors ``FKCommentKitConfiguration/presentsDefaultMoreMenu`` for more-button visibility.
  public var presentsDefaultMoreMenu: Bool = true
  /// When `true`, More stays available even if built-in copy / report / delete are hidden.
  public var hasAdditionalMoreActions: Bool = false

  /// Minimum reply count required to show the expand control.
  public var expandAffordanceMinimumReplyCount: Int = 1

  /// When `true`, tapping the content area also begins a reply via ``onRowTap``.
  public var beginsReplyOnRowTap: Bool = true

  /// Fired when like is tapped.
  public var onLike: ((FKCommentItem) -> Void)?
  /// Fired when reply is tapped.
  public var onReply: ((FKCommentItem) -> Void)?
  /// Fired when more is tapped. Second argument is the more control (popover / menu anchor).
  public var onMore: ((FKCommentItem, UIView) -> Void)?
  /// Fired when the avatar is tapped.
  public var onAvatar: ((FKCommentItem) -> Void)?
  /// Fired when the author name is tapped.
  public var onAuthor: ((FKCommentItem) -> Void)?
  /// Fired when the comment body / content area is tapped.
  public var onComment: ((FKCommentItem) -> Void)?
  /// Fired when the row is long-pressed.
  public var onLongPress: ((FKCommentItem) -> Void)?
  /// Fired when expand / hide replies is tapped.
  public var onToggleExpand: ((FKCommentItem) -> Void)?
  /// Fired when expandable body changes height; host should refresh row height.
  public var onBodyExpansionChange: (() -> Void)?
  /// Fired when the content area is tapped and ``beginsReplyOnRowTap`` is `true`.
  public var onRowTap: ((FKCommentItem) -> Void)?

  private var threadLine: UIView?
  private var threadLineConstraints: [NSLayoutConstraint] = []
  private var threadLineTrailingConstraint: NSLayoutConstraint?
  private let avatar = FKAvatar()
  private var avatarWidthConstraint: NSLayoutConstraint?
  private let authorLabel = UILabel()
  private var timestampLabel: UILabel?
  private var replyToLabel: UILabel?
  private var bodyLabel: UILabel?
  private let actionBar = FKCommentActionBarView()
  private let expandRow = UIStackView()
  private let expandButton = UIButton(type: .system)
  private let expandSpinner = UIActivityIndicatorView(style: .medium)
  private let expandSpinnerSlot = UIView()
  private let headerStack = UIStackView()
  private let textStack = UIStackView()
  private let contentRow = UIStackView()
  private var contentRowLeadingConstraint: NSLayoutConstraint?
  private var currentIndent: CGFloat = 0
  private var boundItem: FKCommentItem?
  private var isExpandLoading = false
  private let rowTapGestureDelegate = FKCommentRowTapGestureDelegate()
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

  /// Binds a comment item to the row UI.
  public func configure(with item: FKCommentItem) {
    boundItem = item
    let cappedDepth = min(max(0, item.depth), rowConfiguration.maxDepth)
    let indent = CGFloat(cappedDepth) * rowConfiguration.indentWidth
    currentIndent = indent
    contentRowLeadingConstraint?.constant = indent
    if cappedDepth == 0 || !rowConfiguration.showsThreadLine {
      releaseThreadLine()
    } else {
      ensureThreadLine()
      threadLineTrailingConstraint?.constant = indent - 4
    }

    avatar.setDisplayName(item.authorName)
    avatar.setImageURL(item.avatarURL, placeholder: nil)
    FKCommentAvatarSupport.applyListRowChrome(
      to: avatar,
      size: rowConfiguration.avatarSize,
      isVerified: item.isVerified
    )
    avatar.isUserInteractionEnabled = true
    avatarWidthConstraint?.constant = rowConfiguration.avatarSize.diameter

    authorLabel.text = item.authorName

    if let timestamp = item.timestampText, !timestamp.isEmpty {
      ensureTimestampLabel().text = timestamp
    } else {
      releaseTimestampLabel()
    }

    if let replyTo = item.replyTo {
      ensureReplyToLabel().text = strings.replyToText(displayName: replyTo.displayName)
    } else {
      releaseReplyToLabel()
    }

    if item.body.isEmpty {
      releaseBodyLabel()
    } else {
      let label = ensureBodyLabel()
      applyBodyText(item.body, to: label)
    }

    let moreActionsAvailable = hasAvailableMoreActions(for: item)
    actionBar.strings = strings
    actionBar.showsLike = showsLikeAction
    actionBar.showsReply = showsReplyAction
    actionBar.showsMore = showsMoreAction && moreActionsAvailable
    actionBar.apply(isLiked: item.isLiked, likeCount: item.likeCount)
    actionBar.onLike = { [weak self] in
      guard let self, let boundItem = self.boundItem else { return }
      self.onLike?(boundItem)
    }
    actionBar.onReply = { [weak self] in
      guard let self, let boundItem = self.boundItem else { return }
      self.onReply?(boundItem)
    }
    actionBar.onMore = { [weak self] sourceView in
      guard let self, let boundItem = self.boundItem else { return }
      self.onMore?(boundItem, sourceView)
    }
    syncActionBarVisibility()

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
    showsLikeAction = kitConfiguration.showsLikeAction
    showsReplyAction = kitConfiguration.showsReplyAction
    showsMoreAction = kitConfiguration.showsMoreAction
    showsCopyAction = kitConfiguration.showsCopyAction
    showsReportAction = kitConfiguration.showsReportAction
    presentsDefaultMoreMenu = kitConfiguration.presentsDefaultMoreMenu
    hasAdditionalMoreActions = !kitConfiguration.additionalMoreActions.isEmpty
    expandAffordanceMinimumReplyCount = kitConfiguration.expandAffordanceMinimumReplyCount
    beginsReplyOnRowTap = kitConfiguration.beginsReplyOnRowTap
    actionBar.configuration = kitConfiguration.actionBar
    syncActionBarVisibility()
  }

  /// Applies like fields without rebuilding the whole row (preserves body expansion).
  public func applyLikeState(isLiked: Bool, likeCount: Int) {
    guard var boundItem else { return }
    boundItem.isLiked = isLiked
    boundItem.likeCount = max(0, likeCount)
    self.boundItem = boundItem
    actionBar.apply(isLiked: isLiked, likeCount: likeCount)
  }

  /// Shows a spinner and blocks expand taps while replies are loading.
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

    headerStack.axis = .horizontal
    headerStack.alignment = .firstBaseline
    headerStack.clipsToBounds = false
    headerStack.spacing = rowConfiguration.headerInlineSpacing
    headerStack.addArrangedSubview(authorLabel)

    expandButton.titleLabel?.font = rowConfiguration.resolvedExpandFont()
    expandButton.tintColor = rowConfiguration.expandTextColor
    expandButton.contentHorizontalAlignment = .leading
    expandButton.addTarget(self, action: #selector(handleExpandTap), for: .touchUpInside)
    expandButton.setContentHuggingPriority(.required, for: .horizontal)
    expandButton.setContentCompressionResistancePriority(.required, for: .horizontal)

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
    expandSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    expandRow.addArrangedSubview(expandSpacer)

    textStack.axis = .vertical
    textStack.alignment = .fill
    textStack.spacing = rowConfiguration.sectionSpacing
    textStack.addArrangedSubview(headerStack)
    textStack.addArrangedSubview(actionBar)
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
    actionBar.prepareForReuse()
    expandSpinner.stopAnimating()
    expandButton.isEnabled = true
    expandButton.accessibilityLabel = nil
    expandRow.isHidden = true
    expandSpinnerSlot.isHidden = true
    releaseTimestampLabel()
    releaseReplyToLabel()
    releaseBodyLabel()
    releaseThreadLine()
    currentIndent = 0
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
    headerStack.spacing = rowConfiguration.headerInlineSpacing
    contentRow.spacing = rowConfiguration.contentRowSpacing
    expandRow.spacing = rowConfiguration.expandRowSpacing
    authorLabel.font = rowConfiguration.resolvedAuthorFont()
    authorLabel.textColor = rowConfiguration.authorTextColor
    timestampLabel?.font = rowConfiguration.resolvedTimestampFont()
    timestampLabel?.textColor = rowConfiguration.metaTextColor
    replyToLabel?.font = rowConfiguration.resolvedReplyToFont()
    replyToLabel?.textColor = rowConfiguration.metaTextColor
    // Do not assign bodyLabel.textColor here — it flattens expandable action colors to body color.
    if let boundItem, !boundItem.body.isEmpty, let bodyLabel {
      applyBodyText(boundItem.body, to: bodyLabel)
    } else if !(rowConfiguration.usesExpandableBody && (rowConfiguration.bodyMaxLines ?? 0) > 0) {
      bodyLabel?.font = rowConfiguration.resolvedBodyFont()
      bodyLabel?.textColor = rowConfiguration.bodyTextColor
      bodyLabel?.numberOfLines = rowConfiguration.bodyMaxLines ?? 0
    }
    expandButton.titleLabel?.font = rowConfiguration.resolvedExpandFont()
    expandButton.tintColor = rowConfiguration.expandTextColor
    threadLine?.backgroundColor = rowConfiguration.threadLineColor
    avatarWidthConstraint?.constant = rowConfiguration.avatarSize.diameter
  }

  private func syncActionBarVisibility() {
    let moreVisible = showsMoreAction && (boundItem.map(hasAvailableMoreActions(for:)) ?? true)
    actionBar.showsLike = showsLikeAction
    actionBar.showsReply = showsReplyAction
    actionBar.showsMore = moreVisible
    // `FKCommentActionBarView` collapses its own height when no actions remain.
    actionBar.isHidden = !actionBar.hasVisibleActions
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

  fileprivate func shouldRowTapGesture(
    _ gestureRecognizer: UIGestureRecognizer,
    receive touch: UITouch
  ) -> Bool {
    guard gestureRecognizer === rowTapGesture else { return false }
    guard let touched = touch.view else { return false }
    if touched is UIControl { return false }
    if touched.isDescendant(of: actionBar) { return false }
    if touched.isDescendant(of: expandRow) { return false }
    if touched === avatar || touched.isDescendant(of: avatar) { return false }
    if touched === authorLabel { return false }
    if let bodyLabel, touched === bodyLabel || touched.isDescendant(of: bodyLabel) {
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

  @objc private func handleExpandTap() {
    guard !isExpandLoading, let boundItem else { return }
    onToggleExpand?(boundItem)
  }

  private func updateExpandButtonTitle() {
    guard let boundItem else { return }
    // Keep title stable while loading to avoid parent-row height jitter.
    if boundItem.areRepliesExpanded {
      expandButton.setTitle(strings.hideReplies, for: .normal)
    } else {
      expandButton.setTitle(strings.viewRepliesText(count: boundItem.replyCount), for: .normal)
    }
  }

  private func applyExpandLoadingAppearance() {
    expandButton.isEnabled = !isExpandLoading
    if !isExpandLoading {
      updateExpandButtonTitle()
      expandButton.accessibilityLabel = nil
    } else {
      expandButton.accessibilityLabel = strings.loadingReplies
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

  @discardableResult
  private func ensureThreadLine() -> UIView {
    if let threadLine { return threadLine }
    let line = UIView()
    line.backgroundColor = rowConfiguration.threadLineColor
    line.translatesAutoresizingMaskIntoConstraints = false
    containerView.insertSubview(line, belowSubview: contentRow)
    threadLine = line
    threadLineTrailingConstraint = line.trailingAnchor.constraint(
      equalTo: containerView.leadingAnchor,
      constant: currentIndent - 4
    )
    threadLineConstraints = [
      line.widthAnchor.constraint(equalToConstant: 2),
      line.topAnchor.constraint(equalTo: containerView.topAnchor),
      line.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      threadLineTrailingConstraint!,
    ]
    NSLayoutConstraint.activate(threadLineConstraints)
    return line
  }

  private func releaseThreadLine() {
    guard let threadLine else { return }
    NSLayoutConstraint.deactivate(threadLineConstraints)
    threadLineConstraints = []
    threadLineTrailingConstraint = nil
    threadLine.removeFromSuperview()
    self.threadLine = nil
  }

  @discardableResult
  private func ensureTimestampLabel() -> UILabel {
    if let timestampLabel { return timestampLabel }
    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .right
    label.textColor = rowConfiguration.metaTextColor
    label.font = rowConfiguration.resolvedTimestampFont()
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentCompressionResistancePriority(.required, for: .horizontal)
    timestampLabel = label
    headerStack.addArrangedSubview(label)
    return label
  }

  private func releaseTimestampLabel() {
    guard let timestampLabel else { return }
    timestampLabel.text = nil
    headerStack.removeArrangedSubview(timestampLabel)
    timestampLabel.removeFromSuperview()
    self.timestampLabel = nil
  }

  @discardableResult
  private func ensureReplyToLabel() -> UILabel {
    if let replyToLabel { return replyToLabel }
    let label = UILabel()
    label.numberOfLines = 1
    label.textColor = rowConfiguration.metaTextColor
    label.font = rowConfiguration.resolvedReplyToFont()
    replyToLabel = label
    insert(inTextStack: label, before: bodyLabel ?? actionBar)
    return label
  }

  private func releaseReplyToLabel() {
    guard let replyToLabel else { return }
    replyToLabel.text = nil
    textStack.removeArrangedSubview(replyToLabel)
    replyToLabel.removeFromSuperview()
    self.replyToLabel = nil
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
    insert(inTextStack: label, before: actionBar)
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

  private func insert(inTextStack view: UIView, before sibling: UIView) {
    if let index = textStack.arrangedSubviews.firstIndex(of: sibling) {
      textStack.insertArrangedSubview(view, at: index)
    } else {
      textStack.addArrangedSubview(view)
    }
  }

  private func updateAccessibility(for item: FKCommentItem) {
    var components = [item.authorName]
    if let timestamp = item.timestampText, !timestamp.isEmpty {
      components.append(timestamp)
    }
    if !item.body.isEmpty {
      components.append(item.body)
    }
    if item.likeCount > 0 {
      components.append("\(item.likeCount) likes")
    }
    if item.replyCount > 0 {
      components.append("\(item.replyCount) replies")
    }
    accessibilityLabel = components.joined(separator: ", ")
  }
}

extension FKCommentRowCell: FKListCellVisibilityHandling {
  public func cellWillDisplay() {}

  public func cellDidEndDisplaying() {
    avatar.resetForReuse()
  }
}

/// Isolates row-tap delegate callbacks so we never override ``UITableViewCell`` gesture hooks
/// (calling `super.gestureRecognizer(_:shouldReceive:)` crashes — unrecognized selector).
@MainActor
private final class FKCommentRowTapGestureDelegate: NSObject, UIGestureRecognizerDelegate {
  weak var cell: FKCommentRowCell?

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

