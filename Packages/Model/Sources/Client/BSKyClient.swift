@preconcurrency import ATProtoKit
import SwiftUI

@Observable
public final class BSkyClient: Sendable {
  public let configuration: ATProtocolConfiguration
  public let protoClient: ATProtoKit
  public let blueskyClient: ATProtoBluesky

  public init(configuration: ATProtocolConfiguration) async {
    self.configuration = configuration
    self.protoClient = await ATProtoKit(sessionConfiguration: configuration)
    self.blueskyClient = ATProtoBluesky(atProtoKitInstance: protoClient)
  }
}

extension ATProtoKit: @unchecked @retroactive Sendable {}
extension ATProtoBluesky: @unchecked @retroactive Sendable {}
