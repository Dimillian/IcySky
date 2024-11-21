@preconcurrency import ATProtoKit
import DesignSystem
import Network
import SwiftUI
import VariableBlur
import Models

public struct FeedsListView: View {
  @Environment(BSkyClient.self) var client

  @State var feeds: [Feed] = []
  
  public init() { }

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
      do {
        let feeds = try await client.protoClient.getSuggestedFeeds()
        self.feeds = feeds.feeds.map { $0.feedItem }
      } catch {
        print(error)
      }
    }
  }

  private var headerView: some View {
    HStack(alignment: .center) {
      Menu {
        Button(action: { }, label: { Text("Discover") })
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
      Button(action: {}) {
        Label("Search", systemImage: "magnifyingglass")
          .padding(.horizontal, 18)
          .padding(.vertical, 8)
          .foregroundStyle(.secondary)
      }
      .buttonStyle(.pill)
    }
  }
}

#Preview {
  FeedsListView()
    .environment(BSkyClient.preview())
}
