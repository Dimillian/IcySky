import Auth
import DesignSystem
import FeedUI
import Models
import Network
import PostUI
import Router
import SwiftUI
import SettingsUI

struct AppTabRootView: View {
  let tab: AppTab

  @Binding var path: [RouterDestination]

  var body: some View {
    NavigationStack(path: $path) {
      tab.rootView
        .navigationBarHidden(true)
        .navigationDestination(for: RouterDestination.self) { destination in
          switch destination {
          case .feed(let feed):
            PostsListView(feed: feed)
          }
        }
    }
    .containerRelativeFrame([.horizontal, .vertical])
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
