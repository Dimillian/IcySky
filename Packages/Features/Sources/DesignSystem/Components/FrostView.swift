import SwiftUI
import VariableBlur

public enum FrostViewPosition {
  case top
  case bottom
}

public struct FrostView: View {
  let position: FrostViewPosition
  
  public init(position: FrostViewPosition) {
    self.position = position
  }
  
  public var body: some View {
    switch position {
    case .top:
      VariableBlurView(
        maxBlurRadius: 10,
        direction: .blurredTopClearBottom
      )
      .frame(height: 70)
      .ignoresSafeArea()
      .overlay(alignment: .top) {
        LinearGradient(
          colors: [.purple.opacity(0.07), .indigo.opacity(0.07), .clear],
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 70)
        .ignoresSafeArea()
      }
      
    case .bottom:
      VariableBlurView(
        maxBlurRadius: 10,
        direction: .blurredBottomClearTop
      )
      .frame(height: 100)
      .offset(y: 40)
      .ignoresSafeArea()
      .overlay(alignment: .bottom) {
        LinearGradient(
          colors: [.purple.opacity(0.07), .indigo.opacity(0.07), .clear],
          startPoint: .bottom,
          endPoint: .top
        )
        .frame(height: 100)
        .offset(y: 40)
        .ignoresSafeArea()
      }
    }
  }
}