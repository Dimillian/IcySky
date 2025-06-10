import ATProtoKit
import DesignSystem
import Network
import SwiftUI

public struct ComposerView: View {
  @Environment(BSkyClient.self) private var client
  @Environment(\.dismiss) private var dismiss

  @State private var text: String = ""
  @State private var sendState: ComposerSendState = .idle

  let mode: ComposerMode

  public init(mode: ComposerMode) {
    self.mode = mode
  }

  public var body: some View {
    VStack(spacing: 0) {
      ComposerHeaderView(mode: mode, sendState: $sendState, onSend: sendPost)

      Divider()

      ComposerTextEditorView(text: $text, sendState: sendState)
    }
    .toolbar {
      ComposerToolbarView(
        text: $text,
        sendState: $sendState
      )
    }
  }
}

// MARK: - Network
extension ComposerView {
  private func sendPost() async {
    sendState = .loading
    do {
      switch mode {
      case .newPost:
        _ = try await client.blueskyClient.createPostRecord(text: text)
      case .reply(let post):
        // TODO: Create replyRef
        _ = try await client.blueskyClient.createPostRecord(text: text)
      }
      dismiss()
    } catch {
      sendState = .error("Failed to send post: \(error.localizedDescription)")
    }
  }
}
