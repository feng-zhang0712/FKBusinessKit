import FKBusinessKit
import UIKit

/// Standalone building-block demos for CommentKit views across presets.
final class FKCommentKitBuildingBlocksExampleViewController: FKBaseViewController {
  private let scrollView = UIScrollView()
  private let contentStack = UIStackView()
  private let actionBar = FKCommentActionBarView()
  private let compactRail = FKCommentCompactActionRailView()
  private let composer = FKCommentComposerView()
  private let compactComposer = FKCommentComposerView()
  private let statusLabel = UILabel()

  override func setupUI() {
    super.setupUI()
    title = "Action Bar & Composer"

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    view.addSubview(scrollView)

    contentStack.axis = .vertical
    contentStack.spacing = 16
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(contentStack)

    statusLabel.numberOfLines = 0
    statusLabel.font = .preferredFont(forTextStyle: .footnote)
    statusLabel.textColor = .secondaryLabel
    statusLabel.text = "Interact with the controls below."

    let actionTitle = makeSectionTitle("FKCommentActionBarView (standard)")
    actionBar.translatesAutoresizingMaskIntoConstraints = false
    actionBar.apply(isLiked: false, likeCount: 3)
    actionBar.onLike = { [weak self] in
      self?.toggleActionBarLike()
    }
    actionBar.onReply = { [weak self] in
      self?.statusLabel.text = "Action bar: Reply"
    }
    actionBar.onMore = { [weak self] _ in
      self?.statusLabel.text = "Action bar: More"
    }

    let railTitle = makeSectionTitle("FKCommentCompactActionRailView")
    compactRail.translatesAutoresizingMaskIntoConstraints = false
    compactRail.configuration = FKCommentCompactDefaults.makeActionBarConfiguration()
    compactRail.strings = FKCommentCompactDefaults.makeStrings()
    compactRail.showsLike = true
    compactRail.showsReply = true
    compactRail.showsMore = true
    compactRail.apply(isLiked: true, likeCount: 14_000, likeCountText: "14k")
    compactRail.onLike = { [weak self] in
      self?.statusLabel.text = "Compact rail: Like"
    }
    compactRail.onReply = { [weak self] in
      self?.statusLabel.text = "Compact rail: Reply"
    }
    compactRail.onMore = { [weak self] _ in
      self?.statusLabel.text = "Compact rail: More"
    }

    let composerTitle = makeSectionTitle("FKCommentComposerView (standard)")
    composer.translatesAutoresizingMaskIntoConstraints = false
    composer.replyTarget = FKCommentReplyTarget(id: "demo", displayName: "Alex Chen")
    composer.onSend = { [weak self] text in
      self?.statusLabel.text = "Composer sent: \(text)"
      self?.composer.resetText()
    }
    composer.onCancelReply = { [weak self] in
      self?.statusLabel.text = "Reply target cleared"
    }

    let shortComposerTitle = makeSectionTitle("FKCommentComposerView (compact)")
    compactComposer.translatesAutoresizingMaskIntoConstraints = false
    compactComposer.configuration = FKCommentCompactDefaults.makeComposerConfiguration()
    compactComposer.strings = FKCommentCompactDefaults.makeStrings()
    compactComposer.onSend = { [weak self] text in
      self?.statusLabel.text = "Compact composer sent: \(text)"
      self?.compactComposer.resetText()
    }
    let tip = UILabel()
    tip.numberOfLines = 0
    tip.font = .preferredFont(forTextStyle: .caption1)
    tip.textColor = .secondaryLabel
    tip.text = "Compact composer uses a capsule input field plus an optional Send button and reply banner."

    [
      actionTitle, actionBar,
      railTitle, compactRail,
      composerTitle, composer,
      shortComposerTitle, compactComposer,
      tip, statusLabel,
    ].forEach {
      contentStack.addArrangedSubview($0)
    }
  }

  override func setupConstraints() {
    super.setupConstraints()
    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

      contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
      contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
      contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
    ])
  }

  private var actionBarLiked = false
  private var actionBarCount = 3

  private func toggleActionBarLike() {
    if actionBarLiked {
      actionBarLiked = false
      actionBarCount = max(0, actionBarCount - 1)
    } else {
      actionBarLiked = true
      actionBarCount += 1
    }
    actionBar.apply(isLiked: actionBarLiked, likeCount: actionBarCount)
    statusLabel.text = actionBarLiked ? "Action bar: Liked (\(actionBarCount))" : "Action bar: Unliked (\(actionBarCount))"
  }

  private func makeSectionTitle(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: .headline)
    return label
  }
}
