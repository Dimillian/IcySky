import ATProtoKit
import Auth
import DesignSystem
import Models
import Network
import SwiftUI

public struct AuthView: View {
  @Environment(Auth.self) private var auth

  @State private var handle: String = ""
  @State private var appPassword: String = ""
  @State private var error: String? = nil

  public init() {}

  public var body: some View {
    Form {
      HeaderView(title: "🦋 Bluesky Login")

      Section {
        TextField("john@bsky.social", text: $handle)
          .font(.title2)
          .textInputAutocapitalization(.never)
        SecureField("App Password", text: $appPassword)
          .font(.title2)
      }
      .listRowSeparator(.hidden)

      Section {
        Button {
          Task {
            do {
              try await auth.authenticate(handle: handle, appPassword: appPassword)
            } catch {
              self.error = error.localizedDescription
            }
          }
        } label: {
          Text("🦋 Login to Bluesky")
            .font(.headline)
            .padding()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.glass)

        if let error {
          Text(error)
            .foregroundColor(.red)
        }
      }
    }
    .scrollContentBackground(.hidden)
  }
}

#Preview {
  @Previewable @State var auth: Auth = .init()
  ScrollView {
    Text("Hello World")
  }
  .sheet(isPresented: .constant(true)) {
    AuthView()
      .environment(auth)
  }
}
