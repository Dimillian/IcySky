import SwiftUI

public struct ScreenContainerModifier: ViewModifier {
  public init() {}

  public func body(content: Content) -> some View {
    content
      .listStyle(.plain)
  }
}

extension View {
  public func screenContainer() -> some View {
    modifier(ScreenContainerModifier())
  }
}
