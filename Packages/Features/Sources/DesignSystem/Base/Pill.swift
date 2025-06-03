import SwiftUI

public struct PillModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme

  let material: Material
  let isPressed: Bool
  let isCircle: Bool

  public init(material: Material, isPressed: Bool, isCircle: Bool = false) {
    self.material = material
    self.isPressed = isPressed
    self.isCircle = isCircle
  }

  public func body(content: Content) -> some View {
    content.background {
      if isCircle {
        background
          .clipShape(Circle())
      }
      if colorScheme == .dark {
        background
          .clipShape(Capsule())
      } else {
        background
      }
    }
  }

  @ViewBuilder
  private var background: some View {
    if colorScheme == .dark {
      Capsule()
        .foregroundStyle(material)
        .shadow(
          color: .shadowPrimary.opacity(isPressed ? 0 : 0.2),
          radius: isPressed ? 5 : 2, x: 1, y: 1
        )
        .overlay {
          ZStack {
            Capsule()
              .strokeBorder(.white.opacity(0.06), lineWidth: 1)
              .blendMode(.screen)
            
            Capsule()
              .strokeBorder(.white.opacity(0.04), lineWidth: 1)
              .blur(radius: 6)
              .blendMode(.screen)
          }
        }
    } else {
      Capsule()
        .foregroundStyle(
          material
            .shadow(
              .inner(color: .shadowSecondary, radius: isPressed ? 5 : 1, x: 0, y: 1)
            )
        )
        .shadow(
          color: .shadowPrimary.opacity(isPressed ? 0 : 0.2),
          radius: isPressed ? 5 : 2, x: 1, y: 1
        )
    }
  }
}

extension View {
  public func pillStyle(material: Material = .thin, isPressed: Bool = false)
    -> some View
  {
    modifier(PillModifier(material: material, isPressed: isPressed))
  }
}

extension View {
  public func circleStyle(material: Material = .thin, isPressed: Bool = false)
    -> some View
  {
    modifier(PillModifier(material: material, isPressed: isPressed, isCircle: true))
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  Button(
    action: {

    },
    label: {
      Text("Hello world")
        .padding()
    }
  )
  .buttonStyle(.pill)
  .padding()
  .environment(\.colorScheme, .light)
  .background(.white)

  Button(
    action: {

    },
    label: {
      Text("Hello world")
        .padding()
    }
  )
  .buttonStyle(.pill)
  .padding()
  .environment(\.colorScheme, .dark)
  .background(.black)
}
