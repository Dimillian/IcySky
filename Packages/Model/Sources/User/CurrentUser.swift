@preconcurrency import ATProtoKit
import Network
import SwiftUI

@Observable
@MainActor
public class CurrentUser {
  public let client: BSkyClient

  public private(set) var profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?
  public private(set) var savedFeeds: [AppBskyLexicon.Actor.SavedFeed] = []

  public init(client: BSkyClient) async {
    self.client = client
    await fetch()
  }

  public func fetch() async {
    await fetchProfile()
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
        case .savedFeedsVersion2(let feeds):
          var feeds = feeds.items
          feeds.removeAll(where: { $0.value == "following" })
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
