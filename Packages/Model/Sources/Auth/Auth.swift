import ATProtoKit
import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: @unchecked Sendable {
  let keychain = KeychainSwift()

  public private(set) var configuration: ATProtocolConfiguration?
  
  private let configurationContinuation: AsyncStream<ATProtocolConfiguration?>.Continuation
  public let configurationUpdates: AsyncStream<ATProtocolConfiguration?>

  private let ATProtoKeychain: AppleSecureKeychain

  public func logout() async throws {
    try await configuration?.deleteSession()
    configuration = nil
    configurationContinuation.yield(nil)
  }

  public init() {
    if let uuid = keychain.get("session_uuid") {
      self.ATProtoKeychain = AppleSecureKeychain(identifier: .init(uuidString: uuid) ?? UUID())
    } else {
      let newUUID = UUID().uuidString
      keychain.set(newUUID, forKey: "session_uuid")
      self.ATProtoKeychain = AppleSecureKeychain(identifier: .init(uuidString: newUUID) ?? UUID())
    }
    
    var continuation: AsyncStream<ATProtocolConfiguration?>.Continuation!
    self.configurationUpdates = AsyncStream { cont in
      continuation = cont
    }
    self.configurationContinuation = continuation
  }

  public func authenticate(handle: String, appPassword: String) async throws {
    let configuration = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
    try await configuration.authenticate(with: handle, password: appPassword)
    self.configuration = configuration
    configurationContinuation.yield(configuration)
  }

  public func refresh() async {
    do {
      let configuration = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
      try await configuration.refreshSession()
      self.configuration = configuration
      configurationContinuation.yield(configuration)
    } catch {
      self.configuration = nil
      configurationContinuation.yield(nil)
    }
  }

}

extension UserSession: @retroactive Equatable {
  public static func == (lhs: UserSession, rhs: UserSession) -> Bool {
    lhs.sessionDID == rhs.sessionDID
  }
}
