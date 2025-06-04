import Foundation
import Models
import Network
import SwiftUI
import User

enum AppState: Sendable {
  case resuming
  case authenticated(client: BSkyClient, currentUser: CurrentUser)
  case unauthenticated
  case error(Error)
}
