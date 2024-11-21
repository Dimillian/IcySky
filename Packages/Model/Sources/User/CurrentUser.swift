@preconcurrency import ATProtoKit
import Network
import SwiftUI

@Observable
@MainActor
public class CurrentUser {
  public let client: BSkyClient

  public var preferences: ATUnion.ActorPreferenceUnion?

  public init(client: BSkyClient) {
    self.client = client

    Task {
      await refreshCurrentUser()
    }
  }

  public func refreshCurrentUser() async {
    await fetchPreferences()
  }

  public func fetchPreferences() async {
    do {
      let preferences = try await client.protoClient.getPreferences().preference.preferences.first
      self.preferences = preferences
    } catch {
      print(error)
    }
  }
}
