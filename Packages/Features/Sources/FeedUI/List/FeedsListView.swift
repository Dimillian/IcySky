@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftData
import SwiftUI
import User
import VariableBlur

public struct FeedsListView: View {
  @Environment(BSkyClient.self) var client
  @Environment(CurrentUser.self) var currentUser
  @Environment(\.modelContext) var modelContext

  @State var feeds: [FeedItem] = []
  @State var filter: FeedsListFilter = .suggested

  @State var isRecentFeedExpanded: Bool = true
  @Query(recentFeedItemsDescriptor) var recentFeedItems: [RecentFeedItem]

  @State var isInSearch: Bool = false
  @State var searchText: String = ""

  @State var error: Error?

  @FocusState var isSearchFocused: Bool

  public init() {}

  public var body: some View {
    List {
      headerView
      errorView
      recentViewedSection
      feedsSection
    }
    .screenContainer()
    .scrollDismissesKeyboard(.immediately)
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
    .listRowSeparator(.hidden)
  }

  @ViewBuilder
  private var recentViewedSection: some View {
    if !isInSearch {
      Section(
        content: {
          if isRecentFeedExpanded {
            TimelineFeedRowView()
            ForEach(recentFeedItems) { item in
              RecentlyViewedFeedRowView(item: item)
            }
            .onDelete { indexSet in
              for index in indexSet {
                modelContext.delete(recentFeedItems[index])
              }
            }
            dividerView
          }
        },
        header: {
          Label(
            "Recently Viewed",
            systemImage: isRecentFeedExpanded ? "chevron.down" : "chevron.right"
          )
          .onTapGesture {
            withAnimation {
              isRecentFeedExpanded.toggle()
            }
          }
        }
      )
    }
  }

  private var feedsSection: some View {
    Section {
      ForEach(feeds) { feed in
        FeedRowView(feed: feed)
      }
    }
  }

  private var dividerView: some View {
    HStack {
      Rectangle()
        .fill(
          LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .leading,
            endPoint: .trailing)
        )
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
    .listRowSeparator(.hidden)
    .listRowInsets(.init())
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

// MARK: - SwiftData
extension FeedsListView {
  static var recentFeedItemsDescriptor: FetchDescriptor<RecentFeedItem> {
    var descriptor = FetchDescriptor<RecentFeedItem>(sortBy: [
      SortDescriptor(\.lastViewedAt, order: .reverse)
    ]
    )
    descriptor.fetchLimit = 4
    return descriptor
  }
}

// MARK: - Network
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
