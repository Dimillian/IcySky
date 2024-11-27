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
        image.resizable()
      } placeholder: {
        Color.gray
      }
      .frame(width: 40, height: 40)
      .clipShape(Circle())

      VStack(alignment: .leading) {
        Text(
          notification.notificationAuthor.displayName ?? notification.notificationAuthor.actorHandle
        )
        .fontWeight(.semibold)
        Text(actionText)
          .foregroundStyle(.secondary)

        if let postItem {
          PostRowView(post: postItem)
        }
      }

      Spacer()

      Text(notification.indexedAt.relativeFormatted)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
  }
}
