import Models
import SwiftUI

public enum RouterDestination: Hashable {
  case feed(FeedItem)
  case post(PostItem)
}
