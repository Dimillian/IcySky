import SwiftUI

struct ComposerSendButtonView: View {
  let sendState: ComposerSendState
  let onSend: () async -> Void
  @State private var showError = false
  
  var body: some View {
    Button {
      switch sendState {
      case .error:
        showError = true
      case .idle:
        Task { await onSend() }
      case .loading:
        break
      }
    } label: {
      switch sendState {
      case .loading:
        ProgressView()
      case .error:
        Image(systemName: "exclamationmark.triangle")
          .foregroundStyle(.red)
      default:
        Image(systemName: "paperplane")
          .foregroundStyle(.indigoPurple)
      }
    }
    .alert("Error", isPresented: $showError) {
      Button("OK", role: .cancel) {
        showError = false
      }
    } message: {
      if case .error(let errorMessage) = sendState {
        Text(errorMessage)
      }
    }
  }
}
