import SwiftUI

public struct ScreenContainerModifier: ViewModifier {
  public init() {}
  

  public func body(content: Content) -> some View {
    content
      .listStyle(.plain)
      .navigationBarHidden(true)
      .safeAreaPadding(.init(top: 0, leading: 0, bottom: .tabBarHeight, trailing: 0))
  }
}

extension View {
  public func screenContainer() -> some View {
    modifier(ScreenContainerModifier())
  }
}
