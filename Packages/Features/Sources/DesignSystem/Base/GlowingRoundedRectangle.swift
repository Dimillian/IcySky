import SwiftUI

public struct GlowingRoundedRectangle: ViewModifier {
  public init() {}

  public func body(content: Content) -> some View {
    content.overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(
          LinearGradient(
            colors: [.shadowPrimary.opacity(0.5), .indigo.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing),
          lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(color: .shadowPrimary.opacity(0.3), radius: 1)
  }
}

extension View {
  public func glowingRoundedRectangle() -> some View {
    modifier(GlowingRoundedRectangle())
  }
}
