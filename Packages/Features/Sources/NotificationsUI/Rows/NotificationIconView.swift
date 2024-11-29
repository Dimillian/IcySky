import SwiftUI

struct NotificationIconView: View {
  let icon: String
  let color: Color

  var body: some View {
    Image(systemName: icon)
      .foregroundStyle(
        color
          .shadow(.drop(color: color.opacity(0.5), radius: 2))
      )
      .shadow(color: color, radius: 1)
      .background(
        Circle()
          .fill(.thickMaterial)
          .stroke(
            LinearGradient(
              colors: [color, .indigo],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1
          )
          .frame(width: 30, height: 30)
          .shadow(color: color.opacity(0.5), radius: 3)
      )
  }
}
