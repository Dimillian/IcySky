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
      HStack(alignment: .center) {
        HeaderView(
          title: "New Post",
          type: .modal,
          fontSize: .largeTitle,
          alignment: .leading
        )
        Spacer()
        
        Button {
          Task { await sendPost() }
        } label: {
          Image(systemName: "paperplane")
            .font(.body)
            .padding(.all, 12)
            .foregroundStyle(.indigoPurple)
        }
        .buttonStyle(.circle)
        .foregroundColor(.primary)
        .padding(.trailing, 16)
      }
      Divider()
      
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
    .safeAreaInset(edge: .bottom, content: {
      ComposerToolbarView(
        text: $text,
        sendState: $sendState
      )
    })
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
