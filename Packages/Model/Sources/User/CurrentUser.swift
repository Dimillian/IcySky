@preconcurrency import ATProtoKit
import Client
import SwiftUI

@Observable
public final class CurrentUser: @unchecked Sendable {
  public let client: BSkyClient

  public private(set) var profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?
  public private(set) var savedFeeds: [AppBskyLexicon.Actor.SavedFeed] = []

  public init(client: BSkyClient) async throws {
    self.client = client
    try await refresh()
  }

  public func refresh() async throws {
    async let profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = fetchProfile()
    async let savedFeeds = fetchPreferences()
    (self.profile, self.savedFeeds) = try await (profile, savedFeeds)
  }

  public func fetchProfile() async throws -> AppBskyLexicon.Actor.ProfileViewDetailedDefinition? {
    if let DID = try await client.protoClient.getUserSession()?.sessionDID {
      return try await client.protoClient.getProfile(for: DID)
    }
    return nil
  }

  public func fetchPreferences() async throws -> [AppBskyLexicon.Actor.SavedFeed] {
    let preferences = try await client.protoClient.getPreferences().preferences
    for preference in preferences {
      switch preference {
      case .savedFeedsVersion2(let feeds):
        var feeds = feeds.items
        feeds.removeAll(where: { $0.value == "following" })
        return feeds
      default:
        return []
      }
    }
    return []
  }
}
