@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftUI

public struct PostsListView: View {
  @Environment(BSkyClient.self) var client
  @Environment(\.dismiss) var dismiss

  let feed: FeedItem

  @State var posts: [PostItem] = []
  @State var cursor: String?
  
  public init(feed: FeedItem) {
    self.feed = feed
  }

  public var body: some View {
    List {
      HeaderView(title: feed.displayName)
        .padding(.bottom)

      ForEach(posts) { post in
        PostRowView(post: post)
      }

      if cursor != nil {
        HStack {
          ProgressView()
        }
        .task {
          await loadFeed()
        }
      }
    }
    .navigationBarHidden(true)
    .listStyle(.plain)
    .task {
      await loadFeed()
    }
  }

  private func loadFeed() async {
    do {
      let feed = try await client.protoClient.getFeed(feed.uri, cursor: cursor)
      if cursor != nil {
        self.posts.append(contentsOf: feed.feed.map { $0.postItem })
      } else {
        self.posts = feed.feed.map { $0.postItem }
      }
      self.cursor = feed.cursor
    } catch {
      print(error)
    }
  }
}
