import ATProtoKit

public enum PostsProfileViewFilter: String, Sendable, CaseIterable, Equatable, Hashable {
  case postsWithReplies
  case postsWithNoReplies
  case postsWithMedia
  case postAndAuthorThreads

  public var atProtocolFilter: AppBskyLexicon.Feed.GetAuthorFeed.Filter {
    switch self {
    case .postsWithReplies: return .postsWithReplies
    case .postsWithNoReplies: return .postsWithNoReplies
    case .postsWithMedia: return .postsWithMedia
    case .postAndAuthorThreads: return .postAndAuthorThreads
    }
  }
}
