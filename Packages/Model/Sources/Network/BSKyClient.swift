@preconcurrency import ATProtoKit
import SwiftUI

@Observable
public class BSkyClient {
  public let session: UserSession
  public let protoClient: ATProtoKit

  public init(session: UserSession, protoClient: ATProtoKit) {
    self.session = session
    self.protoClient = protoClient
  }
  
  static public func preview() -> BSkyClient {
    .init(session: .init(handle: "",
                         sessionDID: "",
                         isEmailAuthenticationFactorEnabled: nil,
                         accessToken: "",
                         refreshToken: "",
                         isActive: nil,
                         status: nil),
          protoClient: .init())
  }
}

extension ATProtoKit: @unchecked @retroactive Sendable { }
