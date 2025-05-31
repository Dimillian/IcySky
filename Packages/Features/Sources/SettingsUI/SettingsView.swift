import Auth
import DesignSystem
import SwiftUI

public struct SettingsView: View {
  @Environment(Auth.self) var auth

  public init() {}

  public var body: some View {
    Form {
      Section {
        HeaderView(title: "Settings", showBack: false)
        Button {
          Task {
            do {
              try await auth.logout()
            } catch {}
          }
        } label: {
          Text("Signout")
            .padding()
        }
        .buttonStyle(.pill)
      }
    }
  }
}
