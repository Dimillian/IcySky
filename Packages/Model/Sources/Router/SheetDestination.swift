import Models
import SwiftUI

public enum SheetDestination: Hashable, Identifiable {
  public var id: Int { self.hashValue }

  case auth
  case fullScreenMedia(
    images: [URL],
    preloadedImage: URL?,
    namespace: Namespace.ID)
}
