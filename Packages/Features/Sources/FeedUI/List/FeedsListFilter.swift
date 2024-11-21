import Foundation

public enum FeedsListFilter: String, CaseIterable, Identifiable {
  case suggested = "Suggested"
  case myFeeds = "My Feeds"

  public var id: Self { self }

  var icon: String {
    switch self {
    case .suggested: return "sparkles.rectangle.stack"
    case .myFeeds: return "person.crop.rectangle.stack"
    }
  }
}
