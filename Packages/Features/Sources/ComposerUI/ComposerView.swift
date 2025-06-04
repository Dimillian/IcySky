import SwiftUI

public struct ComposerView: View {
  public init() {}

  public var body: some View {
    Text("Composer")
  }
}

#Preview {
  NavigationStack {
    
  }
  .sheet(isPresented: .constant(true)) {
    ComposerView()
  }
}
