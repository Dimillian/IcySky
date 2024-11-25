import SwiftUI

struct FeedsListDividerView: View {
  var body: some View {
    HStack {
      Rectangle()
        .fill(
          LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .leading,
            endPoint: .trailing)
        )
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
    .listRowSeparator(.hidden)
    .listRowInsets(.init())
  }
}
