import SwiftUI
import Foundation

// Custom attribute keys for text patterns
struct TextPatternAttribute: CodableAttributedStringKey {
  typealias Value = ComposerTextPattern
  
  static let name = "IcySky.TextPatternAttribute"
  static let inheritedByAddedText: Bool = false
  static let invalidationConditions: Set<AttributedString.AttributeInvalidationCondition>? = [.textChanged]
}

extension AttributeScopes {
  struct ComposerAttributes: AttributeScope {
    let textPattern: TextPatternAttribute
    let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
    let underlineStyle: AttributeScopes.SwiftUIAttributes.UnderlineStyleAttribute
  }
}

extension AttributeDynamicLookup {
  subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<AttributeScopes.ComposerAttributes, T>
  ) -> T {
    self[T.self]
  }
}

enum ComposerTextPattern: String, CaseIterable, Codable {
  case hashtag
  case mention
  case url
  
  var pattern: String {
    switch self {
    case .hashtag:
      return "#\\w+"
    case .mention:
      return "@[\\w.-]+"
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
}
