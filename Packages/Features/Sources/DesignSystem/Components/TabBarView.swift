import SwiftUI

public enum AppTab: String, CaseIterable, Identifiable, Hashable {
  case feed, notification, messages, profile, settings

  public var id: String { rawValue }

  public var icon: String {
    switch self {
    case .feed: return "square.stack"
    case .notification: return "bell"
    case .messages: return "message"
    case .profile: return "person"
    case .settings: return "gearshape"
    }
  }
}

public struct TabBarView: View {
  @Binding var selectedtab: AppTab?

  public init(selectedtab: Binding<AppTab?>) {
    _selectedtab = selectedtab
  }

  public var body: some View {
    HStack(spacing: 32) {
      ForEach(AppTab.allCases, id: \.rawValue) { tab in
        Button {
          withAnimation {
            selectedtab = tab
          }
        } label: {
          Image(systemName: tab.icon)
            .symbolRenderingMode(.palette)
            .symbolVariant(selectedtab == tab ? .fill : .none)
            .symbolEffect(
              .bounce,
              options: .repeat(selectedtab == tab ? 1 : 0),
              value: selectedtab
            )
            .imageScale(.medium)
            .foregroundStyle(
              .linearGradient(
                colors: selectedtab == tab ? [.indigo, .purple] : [.indigo, .secondary],
                startPoint: .top, endPoint: .bottom)
            )
            .shadow(color: selectedtab == tab ? .indigo : .clear, radius: 1, x: 0, y: 0)
        }
      }
    }
    .padding()
    .pillStyle(material: .regular)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  TabBarView(selectedtab: .constant(.feed))
    .padding()
    .environment(\.colorScheme, .light)

  TabBarView(selectedtab: .constant(.feed))
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
}
