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

  public private(set) var configuration: ATProtocolConfiguration?

  public func logout() {
    self.authToken = nil
    self.refreshToken = nil
    self.configuration = nil
  }

  public init() {}

  public func authenticate(handle: String, appPassword: String) async throws {
    let configuration = ATProtocolConfiguration(
      handle: handle,
      appPassword: appPassword)
    try await configuration.authenticate()
    if let session = configuration.session {
      self.authToken = session.accessToken
      self.refreshToken = session.refreshToken
    }
    self.configuration = configuration
  }

  public func refresh() async {
    do {
      if let refreshToken {
        let configuration = ATProtocolConfiguration(handle: "", appPassword: "")
        _ = try await configuration.refreshSession(by: refreshToken)
        if let session = configuration.session {
          self.authToken = session.accessToken
          self.refreshToken = session.refreshToken
        }
        self.configuration = configuration
      }
    } catch {
      self.configuration = nil
    }
  }

}

extension ATProtocolConfiguration: @retroactive Equatable {
  public static func == (lhs: ATProtocolConfiguration, rhs: ATProtocolConfiguration) -> Bool {
    lhs.session == rhs.session
  }
}

extension UserSession: @retroactive Equatable, @unchecked Sendable {
  public static func == (lhs: UserSession, rhs: UserSession) -> Bool {
    lhs.accessToken == rhs.accessToken && lhs.refreshToken == rhs.refreshToken
  }
}
