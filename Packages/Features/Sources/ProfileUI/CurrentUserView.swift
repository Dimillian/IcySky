import SwiftUI
import User

public struct CurrentUserView: View {
  @Environment(CurrentUser.self) private var currentUser

  public init() {}

  public var body: some View {
    if let profile = currentUser.profile {
      ProfileView(profile: profile.profile, showBack: false)
    } else {
      ProgressView()
    }
  }
}
