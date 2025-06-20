import ATProtoKit
import Foundation

public struct Profile: Codable, Hashable, Sendable {
  public let did: String
  public let handle: String
  public let displayName: String?
  public let avatarImageURL: URL?

  public init(
    did: String,
    handle: String,
    displayName: String?,
    avatarImageURL: URL?
  ) {
    self.did = did
    self.handle = handle
    self.displayName = displayName
    self.avatarImageURL = avatarImageURL
  }
}

extension AppBskyLexicon.Actor.ProfileViewDetailedDefinition {
  public var profile: Profile {
    Profile(
      did: actorDID,
      handle: actorHandle,
      displayName: displayName,
      avatarImageURL: avatarImageURL
    )
  }
}
