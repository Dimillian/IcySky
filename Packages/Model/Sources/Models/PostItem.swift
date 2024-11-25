import ATProtoKit
import Foundation

public struct PostItem: Hashable, Identifiable, Equatable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uri)
  }

  public var id: String { uri + uuid.uuidString }
  private let uuid = UUID()
  public let uri: String
  public let indexedAt: Date
  public let indexAtFormatted: String
  public let author: Author
  public let content: String
  public let replyCount: Int
  public let repostCount: Int
  public let likeCount: Int
  public let isLiked: Bool
  public let isReposted: Bool
  public let embed: ATUnion.EmbedViewUnion?
  public let replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?

  public var hasReply: Bool = false

  public struct Author: Codable, Hashable {
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

  public init(
    uri: String,
    indexedAt: Date,
    author: Author,
    content: String,
    replyCount: Int,
    repostCount: Int,
    likeCount: Int,
    isLiked: Bool,
    isReposted: Bool,
    embed: ATUnion.EmbedViewUnion?,
    replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?
  ) {
    self.uri = uri
    self.indexedAt = indexedAt
    self.author = author
    self.content = content
    self.replyCount = replyCount
    self.repostCount = repostCount
    self.likeCount = likeCount
    self.isLiked = isLiked
    self.isReposted = isReposted
    self.embed = embed
    self.indexAtFormatted = indexedAt.relativeFormatted
    self.replyRef = replyRef
  }
}

extension ATUnion.EmbedViewUnion: @retroactive Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    (try? lhs.toJsonData()) == (try? rhs.toJsonData())
  }
}

extension AppBskyLexicon.Feed.PostRecord.ReplyReference: @retroactive Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.parent.cidHash == rhs.parent.cidHash &&
    lhs.parent.recordURI == rhs.parent.recordURI &&
    lhs.root.cidHash == rhs.root.cidHash &&
    lhs.root.recordURI == rhs.root.recordURI
  }
}

extension AppBskyLexicon.Feed.FeedViewPostDefinition {
  public var postItem: PostItem {
    PostItem(
      uri: post.postURI,
      indexedAt: post.indexedAt,
      author: .init(
        did: post.author.actorDID,
        handle: post.author.actorHandle,
        displayName: post.author.displayName,
        avatarImageURL: post.author.avatarImageURL
      ),
      content: post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
      replyCount: post.replyCount ?? 0,
      repostCount: post.repostCount ?? 0,
      likeCount: post.likeCount ?? 0,
      isLiked: post.viewer?.likeURI != nil,
      isReposted: post.viewer?.repostURI != nil,
      embed: post.embed,
      replyRef: post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

extension AppBskyLexicon.Feed.PostViewDefinition {
  public var postItem: PostItem {
    PostItem(
      uri: postURI,
      indexedAt: indexedAt,
      author: .init(
        did: author.actorDID,
        handle: author.actorHandle,
        displayName: author.displayName,
        avatarImageURL: author.avatarImageURL
      ),
      content: record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
      replyCount: replyCount ?? 0,
      repostCount: repostCount ?? 0,
      likeCount: likeCount ?? 0,
      isLiked: viewer?.likeURI != nil,
      isReposted: viewer?.repostURI != nil,
      embed: embed,
      replyRef: record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

extension AppBskyLexicon.Feed.ThreadViewPostDefinition {

}

extension AppBskyLexicon.Embed.RecordDefinition.ViewRecord {
  public var postItem: PostItem {
    PostItem(
      uri: recordURI,
      indexedAt: indexedAt,
      author: .init(
        did: author.actorDID,
        handle: author.actorHandle,
        displayName: author.displayName,
        avatarImageURL: author.avatarImageURL
      ),
      content: value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
      replyCount: replyCount ?? 0,
      repostCount: repostCount ?? 0,
      likeCount: likeCount ?? 0,
      isLiked: false,
      isReposted: false,
      embed: embeds?.first,
      replyRef: value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

extension PostItem {
  @MainActor public static var placeholders: [PostItem] = Array(
    repeating: (), count: 10).map{
      .init(uri: UUID().uuidString,
                       indexedAt: Date(),
                       author: .init(did: "placeholder",
                                     handle: "placeholder@bsky",
                                     displayName: "Placeholder Name",
                                     avatarImageURL: nil),
                       content: "Some content some content some content\nSome content some content some content\nsomecontent",
                       replyCount: 0,
                       repostCount: 0,
                       likeCount: 0,
                       isLiked: false,
                       isReposted: false,
                       embed: nil,
                       replyRef: nil)
    }
  
}
