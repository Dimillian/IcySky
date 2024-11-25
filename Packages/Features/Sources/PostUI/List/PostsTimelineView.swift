@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftUI
import User

public struct PostsTimelineView: View {
  @Environment(BSkyClient.self) var client

  public init() {}

  public var body: some View {
    PostListView(datasource: self)
  }
}

// MARK: - Datasource
extension PostsTimelineView: PostsListViewDatasource {
  var title: String {
    "Following"
  }

  func loadPosts(with state: PostsListViewState) async -> PostsListViewState {
    do {
      switch state {
      case .uninitialized, .loading, .error:
        let feed = try await client.protoClient.getTimeline()
        return .loaded(posts: PostListView.processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getTimeline(cursor: cursor)
        return .loaded(posts: posts + PostListView.processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      return .error(error)
    }
  }
}
