@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Client
import SwiftData
import SwiftUI
import User

public struct PostsFeedView: View {
  @Environment(BSkyClient.self) var client
  @Environment(\.modelContext) var modelContext

  private let feedItem: FeedItem

  public init(feedItem: FeedItem) {
    self.feedItem = feedItem
  }

  public var body: some View {
    PostListView(datasource: self)
      .onAppear {
        updateRecentlyViewed()
      }
  }

  private func updateRecentlyViewed() {
    do {
      try modelContext.delete(
        model: RecentFeedItem.self,
        where: #Predicate { feed in
          feed.uri == feedItem.uri
        })
      modelContext.insert(
        RecentFeedItem(
          uri: feedItem.uri,
          name: feedItem.displayName,
          avatarImageURL: feedItem.avatarImageURL,
          lastViewedAt: Date()
        )
      )
      try modelContext.save()
    } catch {}
  }
}

// MARK: - Datasource
extension PostsFeedView: @MainActor PostsListViewDatasource {
  var title: String {
    feedItem.displayName
  }

  func loadPosts(with state: PostsListViewState) async -> PostsListViewState {
    do {
      switch state {
      case .uninitialized, .loading, .error:
        let feed = try await client.protoClient.getFeed(by: feedItem.uri, cursor: nil)
        return .loaded(posts: PostListView.processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getFeed(by: feedItem.uri, cursor: cursor)
        return .loaded(posts: posts + PostListView.processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      return .error(error)
    }
  }
}
