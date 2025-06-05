import DesignSystem
import SwiftUI

struct ComposerHeaderView: View {
  @Binding var sendState: ComposerSendState

  let onSend: () async -> Void

  var body: some View {
    HStack(alignment: .center) {
      HeaderView(
        title: "New Post",
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
