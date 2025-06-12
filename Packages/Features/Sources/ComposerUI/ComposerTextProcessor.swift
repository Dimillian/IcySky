import SwiftUI
import Foundation

/// Processes text to identify and mark patterns (hashtags, mentions, URLs)
@MainActor
struct ComposerTextProcessor {
  private let combinedRegex: Regex<AnyRegexOutput>
  
  init() {
    let patterns = [
      "#\\w+",          // Complete hashtag
      "@[\\w.-]+",      // Complete mention  
      "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)",  // URL
      "#$",             // Just # being typed
      "@$"              // Just @ being typed
    ]
    
    let combinedPattern = patterns.joined(separator: "|")
    self.combinedRegex = try! Regex(combinedPattern)
  }
  
  /// Process text to apply pattern attributes
  func processText(_ text: inout AttributedString) {
    // Create a completely fresh AttributedString from the plain text
    // This ensures we don't inherit any fragmented runs from TextEditor
    let plainString = String(text.characters)
    var freshText = AttributedString(plainString)
    
    // Find and apply all pattern matches
    for match in plainString.matches(of: combinedRegex) {
      let matchedText = String(plainString[match.range])
      
      // Skip empty matches
      guard !matchedText.isEmpty else { continue }
      
      // Determine which pattern type this is
      let patternType: ComposerTextPattern?
      if matchedText.hasPrefix("#") {
        patternType = .hashtag
      } else if matchedText.hasPrefix("@") {
        patternType = .mention
      } else if matchedText.lowercased().hasPrefix("http") {
        patternType = .url
      } else {
        patternType = nil
      }
      
      guard let pattern = patternType else { continue }
      
      // Convert String range to AttributedString indices
      guard let matchStart = AttributedString.Index(match.range.lowerBound, within: freshText),
            let matchEnd = AttributedString.Index(match.range.upperBound, within: freshText) else {
        continue
      }
      
      // Apply the pattern attribute to the fresh text
      freshText[matchStart..<matchEnd][TextPatternAttribute.self] = pattern
    }
    
    // Replace the entire text with our fresh version
    text = freshText
  }
}