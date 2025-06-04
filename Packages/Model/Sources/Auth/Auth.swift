import ATProtoKit
import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: @unchecked Sendable {
  let keychain = KeychainSwift()

  public private(set) var sessionLastRefreshed: Date?

  public private(set) var configuration: ATProtocolConfiguration?

  private let ATProtoKeychain: AppleSecureKeychain

  public func logout() async throws {
    try await configuration?.deleteSession()
    configuration = nil
    sessionLastRefreshed = Date()
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
    defer { sessionLastRefreshed = Date() }
    let configuration = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
    try await configuration.authenticate(with: handle, password: appPassword)
    self.configuration = configuration
  }

  public func refresh() async {
    defer { sessionLastRefreshed = Date() }
    do {
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
