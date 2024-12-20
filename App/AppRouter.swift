import FeedUI
import NotificationsUI
import PostUI
import ProfileUI
import Router
import SwiftUI

public struct AppRouter: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .navigationDestination(for: RouterDestination.self) { destination in
        switch destination {
        case .feed(let feedItem):
          PostsFeedView(feedItem: feedItem)
        case .post(let post):
          PostDetailView(post: post)
        case .timeline:
          PostsTimelineView()
        case .profile(let profile):
          ProfileView(profile: profile)
        case .profilePosts(let profile, let filter):
          PostsProfileView(profile: profile, filter: filter)
        case .profileLikes(let profile):
          PostsLikesView(profile: profile)
        }
      }
  }
}

extension View {
  public func withAppRouter() -> some View {
    modifier(AppRouter())
  }
}
