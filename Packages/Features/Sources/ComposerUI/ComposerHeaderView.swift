import DesignSystem
import Models
import SwiftUI

struct ComposerHeaderView: ToolbarContent {
  @Environment(\.dismiss) var dismiss
  @Binding var sendState: ComposerSendState
  let onSend: () async -> Void

  var body: some ToolbarContent {    ToolbarItem(placement: .topBarTrailing) {
      ComposerSendButton(
        sendState: sendState,
        onSend: onSend
      )
    }
    ToolbarItem(placement: .topBarLeading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .foregroundStyle(.redPurple)
      }
    }
  }
}
