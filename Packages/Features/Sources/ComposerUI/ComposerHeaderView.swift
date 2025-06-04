import DesignSystem
import SwiftUI

struct ComposerHeaderView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    HStack {
      Text("Composer")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundStyle(
          .primary.shadow(
            .inner(
              color: .shadowSecondary.opacity(0.5),
              radius: 1, x: -1, y: -1))
        )
        .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)

      Spacer()

      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .padding()
      }
      .buttonStyle(.circle)
      .foregroundColor(.primary)
    }
    .padding(.horizontal)
    .padding(.vertical, 16)
  }
}
