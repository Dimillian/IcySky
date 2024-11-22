import SwiftUI

extension EnvironmentValues {
  @Entry public var currentTab: AppTab = .feed
}

public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
  case feed, notification, messages, profile, settings

  public var id: String { rawValue }

  public var icon: String {
    switch self {
    case .feed: return "square.stack"
    case .notification: return "bell"
    case .messages: return "message"
    case .profile: return "person"
    case .settings: return "gearshape"
    }
  }
}
