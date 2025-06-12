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
        .textInputFormattingControlVisibility(.hidden, for: .all)
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
    text.foregroundColor = nil
    text.underlineStyle = nil

    let plainString = String(text.characters)

    let combinedPattern = ComposerTextPattern.allCases
      .map { $0.pattern }
      .joined(separator: "|")

    guard let regex = try? Regex(combinedPattern) else { return }

    for match in plainString.matches(of: regex) {
      guard let start = AttributedString.Index(match.range.lowerBound, within: text),
        let end = AttributedString.Index(match.range.upperBound, within: text)
      else {
        continue
      }

      let matchedText = String(plainString[match.range])

      guard let patternType = ComposerTextPattern.allCases.first(where: { $0.matches(matchedText) })
      else {
        continue
      }

      patternType.applyAttributes(to: &text, in: start..<end)
    }
  }
}
