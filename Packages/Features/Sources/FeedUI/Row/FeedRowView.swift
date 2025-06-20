import ATProtoKit
import AppRouter
import DesignSystem
import Destinations
import Models
import Client
import SwiftUI

struct FeedRowView: View {
  let feed: FeedItem

  var body: some View {
    NavigationLink(value: RouterDestination.feed(feed)) {
      VStack(alignment: .leading, spacing: 12) {
        headerView
        if let description = feed.description {
          Text(description)
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        Text("By @\(feed.creatorHandle)")
          .font(.callout)
          .foregroundStyle(.tertiary)
      }
      .padding(.vertical, 12)
    }
    .listRowSeparator(.hidden)
  }

  @ViewBuilder
  var headerView: some View {
    HStack {
      AsyncImage(url: feed.avatarImageURL) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
        default:
          Image(systemName: "antenna.radiowaves.left.and.right")
            .imageScale(.medium)
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blueskyBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
        }
      }
      VStack(alignment: .leading) {
        Text(feed.displayName)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(
            .primary.shadow(
              .inner(
                color: .shadowSecondary.opacity(0.5),
                radius: 2, x: -1, y: -1)))
        likeView
      }
    }
  }

  @ViewBuilder
  var likeView: some View {
    HStack(spacing: 2) {
      Image(systemName: feed.liked ? "heart.fill" : "heart")
        .foregroundStyle(
          LinearGradient(
            colors: [.indigo.opacity(0.4), .red],
            startPoint: .top,
            endPoint: .bottom
          )
          .shadow(.inner(color: .red, radius: 3))
        )
        .shadow(color: .red, radius: 1)
      Text("\(feed.likesCount) likes")
        .font(.callout)
        .foregroundStyle(.secondary)

    }
  }
}

#Preview {
  NavigationStack {
    List {
      FeedRowView(
        feed: FeedItem(
          uri: "",
          displayName: "Preview Feed",
          description: "This is a sample feed",
          avatarImageURL: nil,
          creatorHandle: "dimillian.app",
          likesCount: 50,
          liked: false
        )
      )
      FeedRowView(
        feed: FeedItem(
          uri: "",
          displayName: "Preview Feed",
          description: "This is a sample feed",
          avatarImageURL: nil,
          creatorHandle: "dimillian.app",
          likesCount: 50,
          liked: true
        )
      )
    }
    .listStyle(.plain)
  }
}
