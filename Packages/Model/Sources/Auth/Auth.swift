import ATProtoKit
import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: Sendable {
  let keychain = KeychainSwift()

  private var authToken: String? {
    get {
      keychain.get("auth_token")
    }
    set {
      if let newValue {
        keychain.set(newValue, forKey: "auth_token")
      } else {
        keychain.delete("auth_token")
      }
    }
  }

  private var refreshToken: String? {
    get {
      keychain.get("refresh_token")
    }
    set {
      if let newValue {
        keychain.set(newValue, forKey: "refresh_token")
      } else {
        keychain.delete("refresh_token")
      }
    }
  }

  public var session: UserSession? {
    get async throws {
      if let refreshToken {
        let configuration = ATProtocolConfiguration(handle: "", appPassword: "")
        let session = try await configuration.refreshSession(using: refreshToken)
        self.authToken = session.accessToken
        self.refreshToken = session.refreshToken
        return session
      }
      return nil
    }
  }
  
  public func logout() {
    self.authToken = nil
    self.refreshToken = nil
  }

  public init() { }

  public func authenticate(handle: String, appPassword: String) async throws -> UserSession {
    let configuration = ATProtocolConfiguration(
      handle: handle,
      appPassword: appPassword)
    let session = try await configuration.authenticate()
    self.authToken = session.accessToken
    self.refreshToken = session.refreshToken
    return session
  }

}
