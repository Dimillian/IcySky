import Foundation
import Models

enum PostsListViewState {
  case uninitialized
  case loading
  case loaded(posts: [PostItem], cursor: String?)
  case error(Error)
}
