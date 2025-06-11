import SwiftUI

struct ComposerTextEditorView: View {
  @Binding var text: AttributedString
  @Binding var selection: AttributedTextSelection

  let sendState: ComposerSendState
  @FocusState private var isFocused: Bool

  @State private var isPlaceholder = true

  var body: some View {
    ZStack(alignment: .topLeading) {
      TextEditor(text: $text, selection: $selection)
        .font(.system(size: UIFontMetrics.default.scaledValue(for: 20)))
        .frame(maxWidth: .infinity)
        .padding()
        .focused($isFocused)
        .textEditorStyle(.plain)
        .disabled(sendState == .loading)
        .onAppear {
          isFocused = true
        }
        .onChange(of: text) {
          isPlaceholder = text.characters.isEmpty
        }
        .onChange(of: selection) {
          processText()
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

  private func processText() {
    // Reset all foreground colors
    text.foregroundColor = nil

    // Find all @ and # characters in a single pass
    let patternIndices = text.characters.indices(where: { $0 == "@" || $0 == "#" })

    for range in patternIndices.ranges {
      let start = range.lowerBound
      let prefix = text.characters[start]

      // Check if prefix is at start or preceded by whitespace
      let isValidStart =
        start == text.startIndex
        || (start > text.startIndex
          && text.characters[text.characters.index(before: start)].isWhitespace)

      if isValidStart {
        // Find the end of the pattern
        var end = text.characters.index(after: start)
        while end < text.endIndex {
          let char = text.characters[end]
          if !char.isLetter && !char.isNumber && char != "_" {
            break
          }
          end = text.characters.index(after: end)
        }

        // Apply appropriate color based on prefix
        if end > start {
          let color: Color = prefix == "@" ? .indigo : .purple
          text[start..<end].foregroundColor = color
        }
      }
    }
  }
}
