import Models
import SwiftUI

public enum RouterDestination: Hashable {
  case feed(FeedItem)
  case post(PostItem)
  case profile(Profile)
  case profilePosts(profile: Profile, filter: PostsProfileViewFilter)
  case profileLikes(Profile)
  case timeline
}
