import SwiftUI

public struct PillButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .pillStyle(isPressed: configuration.isPressed)
  }
}

extension ButtonStyle where Self == PillButtonStyle {
  public static var pill: Self {
    PillButtonStyle()
  }
}

public struct CircleButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .circleStyle(isPressed: configuration.isPressed)
  }
}

extension ButtonStyle where Self == CircleButtonStyle {
  public static var circle: Self {
    CircleButtonStyle()
  }
}
