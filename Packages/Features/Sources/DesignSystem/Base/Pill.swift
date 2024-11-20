import SwiftUI

public struct PillModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  let material: Material
  let isPressed: Bool

  public init(material: Material, isPressed: Bool) {
    self.material = material
    self.isPressed = isPressed
  }

  public func body(content: Content) -> some View {
    content.background {
      if colorScheme == .dark {
        background
          .clipShape(Capsule())
      } else {
        background
      }
    }
  }
  
  private var background: some View {
    Capsule()
      .foregroundStyle(
        material
          .shadow(.inner(color: .shadowSecondary, radius: isPressed ? 5 : 1, x: 0, y: 1))
      )
      .shadow(color: .shadowPrimary.opacity(isPressed ? 0 : 0.2), radius: isPressed ? 5 : 2, x: 1, y: 1)
  }
}

extension View {
  public func pillStyle(material: Material = .ultraThickMaterial, isPressed: Bool = false) -> some View {
    modifier(PillModifier(material: material, isPressed: isPressed))
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  Button(action: {
  
  }, label: {
    Text("Hello world")
      .padding()
  })
  .buttonStyle(.pill)
  .padding()
  .environment(\.colorScheme, .light)
  .background(.white)
  
  Button(action: {
  
  }, label: {
    Text("Hello world")
      .padding()
  })
  .buttonStyle(.pill)
  .padding()
  .environment(\.colorScheme, .dark)
  .background(.black)
}
