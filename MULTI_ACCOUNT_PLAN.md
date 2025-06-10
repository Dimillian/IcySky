# Multi-Account Implementation Plan for IcySky

## Overview
This document outlines the implementation plan for adding multi-account support to IcySky while maintaining the reactive architecture using AsyncStream.

## Architecture Design

### 1. Data Model

```swift
struct Account: Identifiable, Codable {
    let id: UUID
    let handle: String
    let did: String
    let displayName: String?
    let avatarUrl: String?
    let keychainIdentifier: UUID
    var isActive: Bool
}
```

### 2. Account Storage
- Each account gets its own Keychain namespace using a unique UUID
- Account metadata (handle, displayName, avatar) stored in UserDefaults
- Active account ID tracked separately

### 3. AccountManager Service

```swift
@Observable
public final class AccountManager {
    private(set) var accounts: [Account] = []
    private(set) var activeAccountId: UUID?
    
    func addAccount(_ account: Account)
    func removeAccount(_ accountId: UUID)
    func switchToAccount(_ accountId: UUID) async throws
    func loadAccounts()
    func saveAccounts()
}
```

## Integration with Existing Architecture

### Auth Class Updates

```swift
// Add to Auth class:
public private(set) var currentAccountId: UUID?

public func switchAccount(to accountId: UUID) async throws {
    // Load different keychain for the account
    let accountKeychain = AppleSecureKeychain(identifier: accountId)
    let configuration = ATProtocolConfiguration(keychainProtocol: accountKeychain)
    try await configuration.refreshSession()
    
    self.configuration = configuration
    self.currentAccountId = accountId
    
    // This triggers the EXISTING reactive flow!
    configurationContinuation.yield(configuration)
}
```

### Critical: View Identity Fix

In `IcySkyApp.swift`, add `.id()` modifier to force view recreation on account switch:

```swift
case .authenticated(let client, let currentUser):
  AppTabView()
    .environment(client)
    .environment(currentUser)
    .environment(auth)
    .environment(router)
    .environment(postDataControllerProvider)
    .id(auth.currentAccountId)  // ← CRITICAL: Forces complete view recreation
```

Without this `.id()` modifier:
- Views would retain @State from previous account
- Mixed data between accounts
- Stale cached content

## UI Components

### Account Switcher
- Quick switcher in profile tab or settings
- Shows avatar + handle for each account
- Current account highlighted
- "Add Account" option at bottom

### Account Management
- Long press or swipe actions for:
  - Remove account
  - Set as default
  - View account details

## Implementation Steps

1. **Create Account model and AccountManager service**
   - Define Account struct
   - Implement AccountManager with UserDefaults persistence
   - Add account CRUD operations

2. **Update Auth class**
   - Add currentAccountId property
   - Implement switchAccount method
   - Update init to work with AccountManager

3. **Update IcySkyApp**
   - Add .id(auth.currentAccountId) to authenticated case
   - Inject AccountManager into environment

4. **Create UI components**
   - Account switcher view
   - Account row component
   - Add account flow integration

5. **Testing**
   - Test account switching clears all state
   - Verify no data leaks between accounts
   - Test keychain isolation

## Benefits
- Clean account separation with full view recreation
- Leverages existing AsyncStream reactive pattern
- No modifications needed to app's core reactive flow
- Each account has isolated storage
- Quick switching without re-authentication

## Account Persistence & Restoration

### App Launch Flow

1. **AccountManager initialization** (in IcySkyApp)
```swift
@State var accountManager: AccountManager = .init()
@State var auth: Auth = .init(accountManager: accountManager)
```

2. **Account restoration in Auth.init()**
```swift
public init(accountManager: AccountManager) {
    self.accountManager = accountManager
    
    // Load saved accounts
    accountManager.loadAccounts()
    
    // Restore active account if exists
    if let activeAccountId = accountManager.activeAccountId {
        self.currentAccountId = activeAccountId
        self.ATProtoKeychain = AppleSecureKeychain(identifier: activeAccountId)
    } else if let firstAccount = accountManager.accounts.first {
        // Fallback to first account if no active account set
        self.currentAccountId = firstAccount.id
        self.ATProtoKeychain = AppleSecureKeychain(identifier: firstAccount.id)
    } else {
        // No accounts - will show auth screen
        self.ATProtoKeychain = AppleSecureKeychain(identifier: UUID())
    }
    
    // ... AsyncStream setup ...
}
```

3. **Auth.refresh() triggers on app becoming active**
```swift
// Existing code in IcySkyApp:
.task(id: scenePhase) {
    if scenePhase == .active {
        await auth.refresh()  // This now refreshes the active account
    }
}
```

### Account Storage Details

**UserDefaults Storage:**
```swift
// AccountManager stores:
{
    "accounts": [
        {
            "id": "uuid-1",
            "handle": "user1.bsky.social",
            "did": "did:plc:xxx",
            "displayName": "User One",
            "avatarUrl": "https://...",
            "keychainIdentifier": "uuid-1"
        },
        {
            "id": "uuid-2",
            "handle": "user2.bsky.social",
            "did": "did:plc:yyy",
            "displayName": "User Two",
            "avatarUrl": "https://...",
            "keychainIdentifier": "uuid-2"
        }
    ],
    "activeAccountId": "uuid-1"
}
```

**Keychain Storage (per account):**
- Each account's session stored under its UUID
- ATProtoKit handles the actual session persistence
- Complete isolation between accounts

### Edge Cases

1. **No active account on launch:**
   - Try first account in list
   - If no accounts, show auth screen

2. **Active account's session expired:**
   - Auth.refresh() fails
   - Emit nil configuration
   - App shows auth screen but preserves account list

3. **Account deleted externally:**
   - Validate accounts on launch
   - Remove invalid accounts from list
   - Select next available account

## Considerations
- View recreation means losing navigation state (intentional for clean separation)
- Need to handle account deletion gracefully
- Consider account-specific settings/preferences
- Handle edge cases (last account deletion, etc.)