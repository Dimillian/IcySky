@preconcurrency import ATProtoKit
import DesignSystem
import Models
import Network
import SwiftUI
import VariableBlur

public struct FeedsListView: View {
  @Environment(BSkyClient.self) var client

  @State var feeds: [Feed] = []

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
    .task {
      await fetchSuggestedFeed()
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
      HStack(alignment: .center) {
        Menu {
          Button(action: {}, label: { Text("Discover") })
        } label: {
          HStack {
            Text("Feeds")
              .foregroundStyle(
                .primary.shadow(
                  .inner(
                    color: .shadowSecondary.opacity(0.5),
                    radius: 1, x: -1, y: -1))
              )
              .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
              .font(.largeTitle)
              .fontWeight(.bold)
            Image(systemName: "chevron.up.chevron.down")
              .imageScale(.large)
          }
        }
        .buttonStyle(.plain)
        Spacer()
        Button(action: {
          isInSearch.toggle()
          isSearchFocused = true
        }) {
          Label("Search", systemImage: "magnifyingglass")
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.pill)
      }
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
              return
            }
            await searchFeed(query: searchText)
          }
        Button {
          isInSearch.toggle()
          isSearchFocused = false
          Task {
            await fetchSuggestedFeed()
          }
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
    } catch { }
  }
  
  private func searchFeed(query: String) async {
    do {
      try await Task.sleep(for: .milliseconds(250))
      let feeds = try await client.protoClient.getPopularFeedGenerators(matching: query)
      withAnimation {
        self.feeds = feeds.feeds.map { $0.feedItem }
      }
    } catch { }
  }
}

#Preview {
  FeedsListView()
    .environment(BSkyClient.preview())
}
