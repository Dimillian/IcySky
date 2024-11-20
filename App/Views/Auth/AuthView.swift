import Auth
import DesignSystem
import Models
import SwiftUI
import Network
import ATProtoKit

struct AuthView: View {
  public let onSessionCreated: (UserSession) -> Void

  @State private var handle: String = ""
  @State private var appPassword: String = ""
  @State private var error: String? = nil

  var body: some View {
    Form {
      HeaderView(title: "🦋 Bluesky Login")
        
      Section {
        TextField("john@bsky.social", text: $handle)
          .font(.title2)
        SecureField("App Password", text: $appPassword)
          .font(.title2)
      }
      .listRowSeparator(.hidden)

      Section {
        Button {
          Task {
            do {
              let auth = Auth()
              let session = try await auth.authenticate(handle: handle, appPassword: appPassword)
              onSessionCreated(session)
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
        .buttonStyle(.pill)

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
  ScrollView {
    Text("Hello World")
  }
    .sheet(isPresented: .constant(true)) {
      AuthView { _ in
        
      }
    }
}
