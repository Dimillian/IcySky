import SwiftUI

/// The formatting definition for composer text
struct ComposerFormattingDefinition: AttributedTextFormattingDefinition {
  typealias Scope = AttributeScopes.ComposerAttributes
  
  var body: some AttributedTextFormattingDefinition<Scope> {
    PatternColorConstraint()
    URLUnderlineConstraint()
  }
}

/// Constraint that applies colors based on text patterns
struct PatternColorConstraint: AttributedTextValueConstraint {
  typealias Scope = AttributeScopes.ComposerAttributes
  typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
  
  func constrain(_ container: inout Attributes) {
    if let pattern = container.textPattern {
      container.foregroundColor = pattern.color
    } else {
      container.foregroundColor = nil
    }
  }
}

/// Constraint that underlines URLs
struct URLUnderlineConstraint: AttributedTextValueConstraint {
  typealias Scope = AttributeScopes.ComposerAttributes
  typealias AttributeKey = AttributeScopes.SwiftUIAttributes.UnderlineStyleAttribute
  
  func constrain(_ container: inout Attributes) {
    if container.textPattern == .url {
      container.underlineStyle = .single
    } else {
      container.underlineStyle = nil
    }
  }
}