import ATProtoKit
import DesignSystem
import Models
import Network
import Router
import SwiftUI

struct TimelineFeedRowView: View {
  var body: some View {
    NavigationLink(value: RouterDestination.timeline) {
      HStack {
        Image(systemName: "clock")
          .imageScale(.medium)
          .foregroundStyle(.white)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.blueskyBackground)
              .frame(width: 32, height: 32)
          )
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
