import ATProtoKit
import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: @unchecked Sendable {
  let keychain = KeychainSwift()
  
  public private(set) var sessionRefreshed = Date()
  
  public private(set) var configuration: ATProtocolConfiguration?
  
  private let ATProtoKeychain: AppleSecureKeychain
  
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

  public func logout() async throws {
    try await configuration?.deleteSession()
    refreshToken = nil
    authToken = nil
    configuration = nil
    sessionRefreshed = Date()
  }

  public init() {
    if let uuid = keychain.get("session_uuid") {
      self.ATProtoKeychain = AppleSecureKeychain(identifier: .init(uuidString: uuid) ?? UUID())
    } else {
      let newUUID = UUID().uuidString
      keychain.set(newUUID, forKey: "session_uuid")
      self.ATProtoKeychain = AppleSecureKeychain(identifier: .init(uuidString: newUUID) ?? UUID())
    }
    
  }

  public func authenticate(handle: String, appPassword: String) async throws {
    defer { sessionRefreshed = Date() }
    let configuration = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
    try await configuration.authenticate(with: handle, password: appPassword)
    self.authToken = try await configuration.keychainProtocol.retrieveAccessToken()
    self.refreshToken = try await configuration.keychainProtocol.retrieveRefreshToken()
    self.configuration = configuration
  }

  public func refresh() async {
    defer { sessionRefreshed = Date() }
    do {
      guard let authToken, let refreshToken else { return }
      try await ATProtoKeychain.saveAccessToken(authToken)
      try await ATProtoKeychain.saveRefreshToken(refreshToken)
      let configuration = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
      try await configuration.refreshSession()
      self.configuration = configuration
    } catch {
      self.configuration = nil
    }
  }

}

extension UserSession: @retroactive Equatable, @unchecked Sendable {
  public static func == (lhs: UserSession, rhs: UserSession) -> Bool {
    lhs.sessionDID == rhs.sessionDID
  }
}
