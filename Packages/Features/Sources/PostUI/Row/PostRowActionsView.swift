import Models
import SwiftUI

public struct PostRowActionsView: View {
  let post: PostItem

  public init(post: PostItem) {
    self.post = post
  }

  public var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 16) {
      Button(action: {}) {
        Label("\(post.replyCount)", systemImage: "bubble")
      }
      .buttonStyle(.plain)
      .foregroundStyle(
        LinearGradient(
          colors: [.indigo, .purple],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      Button(action: {}) {
        Label("\(post.repostCount)", systemImage: "quote.bubble")
      }
      .buttonStyle(.plain)
      .symbolVariant(post.isReposted ? .fill : .none)
      .foregroundStyle(
        LinearGradient(
          colors: [.purple, .indigo],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      Button(action: {}) {
        Label("\(post.likeCount)", systemImage: "heart")
      }
      .buttonStyle(.plain)
      .symbolVariant(post.isLiked ? .fill : .none)
      .foregroundStyle(
        LinearGradient(
          colors: [.red, .purple],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )

      Spacer()

      Button(action: {}) {
        Image(systemName: "ellipsis")
      }
      .buttonStyle(.plain)
      .foregroundStyle(
        LinearGradient(
          colors: [.indigo, .purple],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
    }
    .buttonStyle(.plain)
    .labelStyle(.customSpacing(4))
    .font(.callout)
    .padding(.top, 8)
    .padding(.bottom, 16)
  }
}
