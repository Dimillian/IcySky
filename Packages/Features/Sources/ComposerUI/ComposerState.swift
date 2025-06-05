import Foundation

public enum ComposerSendState: Equatable {
  case idle
  case loading
  case error(String)
}