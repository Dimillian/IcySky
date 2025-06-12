import SwiftUI

struct ComposerTextEditorView: View {
  @Binding var text: AttributedString
  @Binding var selection: AttributedTextSelection

  let sendState: ComposerSendState
  @FocusState private var isFocused: Bool

  @State private var isPlaceholder = true
  @State private var processor = ComposerTextProcessor()

  var body: some View {
    ZStack(alignment: .topLeading) {
      TextEditor(text: $text, selection: $selection)
        .textInputFormattingControlVisibility(.hidden, for: .all)
        .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
        .frame(maxWidth: .infinity)
        .padding()
        .focused($isFocused)
        .textEditorStyle(.plain)
        .disabled(sendState == .loading)
        .attributedTextFormattingDefinition(ComposerFormattingDefinition())
        .onAppear {
          isFocused = true
        }
        .onChange(of: text, initial: true) { oldValue, newValue in
          isPlaceholder = newValue.characters.isEmpty

          processor.processText(&text)
        }

      if isPlaceholder {
        Text("What's on your mind?")
          .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
          .foregroundStyle(.secondary)
          .padding()
          .padding(.top, 6)
          .padding(.leading, 8)
      }
    }
  }
}
