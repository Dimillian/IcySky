import ATProtoKit
import AppRouter
import DesignSystem
import Destinations
import Models
import Client
import SwiftUI

struct FeedCompactRowView: View {
  let title: String
  let image: String
  let destination: RouterDestination

  var body: some View {
    NavigationLink(value: destination) {
      HStack {
        Image(systemName: image)
          .imageScale(.medium)
          .foregroundStyle(.white)
          .frame(width: 32, height: 32)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color.blueskyBackground))
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
        VStack(alignment: .leading) {
          Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(
              .primary.shadow(
                .inner(
                  color: .shadowSecondary.opacity(0.5),
                  radius: 2, x: -1, y: -1)))
        }
      }
      .padding(.vertical, 12)
    }
    .listRowSeparator(.hidden)
  }
}

#Preview {
  NavigationStack {
    List {
      FeedCompactRowView(
        title: "Following",
        image: "clock",
        destination: .timeline
      )
    }
    .listStyle(.plain)
  }
}
