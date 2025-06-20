import ATProtoKit
import DesignSystem
import Client
import SwiftUI

public struct ComposerView: View {
  @Environment(BSkyClient.self) private var client
  @Environment(\.dismiss) private var dismiss

  @State var presentationDetent: PresentationDetent = .large

  @State private var text = AttributedString()
  @State private var selection = AttributedTextSelection()

  @State private var sendState: ComposerSendState = .idle

  let mode: ComposerMode

  private var title: String {
    switch mode {
    case .newPost:
      return "New Post"
    case .reply(let post):
      return "Reply to \(post.author.displayName ?? post.author.handle)"
    }
  }

  public init(mode: ComposerMode) {
    self.mode = mode
  }

  public var body: some View {
    NavigationStack {
      ComposerTextEditorView(text: $text, selection: $selection, sendState: sendState)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ComposerToolbarView(
            text: $text,
            sendState: $sendState
          )
          ComposerHeaderView(
            sendState: $sendState,
            onSend: sendPost
          )
        }
    }
    .presentationDetents([.height(200), .large], selection: $presentationDetent)
    .presentationBackgroundInteraction(.enabled)
  }
}

// MARK: - Network
extension ComposerView {
  private func sendPost() async {
    sendState = .loading
    do {
      switch mode {
      case .newPost:
        _ = try await client.blueskyClient.createPostRecord(text: String(text.characters))
      case .reply:
        // TODO: Create replyRef
        _ = try await client.blueskyClient.createPostRecord(text: String(text.characters))
      }
      dismiss()
    } catch {
      sendState = .error("Failed to send post: \(error.localizedDescription)")
    }
  }
}
