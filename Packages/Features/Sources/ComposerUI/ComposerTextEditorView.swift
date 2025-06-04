import SwiftUI

struct ComposerTextEditorView: View {
  @Binding var text: String
  let sendState: ComposerView.SendState
  @FocusState private var isFocused: Bool
  
  var body: some View {
    TextEditor(text: $text)
      .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
      .frame(height: 150)
      .frame(maxWidth: .infinity)
      .padding()
      .focused($isFocused)
      .textEditorStyle(.plain)
      .disabled(sendState == .loading)
      .onAppear {
        isFocused = true
      }
  }
}