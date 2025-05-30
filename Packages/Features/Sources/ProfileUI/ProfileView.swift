import DesignSystem
import Models
import PostUI
import AppRouter
import SwiftUI
import Destinations

public struct ProfileView: View {
  @Environment(RouterAlias.self) var router
    
  public let profile: Profile
  public let showBack: Bool

  public init(profile: Profile, showBack: Bool = true) {
    self.profile = profile
    self.showBack = showBack
  }

  public var body: some View {
    List {
      HeaderView(
        title: profile.displayName ?? profile.handle,
        subtitle: "@\(profile.handle)",
        showBack: showBack
      )
      .padding(.bottom)

      NavigationLink(
        value: RouterDestination.profilePosts(profile: profile, filter: .postsWithNoReplies)
      ) {
        makeLabelButton(title: "Posts", icon: "bubble.fill", color: .blueskyBackground)
      }

      NavigationLink(
        value: RouterDestination.profilePosts(profile: profile, filter: .postsWithReplies)
      ) {
        makeLabelButton(title: "Replies", icon: "arrowshape.turn.up.left.fill", color: .teal)
      }

      NavigationLink(
        value: RouterDestination.profilePosts(profile: profile, filter: .postsWithMedia)
      ) {
        makeLabelButton(title: "Medias", icon: "photo.fill", color: .gray)
      }

      NavigationLink(
        value: RouterDestination.profilePosts(profile: profile, filter: .postAndAuthorThreads)
      ) {
        makeLabelButton(title: "Threads", icon: "bubble.left.and.bubble.right.fill", color: .green)
      }

      NavigationLink(value: RouterDestination.profileLikes(profile)) {
        makeLabelButton(title: "Likes", icon: "heart.fill", color: .red)
      }
    }
    .listStyle(.plain)
    .navigationBarBackButtonHidden()
    .toolbar(.hidden, for: .navigationBar)
  }

  private func makeLabelButton(title: String, icon: String, color: Color) -> some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(.white)
        .shadow(color: .white, radius: 3)
        .padding(12)
        .background(
          LinearGradient(
            colors: [color, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        )
        .frame(width: 40, height: 40)
        .glowingRoundedRectangle()
      Text(title)
        .font(.title3)
        .fontWeight(.semibold)
      Spacer()
    }
  }
}
