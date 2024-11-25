@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftData
import SwiftUI
import User

public struct PostsFeedView: View {
  @Environment(BSkyClient.self) var client
  @Environment(\.modelContext) var modelContext

  let uri: String
  let name: String
  let avatarImageURL: URL?

  public init(uri: String, name: String, avatarImageURL: URL?) {
    self.uri = uri
    self.name = name
    self.avatarImageURL = avatarImageURL
  }

  public var body: some View {
    PostListView(datasource: self)
      .onAppear {
        withAnimation {
          do {
            try modelContext.delete(
              model: RecentFeedItem.self,
              where: #Predicate { feed in
                feed.uri == uri
              })
            modelContext.insert(
              RecentFeedItem(
                uri: uri,
                name: name,
                avatarImageURL: avatarImageURL,
                lastViewedAt: Date()
              )
            )
            try modelContext.save()
          } catch {}
        }
      }
  }
}

// MARK: - Datasource
extension PostsFeedView: PostsListViewDatasource {
  var title: String {
    name
  }

  func loadPosts(with state: PostsListViewState) async -> PostsListViewState {
    do {
      switch state {
      case .uninitialized, .loading, .error:
        let feed = try await client.protoClient.getFeed(uri, cursor: nil)
        return .loaded(posts: PostListView.processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getFeed(uri, cursor: cursor)
        return .loaded(posts: posts + PostListView.processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      return .error(error)
    }
  }
}
