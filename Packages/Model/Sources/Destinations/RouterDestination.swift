import Models
import SwiftUI
import AppRouter

public enum RouterDestination: DestinationType, Hashable {
  public static func from(path: String, parameters: [String : String]) -> RouterDestination? {
    nil
  }
  
  case feed(FeedItem)
  case post(PostItem)
  case profile(Profile)
  case profilePosts(profile: Profile, filter: PostsProfileViewFilter)
  case profileLikes(Profile)
  case timeline
}
