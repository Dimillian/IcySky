import Auth
import DesignSystem
import FeedUI
import Models
import Network
import NotificationsUI
import PostUI
import ProfileUI
import AppRouter
import SettingsUI
import SwiftUI
import Destinations

struct AppTabRootView: View {
  @Environment(RouterAlias.self) var router

  let tab: AppTab

  var body: some View {
    @Bindable var router = router

    GeometryReader { _ in
      NavigationStack(path: $router[tab]) {
        tab.rootView
          .navigationBarHidden(true)
          .withAppRouter()
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
      CurrentUserView()
    case .messages:
      HStack {
        Text("Messages view")
      }
    case .notification:
      NotificationsListView()
    case .settings:
      SettingsView()
    }
  }
}
