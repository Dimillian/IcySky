import Foundation

public enum FeedsListFilter: String, CaseIterable, Identifiable {
  case suggested = "Suggested"
  case savedFeeds = "Saved"
  case pinned = "Pinned"

  public var id: Self { self }

  var icon: String {
    switch self {
    case .suggested: return "sparkles.rectangle.stack"
    case .savedFeeds: return "person.crop.rectangle.stack"
    case .pinned: return "pin"
    }
  }
}
