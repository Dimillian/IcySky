import DesignSystem
import SwiftUI

struct FeedsListErrorView: View {
  let error: Error
  let retry: () async -> Void

  var body: some View {
    VStack {
      Text("Error: \(error.localizedDescription)")
        .foregroundColor(.red)
      Button {
        Task {
          await retry()
        }
      } label: {
        Text("Retry")
          .padding()
      }
      .buttonStyle(.glass)
    }
    .listRowSeparator(.hidden)
  }
}
