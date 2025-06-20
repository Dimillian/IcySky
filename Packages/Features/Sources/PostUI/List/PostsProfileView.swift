@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Client
import SwiftUI
import User

public struct PostsProfileView: View {
  @Environment(BSkyClient.self) var client

  let profile: Profile
  let filter: PostsProfileViewFilter

  public init(profile: Profile, filter: PostsProfileViewFilter) {
    self.profile = profile
    self.filter = filter
  }

  public var body: some View {
    PostListView(datasource: self)
  }
}

// MARK: - Datasource
extension PostsProfileView: @MainActor PostsListViewDatasource {
  var title: String {
    "Posts"
  }

  func loadPosts(with state: PostsListViewState) async -> PostsListViewState {
    do {
      switch state {
      case .uninitialized, .loading, .error:
        let feed = try await client.protoClient.getAuthorFeed(
          by: profile.did, postFilter: filter.atProtocolFilter)
        return .loaded(posts: PostListView.processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getAuthorFeed(
          by: profile.did, limit: nil, cursor: cursor, postFilter: filter.atProtocolFilter)
        return .loaded(posts: posts + PostListView.processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      return .error(error)
    }
  }
}
