import Models
import SwiftUI

public struct PostRowBodyView: View {
  @Environment(\.isFocused) private var isFocused

  let post: PostItem

  public init(post: PostItem) {
    self.post = post
  }

  public var body: some View {
    Text(post.content)
      .font(isFocused ? .system(size: UIFontMetrics.default.scaledValue(for: 20)) : .body)
  }
}
