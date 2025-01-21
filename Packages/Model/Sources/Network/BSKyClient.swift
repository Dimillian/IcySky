@preconcurrency import ATProtoKit
import SwiftUI

@Observable
public class BSkyClient {
  public let configuration: ATProtocolConfiguration
  public let protoClient: ATProtoKit
  public let blueskyClient: ATProtoBluesky

  public init(configuration: ATProtocolConfiguration) {
    self.configuration = configuration
    self.protoClient = ATProtoKit(sessionConfiguration: configuration)
    self.blueskyClient = ATProtoBluesky(atProtoKitInstance: protoClient)
  }

  static public func preview() -> BSkyClient {
    .init(configuration: .init(service: ""))
  }
}

extension ATProtoKit: @unchecked @retroactive Sendable {}
extension ATProtoBluesky: @unchecked @retroactive Sendable {}
