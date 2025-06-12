import SwiftUI
import Foundation

/// Processes text to identify and mark patterns (hashtags, mentions, URLs)
@MainActor
struct ComposerTextProcessor {
  private let combinedRegex: Regex<AnyRegexOutput>
  
  init() {
    // Build regex from the patterns defined in ComposerTextPattern
    let patterns = ComposerTextPattern.allCases.map { $0.pattern }
    // Add patterns for in-progress typing
    let inProgressPatterns = ["#$", "@$"]  // Just # or @ being typed
    
    let combinedPattern = (patterns + inProgressPatterns).joined(separator: "|")
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
      guard let pattern = ComposerTextPattern.allCases.first(where: { $0.matches(matchedText) }) else {
        continue
      }
      
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