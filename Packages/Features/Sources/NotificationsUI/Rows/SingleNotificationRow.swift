import ATProtoKit
import Models
import Network
import PostUI
import AppRouter
import SwiftUI
import Destinations

struct SingleNotificationRow: View {
  @Environment(RouterAlias.self) var router
  @Environment(BSkyClient.self) var client
  @Environment(PostContextProvider.self) var postDataControllerProvider

  let notification: AppBskyLexicon.Notification.Notification
  let postItem: PostItem?
  let actionText: String

  var body: some View {
    HStack(alignment: .top) {
      AsyncImage(url: notification.author.avatarImageURL) { image in
        image
          .resizable()
          .scaledToFit()
          .clipShape(Circle())
      } placeholder: {
        Color.gray
      }
      .frame(width: 40, height: 40)
      .overlay {
        Circle()
          .stroke(
            LinearGradient(
              colors: [.shadowPrimary.opacity(0.5), .indigo.opacity(0.5)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1)
      }
      .shadow(color: .shadowPrimary.opacity(0.3), radius: 2)

      VStack(alignment: .leading) {
        Text(notification.author.displayNameOrHandle)
          .fontWeight(.semibold)
        HStack {
          Image(systemName: notification.reason.iconName)
          Text(actionText)
        }
        .foregroundStyle(.secondary)

        if let postItem {
          VStack(alignment: .leading, spacing: 8) {
            PostRowBodyView(post: postItem)
            PostRowEmbedView(post: postItem)
            PostRowActionsView(post: postItem)
              .environment(\.hideMoreActions, true)
          }
          .padding(.top, 8)
          .contentShape(Rectangle())
          .onTapGesture {
            router.navigateTo(RouterDestination.post(postItem))
          }
          .environment(postDataControllerProvider.get(for: postItem, client: client))
        }
      }

      Spacer()

      Text(notification.indexedAt.relativeFormatted)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
  }
}
