import ATProtoKit
import Models
import PostUI
import SwiftUI

struct SingleNotificationRow: View {
  let notification: AppBskyLexicon.Notification.Notification
  let postItem: PostItem?
  let actionText: String

  var body: some View {
    HStack(alignment: .top) {
      AsyncImage(url: notification.notificationAuthor.avatarImageURL) { image in
        image
          .resizable()
          .scaledToFit()
          .clipShape(Circle())
      } placeholder: {
        Color.gray
      }
      .frame(width: 30, height: 30)
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
        Text(
          notification.notificationAuthor.displayName ?? notification.notificationAuthor.actorHandle
        )
        .fontWeight(.semibold)
        Text(actionText)
          .foregroundStyle(.secondary)

        if let postItem {
          VStack(alignment: .leading, spacing: 8) {
            PostRowBodyView(post: postItem)
            PostRowEmbedView(post: postItem)
            PostRowActionsView(post: postItem)
          }
          .padding(.top, 8)
        }
      }

      Spacer()

      Text(notification.indexedAt.relativeFormatted)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
  }
}
