import ATProtoKit
import DesignSystem
import PostUI
import Router
import SwiftUI

struct GroupedNotificationRow: View {
  @Environment(Router.self) var router

  let group: NotificationsGroup
  let actionText: (Int) -> String  // Closure to generate action text based on count

  var body: some View {
    VStack(alignment: .leading) {
      if group.postItem != nil {
        HStack(alignment: .top) {
          actionTextView
          Spacer()
          Text(group.timestamp.relativeFormatted)
            .foregroundStyle(.secondary)
        }
        ZStack(alignment: .bottomTrailing) {
          postView
          avatarsView
            .offset(x: group.postItem == nil ? 0 : 6, y: 24)
          NotificationIconView(
            icon: group.type.iconName,
            color: group.type.color
          )
          .offset(x: 6, y: 18)
        }
      } else {
        ZStack(alignment: .bottomTrailing) {
          avatarsView
            .offset(x: group.postItem == nil ? 0 : 6)
          NotificationIconView(
            icon: group.type.iconName,
            color: group.type.color
          )
          .offset(x: 0, y: -4)
        }
        HStack(alignment: .top) {
          actionTextView
          Spacer()
          Text(group.timestamp.relativeFormatted)
            .foregroundStyle(.secondary)
        }
      }
    }
    .padding(.vertical, 12)
    .padding(.bottom, 6)
  }

  @ViewBuilder
  private var postView: some View {
    if let post = group.postItem {
      HStack(alignment: .top) {
        PostRowBodyView(post: post)
          .foregroundStyle(.secondary)
        Spacer()
        PostRowEmbedView(post: post)
      }
      .environment(\.isQuote, true)
      .padding(8)
      .background {
        RoundedRectangle(cornerRadius: 8)
          .fill(.thinMaterial)
          .stroke(
            LinearGradient(
              colors: [group.type.color, .indigo],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1
          )
          .shadow(color: group.type.color.opacity(0.5), radius: 3)
      }
      .contentShape(Rectangle())
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
            .fill(Color.blueskyBackground)
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

  @ViewBuilder
  private var actionTextView: some View {
    if group.notifications.count == 1 {
      Text(
        group.notifications[0].notificationAuthor.displayNameOrHandle
      )
      .fontWeight(.semibold)
        + Text(actionText(1))
        .foregroundStyle(.secondary)
    } else {
      Text(
        group.notifications[0].notificationAuthor.displayNameOrHandle
      )
      .fontWeight(.semibold)
        + Text(actionText(group.notifications.count))
        .foregroundStyle(.secondary)
    }
  }
}
