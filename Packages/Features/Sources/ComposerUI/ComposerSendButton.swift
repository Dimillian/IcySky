import SwiftUI

struct ComposerSendButton: View {
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
          .padding()
      case .error:
        Image(systemName: "exclamationmark.triangle")
          .font(.body)
          .padding(.all, 12)
          .foregroundStyle(.red)
      default:
        Image(systemName: "paperplane")
          .font(.body)
          .padding(.all, 12)
          .foregroundStyle(.indigoPurple)
      }
    }
    .buttonStyle(.glass)
    .foregroundColor(.primary)
    .padding(.trailing, 16)
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
