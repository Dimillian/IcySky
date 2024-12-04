import Models
import SwiftUI

public enum RouterDestination: Hashable {
  case feed(uri: String, name: String, avatarImageURL: URL?)
  case post(PostItem)
  case profile(Profile)
  case timeline
}
