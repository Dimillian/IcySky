import AppRouter
import Models
import SwiftUI

public enum ComposerDestinationMode: Hashable {
  case newPost
  case reply(PostItem)
}

public enum SheetDestination: SheetType, Hashable, Identifiable {
  public var id: Int { self.hashValue }

  case auth
  case fullScreenMedia(
    images: [Media],
    preloadedImage: URL?,
    namespace: Namespace.ID)
  case composer(mode: ComposerDestinationMode)
}
