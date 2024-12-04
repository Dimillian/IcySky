import Models
import Network
import SwiftUI

extension EnvironmentValues {
  @Entry public var hideMoreActions = false
}

public struct PostRowActionsView: View {
  @Environment(\.hideMoreActions) var hideMoreActions
  @Environment(PostDataController.self) var dataController

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
        Label("\(dataController.repostCount)", systemImage: "quote.bubble")
          .contentTransition(.numericText(value: Double(dataController.repostCount)))
          .monospacedDigit()
          .lineLimit(1)
          .animation(.smooth, value: dataController.repostCount)
      }
      .buttonStyle(.plain)
      .symbolVariant(dataController.isReposted ? .fill : .none)
      .foregroundStyle(
        LinearGradient(
          colors: [.purple, .indigo],
          startPoint: .top,
          endPoint: .bottom
        )
      )

      Button(action: {
        Task {
          await dataController.toggleLike()
        }
      }) {
        Label("\(dataController.likeCount)", systemImage: "heart")
          .lineLimit(1)
      }
      .buttonStyle(.plain)
      .symbolVariant(dataController.isLiked ? .fill : .none)
      .symbolEffect(.bounce, value: dataController.isLiked)
      .contentTransition(.numericText(value: Double(dataController.likeCount)))
      .monospacedDigit()
      .animation(.smooth, value: dataController.likeCount)
      .foregroundStyle(
        LinearGradient(
          colors: [.red, .purple],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )

      Spacer()

      if !hideMoreActions {
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
    }
    .buttonStyle(.plain)
    .labelStyle(.customSpacing(4))
    .font(.callout)
    .padding(.top, 8)
    .padding(.bottom, 16)
  }
}
