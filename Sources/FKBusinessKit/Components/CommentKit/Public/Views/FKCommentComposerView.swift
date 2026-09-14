import UIKit

/// Bottom composer with optional reply-target banner, text input, and send control.
///
/// Supports per-target drafts, blur reset, and presentation hints for
/// ``FKCommentListViewController`` via ``FKCommentComposerConfiguration/presentationMode``.
@MainActor
public final class FKCommentComposerView: UIView, UITextViewDelegate {
  /// Fired when the user taps Send with non-empty trimmed text.
  public var onSend: ((String) -> Void)?
  /// Fired when the user cancels the active reply target.
  public var onCancelReply: (() -> Void)?
  /// Fired when editing, reply target, text, or draft state may affect host chrome visibility.
  public var onCompositionStateChange: (() -> Void)?

  /// Visual configuration.
  public var configuration: FKCommentComposerConfiguration = .init() {
    didSet { applyConfiguration() }
  }

  /// Copy tokens.
  public var strings: FKCommentKitStrings = .init() {
    didSet { applyStrings() }
  }

  /// Active reply target; banner visibility also depends on ``FKCommentComposerConfiguration/showsReplyTargetBanner``.
  public var replyTarget: FKCommentReplyTarget? {
    didSet {
      guard !isApplyingInternalMutation else {
        updateReplyBanner()
        return
      }
      if oldValue?.id != replyTarget?.id {
        saveDraft(for: oldValue)
        loadDraft(for: replyTarget)
      }
      updateReplyBanner()
      onCompositionStateChange?()
    }
  }

  /// When `true`, input is disabled and send shows a busy state.
  public var isSending: Bool = false {
    didSet { updateSendingState() }
  }

  /// Whether the text view is first responder.
  public private(set) var isEditingText: Bool = false

  /// Draft key used for the most recent blur / retarget (`""` = top-level).
  public private(set) var lastDraftKey: String = FKCommentComposerView.topLevelDraftKey

  /// Whether any preserved draft has non-empty trimmed text.
  public var hasPreservedDrafts: Bool {
    drafts.values.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }

  private let containerStack = UIStackView()
  private let bannerStack = UIStackView()
  private let bannerLabel = UILabel()
  private let cancelReplyButton = UIButton(type: .system)
  private let inputRow = UIStackView()
  private let capsuleContainer = UIView()
  private let textView = UITextView()
  private let placeholderLabel = UILabel()
  private let sendButton = UIButton(type: .system)
  private let topSeparator = UIView()
  private var textViewHeightConstraint: NSLayoutConstraint?
  private var capsuleConstraints: [NSLayoutConstraint] = []

  private struct Draft {
    var text: String
    var replyTarget: FKCommentReplyTarget?
  }

  private static let topLevelDraftKey = ""
  private var drafts: [String: Draft] = [:]
  private var isApplyingInternalMutation = false
  /// Prevents double chrome reset across willChangeFrame / willHide / didHide.
  private var didResetChromeForCurrentKeyboardDismiss = false
  private var isKeyboardVisible = false
  private var keyboardObservationTokens: [NSObjectProtocol] = []

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  public override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if newWindow == nil {
      removeKeyboardObservers()
      if configuration.clearsCompositionOnBlur, needsBlurChromeReset {
        resetBlurChrome(duration: nil, curveRaw: nil)
      }
    } else {
      installKeyboardObserversIfNeeded()
    }
  }

  /// Current trimmed text.
  public var text: String {
    get { textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    set {
      textView.text = newValue
      textViewDidChange(textView)
    }
  }

  /// Focuses the text view.
  public func focus() {
    textView.becomeFirstResponder()
  }

  /// Resigns first responder.
  public func blur() {
    textView.resignFirstResponder()
  }

  /// Starts or retargets composition, restoring any preserved draft for `target`.
  public func beginComposition(replyingTo target: FKCommentReplyTarget?) {
    didResetChromeForCurrentKeyboardDismiss = false
    if replyTarget?.id != target?.id {
      saveDraft(for: replyTarget)
      applyReplyTarget(target, loadDraft: true, bannerAnimated: true)
    } else if text.isEmpty {
      loadDraft(for: target)
    }
    // Notify host first so on-demand chrome can unhide before becoming first responder.
    onCompositionStateChange?()
    focus()
  }

  /// Clears the text field and sending flag without removing the reply target or drafts.
  public func resetText() {
    textView.text = ""
    isSending = false
    textViewDidChange(textView)
  }

  /// Clears text and reply target without discarding preserved drafts.
  public func resetAll() {
    didResetChromeForCurrentKeyboardDismiss = false
    applyReplyTarget(nil, loadDraft: false, bannerAnimated: true)
    resetText()
    onCompositionStateChange?()
  }

  /// Discards the draft for `key` (`""` = top-level) and clears UI when it matches the active target.
  public func discardDraft(forKey key: String) {
    drafts.removeValue(forKey: key)
    if draftKey(for: replyTarget) == key {
      resetText()
    }
    onCompositionStateChange?()
  }

  /// Discards every preserved draft.
  public func discardAllDrafts() {
    drafts.removeAll(keepingCapacity: false)
    onCompositionStateChange?()
  }

  /// Whether list hosts should keep the composer chrome visible for `presentationMode`.
  public func shouldDisplayChrome(showsComposer: Bool) -> Bool {
    guard showsComposer else { return false }
    switch configuration.presentationMode {
    case .always:
      return true
    case .onDemand:
      return isEditingText || replyTarget != nil
    case .automatic:
      return isEditingText || replyTarget != nil || !text.isEmpty || hasPreservedDrafts
    }
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false

    topSeparator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(topSeparator)

    containerStack.axis = .vertical
    containerStack.spacing = 6
    containerStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerStack)

    bannerStack.axis = .horizontal
    bannerStack.alignment = .center
    bannerStack.spacing = 8
    bannerStack.isHidden = true

    bannerLabel.numberOfLines = 1
    bannerLabel.textColor = configuration.bannerTextColor
    bannerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    cancelReplyButton.addTarget(self, action: #selector(handleCancelReply), for: .touchUpInside)
    cancelReplyButton.setContentHuggingPriority(.required, for: .horizontal)

    bannerStack.addArrangedSubview(bannerLabel)
    bannerStack.addArrangedSubview(cancelReplyButton)

    inputRow.axis = .horizontal
    inputRow.alignment = .center
    inputRow.spacing = 10

    capsuleContainer.translatesAutoresizingMaskIntoConstraints = false
    capsuleContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)

    textView.delegate = self
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    textView.translatesAutoresizingMaskIntoConstraints = false

    placeholderLabel.textColor = .placeholderText
    placeholderLabel.numberOfLines = 1
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    textView.addSubview(placeholderLabel)

    capsuleContainer.addSubview(textView)

    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    sendButton.setContentHuggingPriority(.required, for: .horizontal)
    sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    inputRow.addArrangedSubview(capsuleContainer)
    inputRow.addArrangedSubview(sendButton)

    containerStack.addArrangedSubview(bannerStack)
    containerStack.addArrangedSubview(inputRow)

    capsuleConstraints = [
      textView.topAnchor.constraint(equalTo: capsuleContainer.topAnchor),
      textView.leadingAnchor.constraint(equalTo: capsuleContainer.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: capsuleContainer.trailingAnchor),
      textView.bottomAnchor.constraint(equalTo: capsuleContainer.bottomAnchor),
    ]

    NSLayoutConstraint.activate([
      topSeparator.topAnchor.constraint(equalTo: topAnchor),
      topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
      topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
      topSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),

      containerStack.topAnchor.constraint(equalTo: topSeparator.bottomAnchor),
      containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),

      placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 13),
      placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -8),
      placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
    ] + capsuleConstraints)

    let height = textView.heightAnchor.constraint(equalToConstant: 36)
    height.priority = .required
    textViewHeightConstraint = height
    height.isActive = true

    applyConfiguration()
    applyStrings()
    updateSendingState()
    textViewDidChange(textView)
  }

  private func applyConfiguration() {
    backgroundColor = configuration.backgroundColor
    topSeparator.backgroundColor = configuration.separatorColor
    containerStack.spacing = configuration.stackSpacing
    bannerStack.spacing = configuration.bannerSpacing
    inputRow.spacing = configuration.inputRowSpacing
    layoutMargins = UIEdgeInsets(
      top: configuration.verticalInset,
      left: configuration.horizontalInset,
      bottom: configuration.verticalInset,
      right: configuration.horizontalInset
    )
    directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: configuration.verticalInset,
      leading: configuration.horizontalInset,
      bottom: configuration.verticalInset,
      trailing: configuration.horizontalInset
    )
    containerStack.isLayoutMarginsRelativeArrangement = true
    containerStack.layoutMargins = layoutMargins

    let textFont = configuration.resolvedTextViewFont()
    textView.font = textFont
    textView.textColor = configuration.textColor
    placeholderLabel.font = textFont
    placeholderLabel.textColor = configuration.placeholderColor
    sendButton.titleLabel?.font = configuration.resolvedSendButtonFont()
    sendButton.tintColor = configuration.sendButtonColor
    sendButton.setTitleColor(configuration.sendButtonColor, for: .normal)
    sendButton.setTitleColor(configuration.sendButtonColor.withAlphaComponent(0.35), for: .disabled)
    bannerLabel.font = configuration.resolvedBannerFont()
    bannerLabel.textColor = configuration.bannerTextColor
    cancelReplyButton.titleLabel?.font = configuration.resolvedBannerFont()
    cancelReplyButton.tintColor = configuration.cancelReplyButtonColor
    cancelReplyButton.setTitleColor(configuration.cancelReplyButtonColor, for: .normal)

    if configuration.usesCapsuleInput {
      capsuleContainer.backgroundColor = configuration.capsuleBackgroundColor
      capsuleContainer.layer.cornerRadius = configuration.capsuleCornerRadius
      capsuleContainer.layer.masksToBounds = true
      textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    } else {
      capsuleContainer.backgroundColor = .clear
      capsuleContainer.layer.cornerRadius = 0
      capsuleContainer.layer.masksToBounds = false
      textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    sendButton.isHidden = !configuration.showsSendButton
    updateReplyBanner()
    invalidateIntrinsicContentSize()
    onCompositionStateChange?()
  }

  private func applyStrings() {
    placeholderLabel.text = strings.composerPlaceholder
    sendButton.setTitle(strings.send, for: .normal)
    cancelReplyButton.setTitle(strings.cancelReply, for: .normal)
    updateReplyBanner()
  }

  private func updateReplyBanner(animated: Bool = false) {
    let shouldShow = configuration.showsReplyTargetBanner && replyTarget != nil
    let visibilityChanged = bannerStack.isHidden == shouldShow
    cancelReplyButton.isHidden = !configuration.showsCancelReplyButton
    if let replyTarget, shouldShow {
      bannerLabel.text = strings.replyToText(displayName: replyTarget.displayName)
    } else {
      bannerLabel.text = nil
    }

    let applyVisibility = {
      self.bannerStack.isHidden = !shouldShow
      self.invalidateIntrinsicContentSize()
      self.superview?.setNeedsLayout()
      self.superview?.layoutIfNeeded()
    }

    if animated, visibilityChanged, window != nil {
      UIView.animate(
        withDuration: 0.22,
        delay: 0,
        options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
      ) {
        applyVisibility()
      }
    } else {
      applyVisibility()
    }
  }

  private func updateSendingState() {
    textView.isEditable = !isSending
    let canSend = !isSending && !text.isEmpty
    sendButton.isEnabled = canSend
    sendButton.isUserInteractionEnabled = canSend
    alpha = isSending ? 0.7 : 1.0
  }

  public func textViewDidBeginEditing(_ textView: UITextView) {
    isEditingText = true
    didResetChromeForCurrentKeyboardDismiss = false
    if text.isEmpty,
      configuration.preservesDrafts,
      let draft = drafts[lastDraftKey],
      !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      applyReplyTarget(draft.replyTarget, loadDraft: true, bannerAnimated: true)
    }
    onCompositionStateChange?()
  }

  public func textViewDidEndEditing(_ textView: UITextView) {
    isEditingText = false
    guard configuration.clearsCompositionOnBlur else {
      onCompositionStateChange?()
      return
    }
    // Always stash draft here. Chrome reset is driven by keyboard will-hide so stripe
    // collapses in the same animation as the keyboard — not after it finishes.
    lastDraftKey = draftKey(for: replyTarget)
    saveDraft(for: replyTarget)
    if !isKeyboardVisible, needsBlurChromeReset {
      resetBlurChrome(duration: nil, curveRaw: nil)
    }
    onCompositionStateChange?()
  }

  public func textViewDidChange(_ textView: UITextView) {
    if let max = configuration.maxCharacterCount, (textView.text?.count ?? 0) > max {
      textView.text = String(textView.text.prefix(max))
    }
    let wasEmpty = placeholderLabel.isHidden == false
    placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    let canSend = !isSending && !text.isEmpty
    sendButton.isEnabled = canSend
    sendButton.isUserInteractionEnabled = canSend
    updateTextViewHeight()
    invalidateIntrinsicContentSize()
    superview?.setNeedsLayout()
    let isEmpty = text.isEmpty
    if wasEmpty != isEmpty {
      onCompositionStateChange?()
    }
  }

  private var needsBlurChromeReset: Bool {
    if replyTarget != nil { return true }
    if configuration.presentationMode == .automatic { return false }
    return !text.isEmpty
  }

  private var shouldKeepVisibleTextOnBlur: Bool {
    configuration.presentationMode == .automatic && !text.isEmpty
  }

  private func resetBlurChrome(duration: Double?, curveRaw: UInt?) {
    guard needsBlurChromeReset else { return }
    guard !didResetChromeForCurrentKeyboardDismiss else { return }
    didResetChromeForCurrentKeyboardDismiss = true

    lastDraftKey = draftKey(for: replyTarget)
    saveDraft(for: replyTarget)
    let keepVisibleText = shouldKeepVisibleTextOnBlur

    let apply = {
      self.applyReplyTarget(nil, loadDraft: false, bannerAnimated: false)
      if !keepVisibleText {
        self.textView.text = ""
        self.textViewDidChange(self.textView)
      } else {
        self.updateReplyBanner(animated: false)
      }
      self.invalidateIntrinsicContentSize()
      self.superview?.setNeedsLayout()
      self.superview?.layoutIfNeeded()
    }

    if let duration, duration > 0.01 {
      let resolvedCurve = curveRaw ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
      var options = UIView.AnimationOptions(rawValue: resolvedCurve << 16)
      options.insert(.beginFromCurrentState)
      options.insert(.allowUserInteraction)
      UIView.animate(withDuration: duration, delay: 0, options: options, animations: apply)
    } else {
      apply()
    }
    onCompositionStateChange?()
  }

  private func handleKeyboardFrameChange(
    endFrameInScreen: CGRect,
    duration: Double?,
    curveRaw: UInt?,
    isWillHide: Bool
  ) {
    let screenBounds = UIScreen.main.bounds
    let visibleHeight = screenBounds.intersection(endFrameInScreen).height
    let keyboardAppearsVisible = visibleHeight > 1
    let wasVisible = isKeyboardVisible
    isKeyboardVisible = keyboardAppearsVisible

    if keyboardAppearsVisible {
      // New keyboard presentation cycle.
      if !wasVisible {
        didResetChromeForCurrentKeyboardDismiss = false
      }
      return
    }

    // Keyboard is dismissing / hidden — collapse stripe in this same animation turn.
    guard configuration.clearsCompositionOnBlur else { return }
    guard isWillHide || wasVisible else { return }
    resetBlurChrome(duration: duration, curveRaw: curveRaw)
  }

  private func installKeyboardObserversIfNeeded() {
    guard keyboardObservationTokens.isEmpty else { return }
    let center = NotificationCenter.default
    keyboardObservationTokens.append(
      center.addObserver(
        forName: UIResponder.keyboardWillChangeFrameNotification,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        let endFrame =
          (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        MainActor.assumeIsolated {
          self?.handleKeyboardFrameChange(
            endFrameInScreen: endFrame,
            duration: duration,
            curveRaw: curveRaw,
            isWillHide: false
          )
        }
      }
    )
    keyboardObservationTokens.append(
      center.addObserver(
        forName: UIResponder.keyboardWillHideNotification,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        let endFrame =
          (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        MainActor.assumeIsolated {
          self?.handleKeyboardFrameChange(
            endFrameInScreen: endFrame,
            duration: duration,
            curveRaw: curveRaw,
            isWillHide: true
          )
        }
      }
    )
  }

  private func removeKeyboardObservers() {
    for token in keyboardObservationTokens {
      NotificationCenter.default.removeObserver(token)
    }
    keyboardObservationTokens.removeAll(keepingCapacity: false)
  }

  private func applyReplyTarget(
    _ target: FKCommentReplyTarget?,
    loadDraft: Bool,
    bannerAnimated: Bool = false
  ) {
    isApplyingInternalMutation = true
    replyTarget = target
    isApplyingInternalMutation = false
    if loadDraft {
      self.loadDraft(for: target)
    }
    updateReplyBanner(animated: bannerAnimated)
  }

  private func draftKey(for target: FKCommentReplyTarget?) -> String {
    target?.id ?? Self.topLevelDraftKey
  }

  private func saveDraft(for target: FKCommentReplyTarget?) {
    guard configuration.preservesDrafts else { return }
    let key = draftKey(for: target)
    let value = textView.text ?? ""
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      drafts.removeValue(forKey: key)
    } else {
      drafts[key] = Draft(text: value, replyTarget: target)
    }
    lastDraftKey = key
  }

  private func loadDraft(for target: FKCommentReplyTarget?) {
    guard configuration.preservesDrafts else { return }
    let key = draftKey(for: target)
    if let draft = drafts[key] {
      textView.text = draft.text
    } else {
      textView.text = ""
    }
    textViewDidChange(textView)
  }

  private func updateTextViewHeight() {
    let sendWidth: CGFloat = configuration.showsSendButton ? 56 : 0
    let width = textView.bounds.width > 0
      ? textView.bounds.width
      : max(0, (bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width)
        - configuration.horizontalInset * 2 - sendWidth - 20)
    let fitting = textView.sizeThatFits(
      CGSize(width: max(1, width), height: .greatestFiniteMagnitude)
    )
    let capped = min(max(36, fitting.height), configuration.maxContentHeight)
    textView.isScrollEnabled = fitting.height > configuration.maxContentHeight + 0.5
    textViewHeightConstraint?.constant = capped
  }

  public override var intrinsicContentSize: CGSize {
    let fitting = containerStack.systemLayoutSizeFitting(
      CGSize(width: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    let height = max(configuration.minimumHeight, fitting.height + 1.0 / UIScreen.main.scale)
    return CGSize(width: UIView.noIntrinsicMetric, height: height)
  }

  @objc private func handleSend() {
    let value = text
    guard !value.isEmpty, !isSending else { return }
    onSend?(value)
  }

  @objc private func handleCancelReply() {
    didResetChromeForCurrentKeyboardDismiss = false
    saveDraft(for: replyTarget)
    lastDraftKey = draftKey(for: replyTarget)
    applyReplyTarget(nil, loadDraft: false, bannerAnimated: true)
    resetText()
    onCancelReply?()
    onCompositionStateChange?()
  }
}
