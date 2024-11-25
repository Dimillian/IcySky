import Models
import SwiftUI

@MainActor
protocol PostsListViewDatasource {
  var title: String { get }
  func loadPosts(with state: PostsListViewState) async -> PostsListViewState
}
