import ATProtoKit
import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: @unchecked Sendable {
  let keychain = KeychainSwift()

  public private(set) var authToken: String? {
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

  public private(set) var refreshToken: String? {
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

  public private(set) var session: UserSession?

  public func logout() {
    self.authToken = nil
    self.refreshToken = nil
    self.session = nil
  }

  public init() {}

  public func authenticate(handle: String, appPassword: String) async throws {
    let configuration = ATProtocolConfiguration(
      handle: handle,
      appPassword: appPassword)
    let session = try await configuration.authenticate()
    self.authToken = session.accessToken
    self.refreshToken = session.refreshToken
    self.session = session
  }

  public func refresh() async -> UserSession? {
    do {
      if let refreshToken {
        let configuration = ATProtocolConfiguration(handle: "", appPassword: "")
        let session = try await configuration.refreshSession(using: refreshToken)
        self.authToken = session.accessToken
        self.refreshToken = session.refreshToken
        self.session = session
        return session
      }
      return nil
    } catch {
      self.session = nil
      return nil
    }
  }

}

extension UserSession: @retroactive Equatable, @unchecked Sendable {
  public static func == (lhs: UserSession, rhs: UserSession) -> Bool {
    lhs.accessToken == rhs.accessToken && lhs.refreshToken == rhs.refreshToken
  }
}
