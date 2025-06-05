import DesignSystem
import Network
import SwiftUI

struct ComposerToolbarView: View {
  @Binding var text: String
  @Binding var sendState: ComposerSendState

  var body: some View {
    HStack {
      HStack(alignment: .center, spacing: 16) {
        Button {
        } label: {
          Image(systemName: "photo")
            .foregroundStyle(.indigoPurple)
        }

        Button {
        } label: {
          Image(systemName: "film")
            .foregroundStyle(.indigoPurple)
        }

        Button {
        } label: {
          Image(systemName: "camera")
            .foregroundStyle(.indigoPurple)
        }

        Spacer()
        
        Button {
        } label: {
          Image(systemName: "at")
            .foregroundStyle(.indigoPurple)
        }
        
        Button {
        } label: {
          Image(systemName: "tag")
            .foregroundStyle(.indigoPurple)
        }
        .padding(.trailing, 16)

        Text("\(300 - text.count)")
          .foregroundStyle(text.count > 250 ? .redPurple : .indigoPurple)
          .font(.subheadline)
          .contentTransition(.numericText(value: Double(text.count)))
          .monospacedDigit()
          .lineLimit(1)
          .animation(.smooth, value: text.count)
      }
      .padding(16)
    }
    .background(Material.thinMaterial)
  }
}
