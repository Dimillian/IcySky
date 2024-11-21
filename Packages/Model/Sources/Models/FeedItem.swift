import ATProtoKit
import Foundation

public struct FeedItem: Codable, Equatable, Identifiable, Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uri)
  }

  public var id: String { uri }
  public let uri: String
  public let displayName: String
  public let description: String?
  public let avatarImageURL: URL?
  public let creatorHandle: String
  public let likesCount: Int
  public let liked: Bool

  public init(
    uri: String,
    displayName: String,
    description: String?,
    avatarImageURL: URL?,
    creatorHandle: String,
    likesCount: Int,
    liked: Bool
  ) {
    self.uri = uri
    self.displayName = displayName
    self.description = description
    self.avatarImageURL = avatarImageURL
    self.creatorHandle = creatorHandle
    self.likesCount = likesCount
    self.liked = liked
  }
}

extension AppBskyLexicon.Feed.GeneratorViewDefinition {
  public var feedItem: FeedItem {
    FeedItem(
      uri: feedURI,
      displayName: displayName,
      description: description,
      avatarImageURL: avatarImageURL,
      creatorHandle: creator.actorHandle,
      likesCount: likeCount ?? 0,
      liked: viewer?.likeURI != nil
    )
  }
}
