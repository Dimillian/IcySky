import DesignSystem
import Models
import SwiftUI

public struct ProfileView: View {
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
    }
    .listStyle(.plain)
    .navigationBarBackButtonHidden()
    .toolbar(.hidden, for: .navigationBar)
  }
}
