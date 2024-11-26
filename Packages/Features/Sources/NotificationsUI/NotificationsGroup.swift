import ATProtoKit
import Foundation
import Models
import Network

@MainActor
struct NotificationsGroup: Identifiable {
  let id: String
  let timestamp: Date
  let type: AppBskyLexicon.Notification.Notification.Reason
  let notifications: [AppBskyLexicon.Notification.Notification]
  let postItem: PostItem?

  static func groupNotifications(
    client: BSkyClient,
    _ notifications: [AppBskyLexicon.Notification.Notification]
  ) async -> [NotificationsGroup] {
    var groups: [NotificationsGroup] = []
    var groupedNotifications:
      [AppBskyLexicon.Notification.Notification.Reason: [String: [AppBskyLexicon.Notification
        .Notification]]] = [:]

    // Sort notifications by date
    let sortedNotifications = notifications.sorted { $0.indexedAt > $1.indexedAt }

    let subjectURI = sortedNotifications.filter { $0.notificationReason != .follow }.compactMap {
      $0.notificationReason == .reply ? $0.notificationURI : $0.reasonSubjectURI
    }
    var postItems: [PostItem] = []
    do {
      postItems = try await client.protoClient.getPosts(subjectURI).posts.map { $0.postItem }
    } catch {
      postItems = []
    }

    for notification in sortedNotifications {
      let reason = notification.notificationReason

      if reason.shouldGroup {
        // Group notifications by type and subject
        let key = notification.reasonSubjectURI ?? "general"
        groupedNotifications[reason, default: [:]][key, default: []].append(notification)
      } else {
        // Create individual groups for non-grouped notifications
        groups.append(
          NotificationsGroup(
            id: notification.notificationURI,
            timestamp: notification.indexedAt,
            type: reason,
            notifications: [notification],
            postItem: postItems.first(where: { $0.uri == notification.reasonSubjectURI })
          ))
      }
    }

    // Add grouped notifications
    for (reason, subjectGroups) in groupedNotifications {
      for (subjectURI, notifications) in subjectGroups {
        groups.append(
          NotificationsGroup(
            id: "\(reason)-\(subjectURI)-\(notifications[0].indexedAt.timeIntervalSince1970)",
            timestamp: notifications[0].indexedAt,
            type: reason,
            notifications: notifications,
            postItem: postItems.first(where: { $0.uri == subjectURI })
          ))
      }
    }

    // Sort all groups by timestamp
    return groups.sorted { $0.timestamp > $1.timestamp }
  }
}

extension AppBskyLexicon.Notification.Notification.Reason {
  fileprivate var shouldGroup: Bool {
    switch self {
    case .like, .follow:
      return true
    case .reply, .repost, .mention, .quote, .starterpackjoined:
      return false
    }
  }
}
