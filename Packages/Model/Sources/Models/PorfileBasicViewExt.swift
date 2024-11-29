import ATProtoKit

extension AppBskyLexicon.Actor.ProfileViewBasicDefinition {
  public var displayNameOrHandle: String {
    if let displayName = displayName, !displayName.isEmpty {
      return displayName
    }
    return actorHandle
  }
}
