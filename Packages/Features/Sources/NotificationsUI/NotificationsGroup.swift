import ATProtoKit
import Foundation
import Models
import Client
import SwiftUI

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

    let postsURIs =
      Array(
        Set(
          sortedNotifications
            .filter { $0.reason != .follow }
            .compactMap { $0.postURI }
        ))
    var postItems: [PostItem] = []
    do {
      postItems = try await client.protoClient.getPosts(postsURIs).posts.map { $0.postItem }
    } catch {
      postItems = []
    }

    for notification in sortedNotifications {
      let reason = notification.reason

      if reason.shouldGroup {
        // Group notifications by type and subject
        let key = notification.reasonSubjectURI ?? "general"
        groupedNotifications[reason, default: [:]][key, default: []].append(notification)
      } else {
        // Create individual groups for non-grouped notifications
        groups.append(
          NotificationsGroup(
            id: notification.uri,
            timestamp: notification.indexedAt,
            type: reason,
            notifications: [notification],
            postItem: postItems.first(where: { $0.uri == notification.postURI })
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
            postItem: postItems.first(where: { $0.uri == notifications[0].postURI })
          ))
      }
    }

    // Sort all groups by timestamp
    return groups.sorted { $0.timestamp > $1.timestamp }
  }
}

extension AppBskyLexicon.Notification.Notification.Reason: @retroactive Hashable, @retroactive
  Equatable
{
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.rawValue)
  }

  public static func == (
    lhs: AppBskyLexicon.Notification.Notification.Reason,
    rhs: AppBskyLexicon.Notification.Notification.Reason
  ) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension AppBskyLexicon.Notification.Notification {
  fileprivate var postURI: String? {
    switch reason {
    case .follow, .starterpackjoined: return nil
    case .like, .repost: return reasonSubjectURI
    case .reply, .mention, .quote: return uri
    default: return nil
    }
  }
}

extension AppBskyLexicon.Notification.Notification.Reason {
  fileprivate var shouldGroup: Bool {
    switch self {
    case .like, .follow, .repost:
      return true
    case .reply, .mention, .quote, .starterpackjoined:
      return false
    default:
      return false
    }
  }

  var iconName: String {
    switch self {
    case .like: return "heart.fill"
    case .follow: return "person.fill.badge.plus"
    case .repost: return "quote.opening"
    case .mention: return "at"
    case .quote: return "quote.opening"
    case .reply: return "arrowshape.turn.up.left.fill"
    case .starterpackjoined: return "star"
    default: return "bell.fill"  // Fallback for unknown reasons
    }
  }

  var color: Color {
    switch self {
    case .like: return .pink
    case .follow: return .blue
    case .repost: return .green
    case .mention: return .purple
    case .quote: return .orange
    case .reply: return .teal
    case .starterpackjoined: return .yellow
    default: return .gray  // Fallback for unknown reasons
    }
  }
}
