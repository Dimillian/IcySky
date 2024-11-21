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

  @FocusState var isSearchFocused: Bool

  public init() {}

  public var body: some View {
    List {
      headerView
        .listRowSeparator(.hidden)

      ForEach(feeds) { feed in
        FeedRowView(feed: feed)
      }
    }
    .listStyle(.plain)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarVisibility(.hidden, for: .navigationBar)
    .scrollContentBackground(.hidden)
    .onChange(of: filter, initial: true) {
      switch filter {
      case .suggested:
        Task { await fetchSuggestedFeed() }
      case .myFeeds:
        Task { await fetchMyFeeds() }
      }
    }
  }

  private var headerView: some View {
    ZStack(alignment: .center) {
      searchFieldView
        .transition(.push(from: .leading).combined(with: .opacity))
      titleView
        .transition(.push(from: .trailing).combined(with: .opacity))
    }
    .animation(.smooth, value: isInSearch)
  }

  @ViewBuilder
  private var titleView: some View {
    if !isInSearch {
      FeedsListTitleView(
        filter: $filter,
        isInSearch: $isInSearch,
        isSearchFocused: $isSearchFocused
      )
    }
  }

  @ViewBuilder
  private var searchFieldView: some View {
    if isInSearch {
      HStack(alignment: .center) {
        TextField("Search feeds", text: $searchText)
          .focused($isSearchFocused)
          .padding()
          .pillStyle()
          .task(id: searchText) {
            guard !searchText.isEmpty else {
              await fetchSuggestedFeed()
              return
            }
            await searchFeed(query: searchText)
          }
        Button {
          isInSearch.toggle()
          isSearchFocused = false
        } label: {
          Image(systemName: "xmark")
            .padding()
        }
        .buttonStyle(.pill)
      }
    }
  }

  private func fetchSuggestedFeed() async {
    do {
      let feeds = try await client.protoClient.getSuggestedFeeds()
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {}
  }

  private func fetchMyFeeds() async {
    guard let preferences = currentUser.preferences else { return }
    switch preferences {
    case .savedFeeds(let definition):
      let feedURI = definition.pinned
      do {
        let feeds = try await client.protoClient.getFeedGenerators(feedURI)
        withAnimation {
          self.feeds = feeds.feeds.map { $0.feedItem }
        }
      } catch {}
    default:
      break
    }
  }

  private func searchFeed(query: String) async {
    do {
      try await Task.sleep(for: .milliseconds(250))
      let feeds = try await client.protoClient.getPopularFeedGenerators(matching: query)
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch {}
  }
}

#Preview {
  FeedsListView()
    .environment(BSkyClient.preview())
}
