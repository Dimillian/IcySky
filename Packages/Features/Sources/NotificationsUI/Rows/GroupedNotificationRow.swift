import ATProtoKit
import PostUI
import SwiftUI

struct GroupedNotificationRow: View {
  let group: NotificationsGroup
  let actionText: (Int) -> String  // Closure to generate action text based on count

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        HStack(spacing: -10) {
          ForEach(group.notifications.prefix(5), id: \.notificationURI) { notification in
            AsyncImage(url: notification.notificationAuthor.avatarImageURL) { image in
              image.resizable()
            } placeholder: {
              Color.gray
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
          }
        }
        .padding(.trailing, 8)
        if group.notifications.count == 1 {
          Text(
            group.notifications[0].notificationAuthor.displayName
              ?? group.notifications[0].notificationAuthor.actorHandle
          )
          .fontWeight(.semibold)
            + Text(actionText(1))
            .foregroundStyle(.secondary)
        } else {
          Text(
            group.notifications[0].notificationAuthor.displayName
              ?? group.notifications[0].notificationAuthor.actorHandle
          )
          .fontWeight(.semibold)
            + Text(actionText(group.notifications.count))
            .foregroundStyle(.secondary)
        }

        if let post = group.postItem {
          VStack(alignment: .leading, spacing: 8) {
            PostRowBodyView(post: post)
              .foregroundStyle(.secondary)
            PostRowEmbedView(post: post)
          }
          .environment(\.isQuote, true)
        }
      }

      Spacer()

      Text(group.notifications[0].indexedAt.relativeFormatted)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 8)
  }
}
