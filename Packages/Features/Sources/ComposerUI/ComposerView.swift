import DesignSystem
import Network
import SwiftUI

public struct ComposerView: View {
  @Environment(BSkyClient.self) private var client
  @Environment(\.dismiss) private var dismiss

  @State private var text: String = ""
  @State private var sendState: ComposerSendState = .idle

  public init() {}

  public var body: some View {
    VStack(spacing: 0) {
      ComposerHeaderView(sendState: $sendState, onSend: sendPost)

      Divider()

      ComposerTextEditorView(text: $text, sendState: sendState)
    }
    .safeAreaInset(
      edge: .bottom,
      content: {
        ComposerToolbarView(
          text: $text,
          sendState: $sendState
        )
      })
  }
}

// MARK: - Network
extension ComposerView {
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
