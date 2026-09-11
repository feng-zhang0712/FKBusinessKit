import UIKit

/// Bottom composer with optional reply-target banner, text input, and send control.
@MainActor
public final class FKCommentComposerView: UIView, UITextViewDelegate {
  /// Fired when the user taps Send with non-empty trimmed text.
  public var onSend: ((String) -> Void)?
  /// Fired when the user cancels the active reply target.
  public var onCancelReply: (() -> Void)?

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
    didSet { updateReplyBanner() }
  }

  /// When `true`, input is disabled and send shows a busy state.
  public var isSending: Bool = false {
    didSet { updateSendingState() }
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

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
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

  /// Clears the text field and sending flag without removing the reply target.
  public func resetText() {
    textView.text = ""
    isSending = false
    textViewDidChange(textView)
  }

  /// Clears text and reply target.
  public func resetAll() {
    replyTarget = nil
    resetText()
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
  }

  private func applyStrings() {
    placeholderLabel.text = strings.composerPlaceholder
    sendButton.setTitle(strings.send, for: .normal)
    cancelReplyButton.setTitle(strings.cancelReply, for: .normal)
    updateReplyBanner()
  }

  private func updateReplyBanner() {
    let shouldShow = configuration.showsReplyTargetBanner && replyTarget != nil
    bannerStack.isHidden = !shouldShow
    if let replyTarget, shouldShow {
      bannerLabel.text = strings.replyToText(displayName: replyTarget.displayName)
    } else {
      bannerLabel.text = nil
    }
    invalidateIntrinsicContentSize()
  }

  private func updateSendingState() {
    textView.isEditable = !isSending
    let canSend = !isSending && !text.isEmpty
    sendButton.isEnabled = canSend
    sendButton.isUserInteractionEnabled = canSend
    alpha = isSending ? 0.7 : 1.0
  }

  public func textViewDidChange(_ textView: UITextView) {
    if let max = configuration.maxCharacterCount, (textView.text?.count ?? 0) > max {
      textView.text = String(textView.text.prefix(max))
    }
    placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    let canSend = !isSending && !text.isEmpty
    sendButton.isEnabled = canSend
    sendButton.isUserInteractionEnabled = canSend
    updateTextViewHeight()
    invalidateIntrinsicContentSize()
    superview?.setNeedsLayout()
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
    replyTarget = nil
    onCancelReply?()
  }
}
