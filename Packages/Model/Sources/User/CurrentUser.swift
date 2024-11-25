@preconcurrency import ATProtoKit
import Network
import SwiftUI

@Observable
@MainActor
public class CurrentUser {
  public let client: BSkyClient

  public private(set) var profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?
  public private(set) var savedFeeds: AppBskyLexicon.Actor.SavedFeedsPreferencesDefinition?

  public init(client: BSkyClient) {
    self.client = client

    Task {
      await fetchProfile()
      await refreshCurrentUser()
    }
  }

  public func refreshCurrentUser() async {
    await fetchPreferences()
  }
  
  public func fetchProfile() async {
    do {
      self.profile = try await client.protoClient.getProfile(client.session.sessionDID)
    } catch {
      print(error)
    }
  }

  public func fetchPreferences() async {
    do {
      let preferences = try await client.protoClient.getPreferences().preferences
      for preference in preferences {
        switch preference {
        case .savedFeeds(let feeds):
          self.savedFeeds = feeds
        default:
          break
        }
      }
    } catch {
      print(error)
    }
  }
}
