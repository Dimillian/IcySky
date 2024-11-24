@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftUI

public struct PostsFeedView: View {
  @Environment(BSkyClient.self) var client
  @Environment(\.dismiss) var dismiss

  enum ViewState {
    case loading
    case loaded(posts: [PostItem], cursor: String?)
    case error(Error)
  }

  @State private var state: ViewState = .loading
  @State private var viewDidLoad = false

  let feed: FeedItem

  public init(feed: FeedItem) {
    self.feed = feed
  }

  public var body: some View {
    List {
      HeaderView(title: feed.displayName)
        .padding(.bottom)

      switch state {
      case .loading:
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
    .screenContainer()
    .task {
      guard !viewDidLoad else { return }
      viewDidLoad = true
      await loadFeed()
    }
    .refreshable {
      state = .loading
      await loadFeed()
    }
  }

  private var nextPageView: some View {
    HStack {
      ProgressView()
    }
    .task {
      await loadFeed()
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

// MARK: - Network
extension PostsFeedView {
  private func loadFeed() async {
    do {
      switch state {
      case .loading, .error:
        let feed = try await client.protoClient.getFeed(feed.uri, cursor: nil)
        state = .loaded(posts: processFeed(feed.feed), cursor: feed.cursor)
      case let .loaded(posts, cursor):
        let feed = try await client.protoClient.getFeed(feed.uri, cursor: cursor)
        state = .loaded(posts: posts + processFeed(feed.feed), cursor: feed.cursor)
      }
    } catch {
      state = .error(error)
    }
  }
}

// MARK: - Data
extension PostsFeedView {
  private func processFeed(_ feed: [AppBskyLexicon.Feed.FeedViewPostDefinition]) -> [PostItem] {
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
