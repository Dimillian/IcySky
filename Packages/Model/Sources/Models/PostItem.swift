import ATProtoKit
import Foundation

public struct PostItem: Hashable, Identifiable, Equatable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uri)
  }

  public var id: String { uri + uuid.uuidString }
  private let uuid = UUID()
  public let uri: String
  public let cid: String
  public let indexedAt: Date
  public let indexAtFormatted: String
  public let author: Profile
  public let content: String
  public let replyCount: Int
  public let repostCount: Int
  public let likeCount: Int
  public let likeURI: String?
  public let repostURI: String?
  public let embed: ATUnion.EmbedViewUnion?
  public let replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?

  public var hasReply: Bool = false

  public init(
    uri: String,
    cid: String,
    indexedAt: Date,
    author: Profile,
    content: String,
    replyCount: Int,
    repostCount: Int,
    likeCount: Int,
    likeURI: String?,
    repostURI: String?,
    embed: ATUnion.EmbedViewUnion?,
    replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?
  ) {
    self.uri = uri
    self.cid = cid
    self.indexedAt = indexedAt
    self.author = author
    self.content = content
    self.replyCount = replyCount
    self.repostCount = repostCount
    self.likeCount = likeCount
    self.likeURI = likeURI
    self.repostURI = repostURI
    self.embed = embed
    self.indexAtFormatted = indexedAt.relativeFormatted
    self.replyRef = replyRef
  }
}

extension AppBskyLexicon.Feed.FeedViewPostDefinition {
  public var postItem: PostItem {
    PostItem(
      uri: post.postItem.uri,
      cid: post.postItem.cid,
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
      likeURI: post.viewer?.likeURI,
      repostURI: post.viewer?.repostURI,
      embed: post.embed,
      replyRef: post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

extension AppBskyLexicon.Feed.PostViewDefinition {
  public var postItem: PostItem {
    PostItem(
      uri: uri,
      cid: cid,
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
      likeURI: viewer?.likeURI,
      repostURI: viewer?.repostURI,
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
      uri: uri,
      cid: cid,
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
      likeURI: nil,
      repostURI: nil,
      embed: embeds?.first,
      replyRef: value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

extension PostItem {
  @MainActor public static var placeholders: [PostItem] = Array(
    repeating: (), count: 10
  ).map {
    .init(
      uri: UUID().uuidString,
      cid: UUID().uuidString,
      indexedAt: Date(),
      author: .init(
        did: "placeholder",
        handle: "placeholder@bsky",
        displayName: "Placeholder Name",
        avatarImageURL: nil),
      content:
        "Some content some content some content\nSome content some content some content\nsomecontent",
      replyCount: 0,
      repostCount: 0,
      likeCount: 0,
      likeURI: nil,
      repostURI: nil,
      embed: nil,
      replyRef: nil)
  }

}
