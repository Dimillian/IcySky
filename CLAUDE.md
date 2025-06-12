# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IcySky is a SwiftUI-based Bluesky client for iOS and macOS built with a modular architecture using Swift Package Manager. The project now requires **iOS 26 SDK** and targets iOS 26+ exclusively, leveraging the latest SwiftUI APIs. It uses the AT Protocol for Bluesky integration.

## Development Commands

### Building
```bash
# Open in Xcode
open IcySky.xcodeproj

# Build from command line
xcodebuild -project IcySky.xcodeproj -scheme IcySky build

# Build with Tuist (if using Tuist workflows)
tuist build
```

### Testing
```bash
# Run all tests
swift test --package-path Packages/Model
xcodebuild test -scheme FeaturesTests -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test targets
swift test --package-path Packages/Features --filter DesignSystemTests
swift test --package-path Packages/Features --filter FeedUITests
swift test --package-path Packages/Model --filter AuthTests

# Run features tests via Xcode test plan
xcodebuild test -scheme FeaturesTests -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Modular Package Structure
The codebase is split into two main Swift packages:

**Packages/Features/** - UI layer containing SwiftUI views and components:
- `AuthUI` - Authentication screens
- `FeedUI` - Feed list and navigation
- `PostUI` - Post display and interaction
- `ProfileUI` - User profile views
- `SettingsUI` - App settings
- `NotificationsUI` - Notification screens
- `ComposerUI` - Post composition
- `MediaUI` - Media viewing
- `DesignSystem` - Reusable UI components and styling

**Packages/Model/** - Core logic and data layer:
- `Network` - AT Protocol client wrapper (BSkyClient)
- `Models` - Data models for posts, feeds, profiles
- `Auth` - Authentication with keychain storage
- `User` - Current user state management
- `Destinations` - App navigation and routing

### Key Dependencies
- **ATProtoKit** - Bluesky/AT Protocol client
- **AppRouter** - Navigation and routing
- **KeychainSwift** - Secure credential storage
- **Nuke/NukeUI** - Image loading and caching
- **VariableBlur** - Advanced UI blur effects
- **ViewInspector** - SwiftUI testing utilities

### State Management
- Uses `@Observable` classes with SwiftUI's Observation framework
- `AppState` enum manages authentication and app lifecycle states
- Environment-based dependency injection for shared services
- Tab-based navigation with sheet-based modal presentation

### Authentication Flow
The `Auth` class uses AsyncStream for reactive authentication state management:
- **AsyncStream Pattern**: `configurationUpdates` emits configuration changes as they happen
- **Stateless Updates**: No timestamp tracking or manual state synchronization
- **Automatic Propagation**: Login, logout, and session refresh all emit through the same stream
- **App Integration**: The root app view listens to the stream and updates UI state accordingly

Example:
```swift
// In Auth class
public let configurationUpdates: AsyncStream<ATProtocolConfiguration?>

// In IcySkyApp
.task {
    for await configuration in auth.configurationUpdates {
        if let configuration {
            await refreshEnvWith(configuration: configuration)
        } else {
            appState = .unauthenticated
            router.presentedSheet = .auth
        }
    }
}

### Testing Approach
- Swift Testing framework (modern replacement for XCTest)
- ViewInspector for SwiftUI component testing
- Test targets organized by package modules
- `@MainActor` test classes for UI testing

## Development Notes

### Package Dependencies
Features package depends on Model package. When adding new functionality:
- UI components go in Features package
- Business logic and data models go in Model package
- Cross-package dependencies are explicitly declared in Package.swift

### Design System
All UI components should use the DesignSystem module for consistency:
- Custom colors defined in `Colors.swift` and `Colors.xcassets`
- Reusable components like `Pill`, `Container`, `GlowingRoundedRectangle`
- Custom button styles like `PillButtonStyle`

### Navigation
- Uses AppRouter for declarative navigation
- `RouterDestination` enum defines available destinations
- `SheetDestination` enum defines modal presentations
- Tab structure defined in `AppTab` enum

## SwiftUI Philosophy: No ViewModels

This project follows a strict **no-ViewModel** approach, embracing SwiftUI's native design patterns:

### Core Principles
- **Views as Pure State Expressions**: SwiftUI views are structs designed to be lightweight and disposable
- **Environment-Based Dependency Injection**: Use `@Environment` for shared services instead of manual ViewModel injection
- **Local State Management**: Use `@State` and enum-based view states directly within views
- **Composition Over Abstraction**: Split complex views into smaller components rather than extracting logic to ViewModels

### Patterns to Follow
- Define view states using enums (`.loading`, `.error`, `.loaded`)
- Use `@Environment` to access shared services like `BSkyClient`, `Auth`, `CurrentUser`
- Leverage `.task(id:)` and `.onChange()` modifiers for side effects and state reactions
- Keep business logic in service classes, not in ViewModels
- Test services and models independently; use ViewInspector for view testing when needed

### Example Structure
```swift
struct ExampleView: View {
    @Environment(BSkyClient.self) private var client
    @State private var viewState: ViewState = .loading
    
    enum ViewState {
        case loading
        case error(String)
        case loaded([Item])
    }
    
    var body: some View {
        // Pure state expression
    }
}
```

This approach results in cleaner, more maintainable code that works with SwiftUI's design rather than against it.

## Build Verification Rule

**IMPORTANT**: After making code changes, you MUST use the XcodeBuildMCP commands to build and verify the project compiles without errors:

1. First, discover available schemes:
   ```
   mcp__XcodeBuildMCP__list_schems_proj({ projectPath: "/Users/thomas/Documents/Dev/Open Source/IcySky/IcySky.xcodeproj" })
   ```

2. Build the IcySky scheme for iOS Simulator:
   ```
   mcp__XcodeBuildMCP__build_ios_sim_name_proj({ 
     projectPath: "/Users/thomas/Documents/Dev/Open Source/IcySky/IcySky.xcodeproj", 
     scheme: "IcySky", 
     simulatorName: "iPhone 16" 
   })
   ```
   
3. If there are build errors, fix them before considering the task complete.

This ensures code changes are syntactically correct and don't break the build.

## iOS 26 SDK Requirements

**IMPORTANT**: This project now requires iOS 26 SDK and targets iOS 26+ exclusively. We fully embrace and utilize the latest SwiftUI APIs introduced in June 2025.

### Available iOS 26 SwiftUI APIs

Feel free to use any of these new APIs throughout the codebase:

#### Liquid Glass Effects
- `glassEffect(_:in:isEnabled:)` - Apply Liquid Glass effects to views
- `buttonStyle(.glass)` - Apply Liquid Glass styling to buttons
- `ToolbarSpacer` - Create visual breaks in toolbars with Liquid Glass

#### Enhanced Scrolling
- `scrollEdgeEffectStyle(_:for:)` - Configure scroll edge effects
- `backgroundExtensionEffect()` - Duplicate, mirror, and blur views around edges

#### Tab Bar Enhancements
- `tabBarMinimizeBehavior(_:)` - Control tab bar minimization behavior
- Search role for tabs with search field replacing tab bar
- `TabViewBottomAccessoryPlacement` - Adjust accessory view content based on placement

#### Web Integration
- `WebView` and `WebPage` - Full control over browsing experience

#### Drag and Drop
- `draggable(_:_:)` - Drag multiple items
- `dragContainer(for:id:in:selection:_:)` - Container for draggable views

#### Animation
- `@Animatable` macro - SwiftUI synthesizes custom animatable data properties

#### UI Components
- `Slider` with automatic tick marks when using step parameter
- `windowResizeAnchor(_:)` - Set window anchor point for resizing

#### Text Enhancements
- `TextEditor` now supports `AttributedString`
- `AttributedTextSelection` - Handle text selection with attributed text
- `AttributedTextFormattingDefinition` - Define text styling in specific contexts
- `FindContext` - Create find navigator in text editing views

#### Accessibility
- `AssistiveAccess` - Support Assistive Access in iOS scenes

#### HDR Support
- `Color.ResolvedHDR` - RGBA values with HDR headroom information

#### UIKit Integration
- `UIHostingSceneDelegate` - Host and present SwiftUI scenes in UIKit
- `NSGestureRecognizerRepresentable` - Incorporate gesture recognizers from AppKit

#### Immersive Spaces (if applicable)
- `manipulable(coordinateSpace:operations:inertia:isEnabled:onChanged:)` - Hand gesture manipulation
- `SurfaceSnappingInfo` - Snap volumes and windows to surfaces
- `RemoteImmersiveSpace` - Render stereo content from Mac to Apple Vision Pro
- `SpatialContainer` - 3D layout container
- Depth-based modifiers: `aspectRatio3D(_:contentMode:)`, `rotation3DLayout(_:)`, `depthAlignment(_:)`

### Usage Guidelines
- Leverage these new APIs to enhance the user experience
- Replace legacy implementations with iOS 26 APIs where appropriate
- Take advantage of Liquid Glass effects for modern UI aesthetics
- Use the enhanced text and drag-and-drop capabilities for better interactions

## Text Processing with AttributedString (iOS 26)

### Overview
The ComposerUI module implements automatic pattern detection for @mentions and #hashtags using iOS 26's AttributedString APIs. This implementation demonstrates how to work with TextEditor's behavior when implementing real-time pattern detection.

### Architecture

**Location**: `Packages/Features/Sources/ComposerUI/TextProcessing/`

**Key Components**:
- `ComposerTextPattern.swift` - Defines patterns (hashtag, mention, URL) and their attributes
- `ComposerTextProcessor.swift` - Processes text to detect and mark patterns
- `ComposerFormattingDefinition.swift` - Applies visual styling using AttributedTextValueConstraint

### Implementation Details

#### Custom Attributes
```swift
struct TextPatternAttribute: CodableAttributedStringKey {
    typealias Value = ComposerTextPattern
    static let name = "IcySky.TextPatternAttribute"
    static let inheritedByAddedText: Bool = false
}
```

#### Text Processing Approach
Due to TextEditor creating fragmented character-by-character runs during typing, we must:
1. Create a fresh AttributedString from the plain text on each update
2. Apply all pattern attributes to the fresh string
3. Replace the entire text with the fresh version

```swift
func processText(_ text: inout AttributedString) {
    let plainString = String(text.characters)
    var freshText = AttributedString(plainString)
    
    // Find and apply patterns to fresh text
    // This avoids fragmented runs from TextEditor
}
```

#### Formatting Definition
The `ComposerFormattingDefinition` uses constraints to automatically apply visual styling:
- `PatternColorConstraint` - Applies colors based on text pattern
- `URLUnderlineConstraint` - Underlines URLs

Applied at the parent view level:
```swift
.attributedTextFormattingDefinition(ComposerFormattingDefinition())
```

### Key Learnings

1. **TextEditor Behavior**: During active typing, TextEditor creates character-by-character AttributedString runs, causing fragmentation

2. **Apple's Approach vs Ours**: 
   - Apple's sample (recipe editor) uses manual attribute application by user selection
   - Our approach requires automatic pattern detection during typing
   - This fundamental difference necessitates rebuilding the AttributedString

3. **Performance Optimization**: Process immediately for small changes (typing), debounce for large changes (paste)

4. **Pattern Matching**: Centralize regex patterns and matching logic in the enum to avoid duplication

### Important Notes

- The fresh AttributedString approach is necessary for automatic pattern detection
- AttributedTextFormattingDefinition constraints work elegantly for visual styling
- This pattern can be adapted for other real-time text processing needs (e.g., syntax highlighting)
- The implementation leverages iOS 26's enhanced TextEditor with AttributedString support