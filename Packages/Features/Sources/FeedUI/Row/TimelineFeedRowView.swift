import ATProtoKit
import AppRouter
import DesignSystem
import Destinations
import Models
import Client
import SwiftUI

struct TimelineFeedRowView: View {
  var body: some View {
    NavigationLink(value: RouterDestination.timeline) {
      HStack {
        Image(systemName: "clock")
          .imageScale(.medium)
          .foregroundStyle(.white)
          .frame(width: 32, height: 32)
          .background(RoundedRectangle(cornerRadius: 8).fill(Color.blueskyBackground))
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(color: .shadowPrimary.opacity(0.7), radius: 2)
        Text("Following")
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
