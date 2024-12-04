import DesignSystem
import Models
import SwiftUI

public struct ProfileView: View {
  public let profile: Profile

  public init(profile: Profile) {
    self.profile = profile
  }

  public var body: some View {
    List {
      HeaderView(title: profile.displayName ?? profile.handle)
        .padding(.bottom)
    }
    .listStyle(.plain)
  }
}
