@preconcurrency import ATProtoKit
import SwiftUI

@Observable
public class BSkyClient {
  public let session: UserSession
  public let protoClient: ATProtoKit
  public let blueskyClient: ATProtoBluesky

  public init(session: UserSession) {
    self.session = session
    self.protoClient = ATProtoKit(session: session)
    self.blueskyClient = ATProtoBluesky(atProtoKitInstance: protoClient)
  }

  static public func preview() -> BSkyClient {
    .init(
      session: .init(
        handle: "",
        sessionDID: "",
        isEmailAuthenticationFactorEnabled: nil,
        accessToken: "",
        refreshToken: "",
        isActive: nil,
        status: nil)
    )
  }
}

extension ATProtoKit: @unchecked @retroactive Sendable {}
extension ATProtoBluesky: @unchecked @retroactive Sendable {}
