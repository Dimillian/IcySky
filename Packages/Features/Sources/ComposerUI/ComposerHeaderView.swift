import DesignSystem
import Models
import SwiftUI

struct ComposerHeaderView: View {
  let mode: ComposerMode
  @Binding var sendState: ComposerSendState
  let onSend: () async -> Void

  private var title: String {
    switch mode {
    case .newPost:
      return "New Post"
    case .reply(let post):
      return "Reply to \(post.author.displayName ?? post.author.handle)"
    }
  }

  var body: some View {
    HStack(alignment: .center) {
      HeaderView(
        title: title,
        type: .modal,
        fontSize: .largeTitle,
        alignment: .leading
      )
      Spacer()

      ComposerSendButton(
        sendState: sendState,
        onSend: onSend
      )
    }
  }
}
