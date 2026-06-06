import UIKit

@MainActor
enum FKBaseScrollKeyboardFocus {

  /// Lays out `hostView`, then scrolls the current first responder inside `scrollView` into the visible bounds.
  static func scrollFirstResponderAfterKeyboardChange(
    in scrollView: UIScrollView,
    hostView: UIView,
    keyboardFrame: CGRect,
    duration: TimeInterval,
    curve: UIView.AnimationCurve
  ) {
    guard keyboardIntersectsVisibleBounds(keyboardFrame, in: hostView) else { return }
    let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
    UIView.animate(withDuration: duration, delay: 0, options: options) {
      hostView.layoutIfNeeded()
    } completion: { _ in
      scrollFirstResponderIntoView(in: scrollView)
    }
  }

  /// Scrolls the current first responder inside `scrollView` into the visible bounds.
  static func scrollFirstResponderIntoView(
    in scrollView: UIScrollView,
    extraPadding: CGFloat = 12,
    animated: Bool = true
  ) {
    guard let responder = firstResponder(in: scrollView) else { return }
    var target = responder.convert(responder.bounds, to: scrollView)
    target = target.insetBy(dx: 0, dy: -extraPadding)
    scrollView.scrollRectToVisible(target, animated: animated)
  }

  private static func keyboardIntersectsVisibleBounds(_ keyboardFrame: CGRect, in hostView: UIView) -> Bool {
    guard keyboardFrame.height > 0 else { return false }
    if let window = hostView.window {
      let keyboardInHost = hostView.convert(keyboardFrame, from: window.screen.coordinateSpace)
      return keyboardInHost.intersection(hostView.bounds).height > 0
    }
    let screenBounds = UIScreen.main.bounds
    return keyboardFrame.intersection(screenBounds).height > 0
  }

  private static func firstResponder(in view: UIView) -> UIView? {
    if view.isFirstResponder { return view }
    for subview in view.subviews {
      if let found = firstResponder(in: subview) { return found }
    }
    return nil
  }
}
