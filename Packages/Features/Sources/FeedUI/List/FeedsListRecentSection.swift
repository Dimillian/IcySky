import Models
import SwiftData
import SwiftUI

struct FeedsListRecentSection: View {
  @Environment(\.modelContext) var modelContext

  @Binding var isRecentFeedExpanded: Bool

  @Query(recentFeedItemsDescriptor) var recentFeedItems: [RecentFeedItem]

  var body: some View {
    HStack {
      Image(systemName: "chevron.right")
        .rotationEffect(.degrees(isRecentFeedExpanded ? 90 : 0))
      Text("Recently Viewed")
    }
    .font(.subheadline)
    .fontWeight(.semibold)
    .foregroundStyle(.secondary)
    .listRowSeparator(.hidden)
    .onTapGesture {
      withAnimation {
        isRecentFeedExpanded.toggle()
      }
    }

    if isRecentFeedExpanded {
      Section {
        TimelineFeedRowView()
        ForEach(recentFeedItems) { item in
          RecentlyViewedFeedRowView(item: item)
        }
        .onDelete { indexSet in
          for index in indexSet {
            modelContext.delete(recentFeedItems[index])
          }
        }
        FeedsListDividerView()
      }
    }
  }
}

// MARK: - SwiftData
extension FeedsListRecentSection {
  static var recentFeedItemsDescriptor: FetchDescriptor<RecentFeedItem> {
    var descriptor = FetchDescriptor<RecentFeedItem>(sortBy: [
      SortDescriptor(\.lastViewedAt, order: .reverse)
    ]
    )
    descriptor.fetchLimit = 4
    return descriptor
  }
}
