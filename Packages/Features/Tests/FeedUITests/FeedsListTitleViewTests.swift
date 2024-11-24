import FeedUI
import ViewInspector
import Testing
import SwiftUI

@MainActor
struct FeedsListTitleViewTests {
  @FocusState var isSearchFocused: Bool
  @State var filter: FeedsListFilter = .pinned
  
  @Test func testFeedTitleViewBase() throws {
    let view = FeedsListTitleView(filter: $filter,
                                  searchText: .constant(""),
                                  isInSearch: .constant(false),
                                  isSearchFocused: $isSearchFocused)
    #expect(try view.inspect().find(text: "Feeds").string() == "Feeds")
    #expect(try view.inspect().find(text: filter.rawValue).string() == FeedsListFilter.pinned.rawValue)
  }
}
