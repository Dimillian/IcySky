import Network
import SwiftUI

struct ComposerToolbarView: ToolbarContent {
  @Binding var text: String
  @Binding var sendState: ComposerView.SendState
  let onSend: () async -> Void
  let onDismiss: () -> Void
  
  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .keyboard) {
      Spacer()
      Button("Send") {
        Task {
          await onSend()
        }
      }
      .disabled(text.isEmpty || sendState == .loading)
      
      Button("Done") {
        onDismiss()
      }
      .disabled(sendState == .loading)
    }
  }
}