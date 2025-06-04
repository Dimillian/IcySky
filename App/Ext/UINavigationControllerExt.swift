import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self

    let gesture = UnidirectionalPanGestureRecognizer(direction: .horizontal)
    gesture.delegate = self
    if let targets = interactivePopGestureRecognizer?.value(forKey: "targets") {
      gesture.setValue(targets, forKey: "targets")
      view.addGestureRecognizer(gesture)
    }
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}

public class UnidirectionalPanGestureRecognizer: UIPanGestureRecognizer {
  public enum Direction {
    case horizontal
    case vertical
  }

  let direction: Direction

  public init(direction: Direction, target: Any? = nil, action: Selector? = nil) {
    self.direction = direction
    super.init(target: target, action: action)
  }

  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)

    if state == .began {
      let vel = velocity(in: view)
      switch direction {
      case .horizontal where abs(vel.y) > abs(vel.x):
        state = .cancelled
      case .vertical where abs(vel.x) > abs(vel.y):
        state = .cancelled
      default:
        break
      }
    }
  }
}
