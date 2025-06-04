import DesignSystem
import Network
import SwiftUI

public struct ComposerView: View {
  @Environment(BSkyClient.self) private var client
  @Environment(\.dismiss) private var dismiss

  @State private var text: String = ""
  @State private var sendState: SendState = .idle

  enum SendState: Equatable {
    case idle
    case loading
    case error(String)
  }

  public init() {}

  public var body: some View {
    VStack(spacing: 0) {
      HeaderView(
        title: "Composer",
        type: .modal,
        fontSize: .largeTitle,
        alignment: .leading
      )
      
      VStack {
        if case .error(let errorMessage) = sendState {
          Text(errorMessage)
            .foregroundColor(.red)
            .padding()
        }

        ComposerTextEditorView(text: $text, sendState: sendState)

        if sendState == .loading {
          ProgressView()
            .padding()
        }

        Spacer()
      }
    }
    .toolbar {
      ComposerToolbarView(
        text: $text,
        sendState: $sendState,
        onSend: sendPost,
        onDismiss: { dismiss() }
      )
    }
  }
  
  private func sendPost() async {
    sendState = .loading
    do {
      _ = try await client.blueskyClient.createPostRecord(text: text)
      dismiss()
    } catch {
      sendState = .error("Failed to send post: \(error.localizedDescription)")
    }
  }
}

#Preview {
  NavigationStack {
    ComposerView()
  }
  .sheet(isPresented: .constant(true)) {
    ComposerView()
  }
}
