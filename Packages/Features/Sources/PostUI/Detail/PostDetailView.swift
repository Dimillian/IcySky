import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftUI

public struct PostDetailView: View {
  @Environment(BSkyClient.self) var client

  @State var post: PostItem
  @State var replies: [PostItem] = []

  public init(post: PostItem) {
    self.post = post
  }

  public var body: some View {
    List {
      HeaderView(title: "Post")
        .padding(.bottom)

      PostRowView(post: post)
        .environment(\.isFocused, true)
      
      ForEach(replies) { reply in
        PostRowView(post: reply)
      }
      
    }
    .listStyle(.plain)
    .navigationBarHidden(true)
    .task {
      await fetchThread()
    }
  }

  private func fetchThread() async {
    do {
      let thread = try await client.protoClient.getPostThread(from: post.uri, shouldAuthenticate: true)
      switch thread.thread {
      case .threadViewPost(let threadViewPost):
        self.post = threadViewPost.post.postItem
        if let replies = threadViewPost.replies {
          for reply in replies {
            switch reply {
            case .threadViewPost(let reply):
              self.replies.append(reply.post.postItem)
            default:
              break
            }
          }
        }
      default:
        break
      }
    } catch {
      print(error)
    }
  }
}
