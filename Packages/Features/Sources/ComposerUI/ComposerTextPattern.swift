import SwiftUI

enum ComposerTextPattern: CaseIterable {
  case hashtag
  case mention
  case url

  var pattern: String {
    switch self {
    case .hashtag:
      return "(#+[\\w0-9(_)]{0,})"
    case .mention:
      return "(@+[a-zA-Z0-9(_).-]{1,})"
    case .url:
      return "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
    }
  }

  var color: Color {
    switch self {
    case .hashtag:
      return .purple
    case .mention:
      return .indigo
    case .url:
      return .blue
    }
  }

  func matches(_ text: String) -> Bool {
    switch self {
    case .hashtag:
      return text.hasPrefix("#")
    case .mention:
      return text.hasPrefix("@")
    case .url:
      return text.lowercased().hasPrefix("http")
    }
  }

  func applyAttributes(
    to attributedString: inout AttributedString, in range: Range<AttributedString.Index>
  ) {
    attributedString[range].foregroundColor = color

    switch self {
    case .url:
      attributedString[range].underlineStyle = .single
    default:
      break
    }
  }
}
