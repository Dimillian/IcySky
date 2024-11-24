import DesignSystem
import Models
import Network
import Router
import SwiftUI

extension EnvironmentValues {
  @Entry public var isQuote: Bool = false
  @Entry public var isFocused: Bool = false
}

struct PostRowView: View {
  @Environment(\.isQuote) var isQuote
  @Environment(Router.self) var router

  let post: PostItem

  var body: some View {
    if isQuote {
      mainView
        .listRowSeparator(.hidden)
    } else {
      HStack(alignment: .top, spacing: 8) {
        VStack(spacing: 0) {
          avatarView
          threadLineView
        }
        mainView
          .padding(.bottom, 18)
      }
      .listRowSeparator(.hidden)
      .listRowInsets(.init(top: 0, leading: 18, bottom: 0, trailing: 18))
    }
  }

  private var mainView: some View {
    VStack(alignment: .leading, spacing: 8) {
      authorView
      bodyView
      PostRowEmbedView(post: post)
      if !isQuote {
        actionsView
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      router.navigateTo(.post(post))
    }
  }

  private var avatarView: some View {
    AsyncImage(url: post.author.avatarImageURL) { phase in
      switch phase {
      case .success(let image):
        image
          .resizable()
          .scaledToFit()
          .frame(width: isQuote ? 16 : 32, height: isQuote ? 16 : 32)
          .clipShape(Circle())
      default:
        Circle()
          .fill(.gray.opacity(0.2))
          .frame(width: isQuote ? 16 : 32, height: isQuote ? 16 : 32)
      }
    }
    .overlay {
      Circle()
        .stroke(
          LinearGradient(
            colors: post.hasReply ? [.purple, .indigo] : [.shadowPrimary.opacity(0.5), .indigo.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing),
          lineWidth: 1)
    }
    .shadow(color: .shadowPrimary.opacity(0.3), radius: 2)
  }

  private var authorView: some View {
    HStack(alignment: .center) {
      if isQuote {
        avatarView
      }
      Text(post.author.displayName ?? "")
        .font(.callout)
        .foregroundStyle(.primary)
        .fontWeight(.semibold)
        + Text("  @\(post.author.handle)")
        .font(.footnote)
        .foregroundStyle(.tertiary)
      Spacer()
      Text(post.indexAtFormatted)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .lineLimit(1)
  }

  @ViewBuilder
  private var bodyView: some View {
    Text(post.content)
      .font(.body)
  }
  
  @ViewBuilder
  private var threadLineView: some View {
    if post.hasReply {
      Rectangle()
        .frame(width: 1)
        .frame(maxHeight: .infinity)
        .foregroundStyle(
          LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .top,
            endPoint: .bottom
          ))
    }
  }

  private var actionsView: some View {
    HStack(spacing: 16) {
      Button(action: {}) {
        Label("\(post.replyCount)", systemImage: "bubble")
      }
      .buttonStyle(.plain)
      .foregroundStyle(
        LinearGradient(
          colors: [.indigo, .purple],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      Button(action: {}) {
        Label("\(post.repostCount)", systemImage: "quote.bubble")
      }
      .buttonStyle(.plain)
      .symbolVariant(post.isReposted ? .fill : .none)
      .foregroundStyle(
        LinearGradient(
          colors: [.purple, .indigo],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      Button(action: {}) {
        Label("\(post.likeCount)", systemImage: "heart")
      }
      .buttonStyle(.plain)
      .symbolVariant(post.isLiked ? .fill : .none)
      .foregroundStyle(
        LinearGradient(
          colors: [.red, .purple],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )

      Spacer()

      Button(action: {}) {
        Image(systemName: "ellipsis")
      }
      .buttonStyle(.plain)
      .foregroundStyle(
        LinearGradient(
          colors: [.indigo, .purple],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
    }
    .buttonStyle(.plain)
    .labelStyle(.customSpacing(4))
    .font(.callout)
    .padding(.top, 8)
    .padding(.bottom, 16)
  }
}

#Preview {
  NavigationStack {
    List {
      PostRowView(
        post: .init(
          uri: "",
          indexedAt: Date(),
          author: .init(
            did: "",
            handle: "dimillian",
            displayName: "Thomas Ricouard",
            avatarImageURL: nil),
          content: "Just some content",
          replyCount: 10,
          repostCount: 150,
          likeCount: 38,
          isLiked: false,
          isReposted: false,
          embed: nil))
      PostRowView(
        post: .init(
          uri: "",
          indexedAt: Date(),
          author: .init(
            did: "",
            handle: "dimillian",
            displayName: "Thomas Ricouard",
            avatarImageURL: nil),
          content: "Just some content",
          replyCount: 10,
          repostCount: 150,
          likeCount: 38,
          isLiked: true,
          isReposted: false,
          embed: nil))
      PostRowView(
        post: .init(
          uri: "",
          indexedAt: Date(),
          author: .init(
            did: "",
            handle: "dimillian",
            displayName: "Thomas Ricouard",
            avatarImageURL: nil),
          content: "Just some content",
          replyCount: 10,
          repostCount: 150,
          likeCount: 38,
          isLiked: true,
          isReposted: true,
          embed: nil))
    }
    .listStyle(.plain)
  }
}
