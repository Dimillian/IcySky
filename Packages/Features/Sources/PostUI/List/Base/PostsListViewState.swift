import Foundation
import Models

enum PostsListViewState: Sendable {
  case uninitialized
  case loading
  case loaded(posts: [PostItem], cursor: String?)
  case error(Error)
}
