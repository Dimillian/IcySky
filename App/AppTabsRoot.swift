import SwiftUI
import DesignSystem
import Network
import Models
import Auth
import FeedUI
import PostUI

@MainActor
extension AppTab {
  @ViewBuilder
  var rootView: some View {
    switch self {
    case .feed:
      NavigationStack {
        FeedsListView()
          .containerRelativeFrame([.horizontal, .vertical])
          .navigationDestination(for: FeedItem.self) { feed in
            PostsListView(feed: feed)
          }
      }
      .containerRelativeFrame([.horizontal, .vertical])
    case .profile:
      HStack {
        Text("Profile view")
      }
      .containerRelativeFrame([.horizontal, .vertical])
    case .messages:
      HStack {
        Text("Messages view")
      }
      .containerRelativeFrame([.horizontal, .vertical])
    case .notification:
      HStack {
        Text("Notifications view")
      }
      .containerRelativeFrame([.horizontal, .vertical])
    case .settings:
      NavigationStack {
        ScrollView {
          VStack(alignment: .leading) {
            HeaderView(title: "Settings", showBack: false)
            Button {
              let auth = Auth()
              auth.logout()
            } label: {
              Text("Signout")
                .padding()
            }
            .buttonStyle(.pill)
          }
        }
        .navigationBarHidden(true)
      }
      .containerRelativeFrame([.horizontal, .vertical])
    }
  }
}
