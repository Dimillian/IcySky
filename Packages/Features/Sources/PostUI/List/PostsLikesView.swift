@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Client
import SwiftUI
import User

public struct PostsLikesView: View {
  @Environment(BSkyClient.self) var client

  let profile: Profile

  public init(profile: Profile) {
    self.profile = profile
  }

  public var body: some View {
    PostListView(datasource: self)
  }
}

// MARK: - Datasource
extension PostsLikesView: @MainActor PostsListViewDatasource {
  var title: String {
    "Likes"
  }

  func loadPosts(with state: PostsListViewState) async -> PostsListViewState {
    do {
      switch state {
      case .uninitialized, .loading, .error:
        let feed = try await client.protoClient.getActorLikes(by: profile.did)
        return .loaded(posts: PostListView.processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getActorLikes(
          by: profile.did, limit: nil, cursor: cursor)
        return .loaded(posts: posts + PostListView.processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      return .error(error)
    }
  }
}
