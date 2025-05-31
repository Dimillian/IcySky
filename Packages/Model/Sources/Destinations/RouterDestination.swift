import AppRouter
import Models
import SwiftUI

public enum RouterDestination: DestinationType, Hashable {
  public static func from(path: String, fullPath: [String], parameters: [String : String]) -> RouterDestination? {
    nil
  }

  case feed(FeedItem)
  case post(PostItem)
  case profile(Profile)
  case profilePosts(profile: Profile, filter: PostsProfileViewFilter)
  case profileLikes(Profile)
  case timeline
}
