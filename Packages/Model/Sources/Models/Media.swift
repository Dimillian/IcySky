import Foundation

public struct Media: Identifiable, Hashable {
  public var id: URL { url }
  public let url: URL
  public let alt: String?

  public init(url: URL, alt: String?) {
    self.url = url
    self.alt = alt?.isEmpty == true ? nil : alt
  }
}
