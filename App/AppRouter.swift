import FeedUI
import NotificationsUI
import PostUI
import Router
import SwiftUI

public struct AppRouter: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .navigationDestination(for: RouterDestination.self) { destination in
        switch destination {
        case .feed(let uri, let name, let avatarImageURL):
          PostsFeedView(uri: uri, name: name, avatarImageURL: avatarImageURL)
        case .post(let post):
          PostDetailView(post: post)
        case .timeline:
          PostsTimelineView()
        }
      }
  }
}

extension View {
  public func withAppRouter() -> some View {
    modifier(AppRouter())
  }
}
