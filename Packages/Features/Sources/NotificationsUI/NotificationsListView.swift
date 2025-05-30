import ATProtoKit
import DesignSystem
import Models
import Network
import AppRouter
import SwiftUI

public struct NotificationsListView: View {
  @Environment(BSkyClient.self) private var client

  @State private var notificationsGroups: [NotificationsGroup] = []
  @State private var cursor: String?

  public init() {}

  public var body: some View {
    List {
      HeaderView(title: "Notifications", showBack: false)
        .padding(.bottom)

      ForEach(notificationsGroups) { group in
        Section {
          switch group.type {
          case .reply:
            SingleNotificationRow(
              notification: group.notifications[0],
              postItem: group.postItem,
              actionText: "replied to your post"
            )
          case .follow:
            GroupedNotificationRow(group: group) { count in
              count == 1 ? " followed you" : " and \(count - 1) others followed you"
            }
          case .like:
            GroupedNotificationRow(group: group) { count in
              count == 1 ? " liked your post" : " and \(count - 1) others liked your post"
            }
          case .repost:
            GroupedNotificationRow(group: group) { count in
              count == 1 ? " reposted your post" : " and \(count - 1) others reposted your post"
            }
          case .mention:
            SingleNotificationRow(
              notification: group.notifications[0],
              postItem: group.postItem,
              actionText: "mentioned you"
            )
          case .quote:
            SingleNotificationRow(
              notification: group.notifications[0],
              postItem: group.postItem,
              actionText: "quoted you"
            )
          case .starterpackjoined:
            EmptyView()
          }
        }
        .listRowSeparator(.hidden)
      }

      if cursor != nil {
        ProgressView()
          .task {
            await fetchNotifications()
          }
      }
    }
    .listStyle(.plain)
    .task {
      cursor = nil
      await fetchNotifications()
    }
    .refreshable {
      cursor = nil
      await fetchNotifications()
    }
  }

  private func fetchNotifications() async {
    do {
      if let cursor {
        let response = try await client.protoClient.listNotifications(
          isPriority: false, cursor: cursor)
        self.notificationsGroups.append(
          contentsOf: await NotificationsGroup.groupNotifications(
            client: client, response.notifications)
        )
        self.cursor = response.cursor
      } else {
        let response = try await client.protoClient.listNotifications(isPriority: false)
        self.notificationsGroups = await NotificationsGroup.groupNotifications(
          client: client, response.notifications)
        self.cursor = response.cursor
      }
    } catch {
      print(error)
    }
  }
}
