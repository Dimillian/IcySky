import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftUI

struct RecentlyViewedFeedRowView: View {
  let item: RecentFeedItem

  var body: some View {
    NavigationLink(
      value: RouterDestination.feed(
        uri: item.uri,
        name: item.name,
        avatarImageURL: item.avatarImageURL
      )
    ) {
      HStack {
        AsyncImage(url: item.avatarImageURL) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .scaledToFit()
              .frame(width: 32, height: 32)
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
          default:
            RoundedRectangle(cornerRadius: 8)
              .fill(.gray.opacity(0.2))
              .frame(width: 32, height: 32)
              .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
          }
        }
        Text(item.name)
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(
            .primary.shadow(
              .inner(
                color: .shadowSecondary.opacity(0.5),
                radius: 2, x: -1, y: -1)))
      }
    }
    .listRowSeparator(.hidden)
  }
}
