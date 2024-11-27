import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftUI

public struct NotificationsListView: View {
  @Environment(BSkyClient.self) private var client

  @State private var notifications: [AppBskyLexicon.Notification.Notification] = []

  public init() {}

  public var body: some View {
    NavigationStack {
      List {
        HeaderView(title: "Notifications", showBack: false)
          .padding(.bottom)
        ForEach(notifications, id: \.notificationURI) { notification in
          Text(notification.notificationReason.rawValue)
        }
      }
      .listStyle(.plain)
    }
    .task {
      await fetchNotifications()
    }
  }

  private func fetchNotifications() async {
    do {
      self.notifications = try await client.protoClient.listNotifications(priority: false)
        .notifications
    } catch {
      print(error)
    }
  }
}
