import SwiftUI
import Auth
import DesignSystem

public struct SettingsView: View {
  @Environment(Auth.self) var auth
  
  public init() { }
  
  public var body: some View {
    Form {
      Section {
        HeaderView(title: "Settings", showBack: false)
        Button {
          auth.logout()
        } label: {
          Text("Signout")
            .padding()
        }
        .buttonStyle(.pill)
      }
    }
  }
}
