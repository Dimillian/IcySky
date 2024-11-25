import Foundation
import SwiftData

@Model
public class RecentFeedItem {
  @Attribute(.unique)
  public var uri: String
  public var name: String
  public var avatarImageURL: URL? = nil
  public var lastViewedAt: Date

  public init(uri: String, name: String, avatarImageURL: URL?, lastViewedAt: Date) {
    self.uri = uri
    self.name = name
    self.avatarImageURL = avatarImageURL
    self.lastViewedAt = lastViewedAt
  }
}
