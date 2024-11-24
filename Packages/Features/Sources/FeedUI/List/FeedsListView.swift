@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftUI
import User
import VariableBlur

public struct FeedsListView: View {
  @Environment(BSkyClient.self) var client
  @Environment(CurrentUser.self) var currentUser

  @State var feeds: [FeedItem] = []
  @State var filter: FeedsListFilter = .suggested

  @State var isInSearch: Bool = false
  @State var searchText: String = ""

  @State var error: Error?

  @FocusState var isSearchFocused: Bool

  public init() {}

  public var body: some View {
    List {
      headerView
        .listRowSeparator(.hidden)

      errorView

      ForEach(feeds) { feed in
        FeedRowView(feed: feed)
      }

    }
    .screenContainer()
    .task(id: filter) {
      guard !isInSearch else { return }
      switch filter {
      case .suggested:
        await fetchSuggestedFeed()
      case .savedFeeds, .pinned:
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
      guard !searchText.isEmpty else {
        return
      }
      await searchFeed(query: searchText)
    }
    .onChange(of: isInSearch, initial: false) {
      guard !isInSearch else { return }
      Task { await fetchSuggestedFeed() }
    }
  }

  @ViewBuilder
  private var errorView: some View {
    if let error {
      VStack {
        Text("Error: \(error.localizedDescription)")
          .foregroundColor(.red)
        Button {
          Task {
            await fetchSuggestedFeed()
          }
        } label: {
          Text("Retry")
            .padding()
        }
        .buttonStyle(.pill)
      }
      .listRowSeparator(.hidden)
    }
  }
}

extension FeedsListView {
  private func fetchSuggestedFeed() async {
    error = nil
    do {
      let feeds = try await client.protoClient.getSuggestedFeeds()
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {
      self.error = error
    }
  }

  private func fetchMyFeeds() async {
    guard let savedFeeds = currentUser.savedFeeds else { return }
    do {
      let feeds = try await client.protoClient.getFeedGenerators(
        filter == .savedFeeds ? savedFeeds.saved : savedFeeds.pinned)
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {}
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
