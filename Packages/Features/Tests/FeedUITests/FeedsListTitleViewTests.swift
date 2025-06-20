import FeedUI
import SwiftUI
import Testing
import ViewInspector

struct FeedsListTitleViewTests {
  @FocusState var isSearchFocused: Bool
  @State var filter: FeedsListFilter = .myFeeds

  @Test func testFeedTitleViewBase() throws {
    let view = FeedsListTitleView(
      filter: $filter,
      searchText: .constant(""),
      isInSearch: .constant(false),
      isSearchFocused: $isSearchFocused)
    #expect(try view.inspect().find(text: "Feeds").string() == "Feeds")
    #expect(
      try view.inspect().find(text: filter.rawValue).string() == FeedsListFilter.myFeeds.rawValue)
  }
}
