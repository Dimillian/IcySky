import SwiftUI

public struct GlowingRoundedRectangle: ViewModifier {
  let cornerRadius: CGFloat

  public init(cornerRadius: CGFloat = 8) {
    self.cornerRadius = cornerRadius
  }

  public func body(content: Content) -> some View {
    content.overlay {
      RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(
          LinearGradient(
            colors: [.shadowPrimary.opacity(0.5), .indigo.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing),
          lineWidth: 1)
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    .shadow(color: .shadowPrimary.opacity(0.3), radius: 1)
  }
}

extension View {
  public func glowingRoundedRectangle(cornerRadius: CGFloat = 8) -> some View {
    modifier(GlowingRoundedRectangle(cornerRadius: cornerRadius))
  }
}
