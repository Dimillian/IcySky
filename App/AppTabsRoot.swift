import Auth
import DesignSystem
import FeedUI
import Models
import Network
import PostUI
import Router
import SettingsUI
import SwiftUI

struct AppTabRootView: View {
  @Environment(Router.self) var router

  let tab: AppTab

  var body: some View {
    @Bindable var router = router

    GeometryReader { _ in
      NavigationStack(path: $router[tab]) {
        tab.rootView
          .navigationBarHidden(true)
          .navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
            case .feed(let feed):
              PostsFeedView(feed: feed)
            case .post(let post):
              PostDetailView(post: post)
            }
          }
          .environment(\.currentTab, tab)
      }
    }
    .ignoresSafeArea()
  }
}

@MainActor
extension AppTab {
  @ViewBuilder
  fileprivate var rootView: some View {
    switch self {
    case .feed:
      FeedsListView()
    case .profile:
      HStack {
        Text("Profile view")
      }
    case .messages:
      HStack {
        Text("Messages view")
      }
    case .notification:
      HStack {
        Text("Notifications view")
      }
    case .settings:
      SettingsView()
    }
  }
}
