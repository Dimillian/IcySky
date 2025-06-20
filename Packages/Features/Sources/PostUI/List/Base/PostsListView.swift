@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Client
import SwiftUI
import User

public struct PostListView: View {
  let datasource: PostsListViewDatasource
  @State private var state: PostsListViewState = .uninitialized

  public var body: some View {
    List {
      switch state {
      case .loading, .uninitialized:
        placeholderView
      case let .loaded(posts, cursor):
        ForEach(posts) { post in
          PostRowView(post: post)
        }
        if cursor != nil {
          nextPageView
        }
      case let .error(error):
        Text(error.localizedDescription)
      }
    }
    .navigationTitle(datasource.title)
    .screenContainer()
    .task {
      if case .uninitialized = state {
        state = .loading
        state = await datasource.loadPosts(with: state)
      }
    }
    .refreshable {
      state = .loading
      state = await datasource.loadPosts(with: state)
    }
  }

  private var nextPageView: some View {
    HStack {
      ProgressView()
    }
    .task {
      state = await datasource.loadPosts(with: state)
    }
  }

  private var placeholderView: some View {
    ForEach(PostItem.placeholders) { post in
      PostRowView(post: post)
        .redacted(reason: .placeholder)
        .allowsHitTesting(false)
    }
  }
}

// MARK: - Data
extension PostListView {
  public static func processFeed(_ feed: [AppBskyLexicon.Feed.FeedViewPostDefinition]) -> [PostItem]
  {
    var postItems: [PostItem] = []

    func insert(post: AppBskyLexicon.Feed.PostViewDefinition, hasReply: Bool) {
      guard !postItems.contains(where: { $0.uri == post.postItem.uri }) else { return }
      var item = post.postItem
      item.hasReply = hasReply
      postItems.append(item)
    }

    for post in feed {
      if let reply = post.reply {
        switch reply.root {
        case let .postView(post):
          insert(post: post, hasReply: true)

          switch reply.parent {
          case let .postView(parent):
            insert(post: parent, hasReply: true)
          default:
            break
          }
        default:
          break
        }
      }
      insert(post: post.post, hasReply: false)

    }
    return postItems
  }
}
