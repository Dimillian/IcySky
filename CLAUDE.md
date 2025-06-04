# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IcySky is a SwiftUI-based Bluesky client for iOS and macOS built with a modular architecture using Swift Package Manager. The project targets iOS 18+ and macOS 15+ and uses the AT Protocol for Bluesky integration.

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