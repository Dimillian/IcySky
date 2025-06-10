import AppRouter
import SwiftUI

extension EnvironmentValues {
  @Entry public var currentTab: AppTab = .feed
}

public enum AppTab: String, TabType {
  case feed, notification, profile, settings, compose

  public var id: String { rawValue }
  
  public var title: String {
    switch self {
    case .feed: return "Feed"
    case .notification: return "Notifications"
    case .profile: return "Profile"
    case .settings: return "Settings"
    case .compose: return "New Post"
    }
  }

  public var icon: String {
    switch self {
    case .feed: return "square.stack"
    case .notification: return "bell"
    case .profile: return "person"
    case .settings: return "gearshape"
    case .compose: return "square.and.pencil"
    }
  }
}
