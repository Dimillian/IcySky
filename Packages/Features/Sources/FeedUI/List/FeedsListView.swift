@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftUI
import User
import VariableBlur

public struct FeedsListView: View {
  @Environment(BSkyClient.self) var client
  @Environment(CurrentUser.self) var currentUser

  @State var feeds: [FeedItem] = []
  @State var filter: FeedsListFilter = .suggested

  @State var isRecentFeedExpanded: Bool = true

  @State var isInSearch: Bool = false
  @State var searchText: String = ""

  @State var error: Error?

  @FocusState var isSearchFocused: Bool

  public init() {}

  public var body: some View {
    List {
      headerView
      if let error {
        FeedsListErrorView(error: error) {
          await fetchSuggestedFeed()
        }
      }
      if !isInSearch {
        FeedsListRecentSection(isRecentFeedExpanded: $isRecentFeedExpanded)
      }
      feedsSection
    }
    .screenContainer()
    .scrollDismissesKeyboard(.immediately)
    .task(id: filter) {
      guard !isInSearch else { return }
      switch filter {
      case .suggested:
        await fetchSuggestedFeed()
      case .myFeeds:
        await fetchMyFeeds()
      }
    }
  }

  private var headerView: some View {
    FeedsListTitleView(
      filter: $filter,
      searchText: $searchText,
      isInSearch: $isInSearch,
      isSearchFocused: $isSearchFocused
    )
    .task(id: searchText) {
      guard !searchText.isEmpty else { return }
      await searchFeed(query: searchText)
    }
    .onChange(of: isInSearch, initial: false) {
      guard !isInSearch else { return }
      Task { await fetchSuggestedFeed() }
    }
    .onChange(of: currentUser.savedFeeds.count) {
      switch filter {
      case .suggested:
        feeds = feeds.filter { feed in
          !currentUser.savedFeeds.contains { $0.value == feed.uri }
        }
      case .myFeeds:
        Task { await fetchMyFeeds() }
      }
    }
    .listRowSeparator(.hidden)
  }

  private var feedsSection: some View {
    Section {
      ForEach(feeds) { feed in
        FeedRowView(feed: feed)
      }
    }
  }
}

// MARK: - Network
extension FeedsListView {
  private func fetchSuggestedFeed() async {
    error = nil
    do {
      let feeds = try await client.protoClient.getPopularFeedGenerators(matching: nil)
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }.filter { feed in
          !currentUser.savedFeeds.contains { $0.value == feed.uri }
        }
      }
    } catch {
      self.error = error
    }
  }

  private func fetchMyFeeds() async {
    do {
      let feeds = try await client.protoClient.getFeedGenerators(
        currentUser.savedFeeds.map { $0.value })
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {
      print(error)
    }
  }

  private func searchFeed(query: String) async {
    do {
      try await Task.sleep(for: .milliseconds(250))
      let feeds = try await client.protoClient.getPopularFeedGenerators(matching: query)
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {
      print(error)
    }
  }
}

#Preview {
  FeedsListView()
    .environment(BSkyClient.preview())
}
