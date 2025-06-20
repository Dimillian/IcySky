import Foundation
import Models
import Client
import SwiftUI
import User

enum AppState: Sendable {
  case resuming
  case authenticated(client: BSkyClient, currentUser: CurrentUser)
  case unauthenticated
  case error(Error)
  
  var client: BSkyClient? {
    if case .authenticated(let client, _) = self {
      return client
    }
    return nil
  }
  
  var currentUser: CurrentUser? {
    if case .authenticated(_, let currentUser) = self {
      return currentUser
    }
    return nil
  }
}
