import ATProtoKit
import PostUI
import Router
import SwiftUI

struct GroupedNotificationRow: View {
  @Environment(Router.self) var router

  let group: NotificationsGroup
  let actionText: (Int) -> String  // Closure to generate action text based on count

  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .bottomTrailing) {
        postView
        avatarsView
          .offset(x: group.postItem == nil ? 0 : 6, y: 11)
        iconView
          .offset(x: 6, y: 6)
      }
      actionTextView
        .padding(.top, 12)
    }
    .padding(.vertical, 12)
  }

  @ViewBuilder
  private var postView: some View {
    if let post = group.postItem {
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          PostRowBodyView(post: post)
            .foregroundStyle(.secondary)
          PostRowEmbedView(post: post)
        }
        Spacer()
      }
      .environment(\.isQuote, true)
      .padding(8)
      .padding(.bottom, 12)
      .background(.thinMaterial)
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            LinearGradient(
              colors: [group.type.color, .indigo],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1
          )
          .shadow(color: group.type.color.opacity(0.5), radius: 3)
      }
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .onTapGesture {
        router.navigateTo(RouterDestination.post(post))
      }
    }
  }

  private var avatarsView: some View {
    HStack(spacing: -10) {
      ForEach(group.notifications.prefix(5), id: \.notificationURI) { notification in
        AsyncImage(url: notification.notificationAuthor.avatarImageURL) { image in
          image.resizable()
        } placeholder: {
          Circle()
            .fill(.secondary)
        }
        .frame(width: 30, height: 30)
        .clipShape(Circle())
        .overlay(
          Circle().stroke(
            LinearGradient(
              colors: [group.type.color, .indigo],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
        )
      }
    }
    .padding(.trailing, 12)
  }

  private var iconView: some View {
    Image(systemName: group.type.iconName)
      .foregroundStyle(
        group.type.color
          .shadow(.drop(color: group.type.color.opacity(0.5), radius: 2))
      )
      .shadow(color: group.type.color, radius: 1)
      .background(
        Circle()
          .fill(.thickMaterial)
          .stroke(
            LinearGradient(
              colors: [group.type.color, .indigo],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1
          )
          .frame(width: 30, height: 30)
          .shadow(color: group.type.color.opacity(0.5), radius: 3)
      )
  }

  @ViewBuilder
  private var actionTextView: some View {
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
  }
}
