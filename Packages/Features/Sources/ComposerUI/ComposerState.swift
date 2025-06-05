import Foundation
import Models

public enum ComposerMode: Equatable {
  case newPost
  case reply(PostItem)
}

public enum ComposerSendState: Equatable {
  case idle
  case loading
  case error(String)
}
