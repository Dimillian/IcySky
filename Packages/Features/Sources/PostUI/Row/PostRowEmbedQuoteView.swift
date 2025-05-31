import AppRouter
import Destinations
import Models
import SwiftUI

struct PostRowEmbedQuoteView: View {
  @Environment(\.currentTab) var currentTab
  @Environment(AppRouter.self) var router

  let post: PostItem

  var body: some View {
    PostRowView(post: post)
      .environment(\.isQuote, true)
      .padding(8)
      .background(.thinMaterial)
      .overlay {
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            LinearGradient(
              colors: [.shadowPrimary.opacity(0.5), .indigo.opacity(0.5)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing),
            lineWidth: 1
          )
          .shadow(color: .shadowPrimary.opacity(0.3), radius: 1)
      }
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .shadow(color: .indigo.opacity(0.3), radius: 2)
      .onTapGesture {
        router.navigateTo(.post(post))
      }
  }
}
