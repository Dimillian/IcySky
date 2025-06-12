# TextEditor with AttributedString Pattern Detection

## Overview

This document explains how IcySky implements real-time pattern detection (for @mentions, #hashtags, and URLs) in a TextEditor using iOS 26's AttributedString APIs. If you're trying to build similar functionality, this guide will help you understand the approach and avoid common pitfalls.

## The Challenge

When users type in a composer, we want to:
- Automatically detect and highlight @mentions (e.g., `@john` in purple)
- Automatically detect and highlight #hashtags (e.g., `#swift` in indigo)
- Automatically detect and underline URLs (e.g., `https://example.com` in blue)
- Do this in real-time as the user types, without any manual intervention

## The Architecture

### 1. Pattern Definition (`ComposerTextPattern.swift`)

First, we define what patterns we're looking for:

```swift
enum ComposerTextPattern: String, CaseIterable, Codable {
    case hashtag
    case mention
    case url
    
    var pattern: String {
        switch self {
        case .hashtag: return "#\\w+"
        case .mention: return "@[\\w.-]+"
        case .url: return "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        }
    }
    
    var color: Color {
        switch self {
        case .hashtag: return .purple
        case .mention: return .indigo
        case .url: return .blue
        }
    }
}
```

### 2. Custom Attribute (`TextPatternAttribute`)

We create a custom attribute to mark text with its pattern type:

```swift
struct TextPatternAttribute: CodableAttributedStringKey {
    typealias Value = ComposerTextPattern
    static let name = "IcySky.TextPatternAttribute"
    static let inheritedByAddedText: Bool = false
}
```

### 3. Text Processing (`ComposerTextProcessor.swift`)

Here's where the magic happens - and where we solve a critical problem:

```swift
func processText(_ text: inout AttributedString) {
    // CRITICAL: Create a fresh AttributedString from plain text
    let plainString = String(text.characters)
    var freshText = AttributedString(plainString)
    
    // Find all pattern matches
    for match in plainString.matches(of: combinedRegex) {
        // Apply pattern attribute to fresh text
        freshText[matchStart..<matchEnd][TextPatternAttribute.self] = patternType
    }
    
    // Replace entire text with fresh version
    text = freshText
}
```

### 4. Visual Styling (`ComposerFormattingDefinition.swift`)

We use iOS 26's `AttributedTextFormattingDefinition` to automatically apply colors:

```swift
struct PatternColorConstraint: AttributedTextValueConstraint {
    func constrain(_ container: inout Attributes) {
        if let pattern = container.textPattern {
            container.foregroundColor = pattern.color
        }
    }
}
```

## The Flow: What Happens When You Type

Let's trace through what happens when a user types `@john`:

### Step 1: User Types "@"
1. TextEditor triggers `onChange`
2. Processor creates fresh AttributedString: `"@"`
3. Regex matches `@` as a mention pattern
4. Applies mention attribute to entire string
5. Formatting constraint colors it indigo
6. User sees: @

### Step 2: User Types "j" (text is now "@j")
1. TextEditor triggers `onChange`
2. **Problem**: TextEditor has created fragmented runs: `[@][j]`
3. **Solution**: Processor creates fresh AttributedString: `"@j"`
4. Regex matches `@j` as a mention pattern
5. Applies mention attribute to entire string
6. User sees: @j (all indigo)

### Step 3: User Continues Typing
- Each keystroke repeats the process
- Fresh AttributedString prevents fragmentation
- Pattern stays highlighted consistently

### Step 4: User Types a Space
- Text is now `@john `
- Regex still matches `@john` (space isn't part of pattern)
- Only `@john` is highlighted, space remains normal

## Why We Need This Approach

### The Problem: TextEditor Fragmentation

When you type in a TextEditor with AttributedString:
1. TextEditor creates individual runs for each character as you type
2. If you try to modify attributes in-place, you get fragmented styling
3. This causes only the last character to be highlighted

Example of fragmentation:
```
Text: "@john"
Runs: [@] [j] [o] [h] [n]  // Each character is a separate run
```

### The Solution: Fresh AttributedString

By creating a fresh AttributedString:
1. We start with a clean slate each time
2. All characters in a pattern get the same attribute
3. No fragmentation issues

Result:
```
Text: "@john"
Runs: [@john]  // Single run with consistent attributes
```

## Key Implementation Details

### 1. Process on Every Change
```swift
.onChange(of: text) { oldValue, newValue in
    processor.processText(&text)
}
```

### 2. Apply Formatting Definition at Parent Level
```swift
NavigationStack {
    ComposerTextEditorView(...)
}
.attributedTextFormattingDefinition(ComposerFormattingDefinition())
```

### 3. Pattern Detection Logic
- Patterns include single characters (`@`, `#`) for immediate feedback
- Use regex alternation to check all patterns at once
- Match patterns using simple prefix checks

## Common Pitfalls to Avoid

1. **Don't try to modify attributes in-place** - TextEditor's fragmentation will cause issues
2. **Don't clear individual runs** - Create a fresh AttributedString instead
3. **Don't forget in-progress patterns** - Include `@` and `#` alone in your regex
4. **Don't apply visual styling directly** - Use AttributedTextFormattingDefinition constraints

## Performance Considerations

1. **Debouncing**: For large texts, consider debouncing the processing
2. **Incremental Updates**: For very large documents, process only changed portions
3. **Regex Optimization**: Compile regex once and reuse

## Comparison with Apple's Approach

Apple's recipe editor sample uses a different approach because:
- They mark text manually (user selects and marks as ingredient)
- Attributes persist naturally without automatic detection
- No need to rebuild AttributedString

Our use case requires automatic detection, which necessitates the fresh AttributedString approach.

## Summary

The key insight is that automatic pattern detection during typing requires working against TextEditor's natural behavior of creating fragmented runs. By creating a fresh AttributedString on each update, we ensure consistent highlighting of patterns as users type.

This approach enables a smooth, real-time highlighting experience for @mentions, #hashtags, and URLs in a SwiftUI TextEditor.