import ATProtoKit
import AppRouter
import DesignSystem
import Models
import Client
import SwiftUI

public struct PostDetailView: View {
  @Environment(BSkyClient.self) var client

  @State var post: PostItem
  @State var parents: [PostItem] = []
  @State var replies: [PostItem] = []

  @State private var scrollToId: String?

  public init(post: PostItem) {
    self.post = post
  }

  public var body: some View {
    ScrollViewReader { proxy in
      List {
        ForEach(parents) { parent in
          PostRowView(post: parent)
        }

        PostRowView(post: post)
          .environment(\.isFocused, true)
          .id("focusedPost")

        ForEach(replies) { reply in
          PostRowView(post: reply)
        }

        VStack {}
          .frame(height: 300)
          .listRowSeparator(.hidden)
      }
      .screenContainer()
      .task {
        await fetchThread()
        if !parents.isEmpty {
          scrollToId = "focusedPost"
        }
      }
      .onChange(of: scrollToId) {
        if let scrollToId {
          proxy.scrollTo(scrollToId, anchor: .top)
        }
      }
      .navigationTitle("Post")
    }
  }

  private func fetchThread() async {
    do {
      let thread = try await client.protoClient.getPostThread(from: post.uri)
      switch thread.thread {
      case .threadViewPost(let threadViewPost):
        self.post = threadViewPost.post.postItem
        processParents(from: threadViewPost)
        processReplies(from: threadViewPost)
      default:
        break
      }
    } catch {
      print(error)
    }
  }

  private func processParents(from threadViewPost: AppBskyLexicon.Feed.ThreadViewPostDefinition) {
    if let parent = threadViewPost.parent {
      switch parent {
      case .threadViewPost(let post):
        var item = post.post.postItem
        item.hasReply = true
        self.parents.append(item)
        processParents(from: post)
      default:
        break
      }
    }
  }

  private func processReplies(from threadViewPost: AppBskyLexicon.Feed.ThreadViewPostDefinition) {
    if let replies = threadViewPost.replies {
      for reply in replies {
        switch reply {
        case .threadViewPost(let reply):
          var postItem = reply.post.postItem
          if reply.replies?.isEmpty == false {
            postItem.hasReply = true
          }
          self.replies.append(postItem)
          processReplies(from: reply)
        default:
          break
        }
      }
    }
  }
}
