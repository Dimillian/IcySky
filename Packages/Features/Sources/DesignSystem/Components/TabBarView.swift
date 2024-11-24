import Router
import SwiftUI

public extension CGFloat {
  static let tabBarHeight: CGFloat = 70
}

public struct TabBarView: View {
  @Environment(Router.self) var router

  public init() {}

  public var body: some View {
    ZStack(alignment: .center) {
      backButtonView
      tabbarView
    }
  }

  private var backButtonView: some View {
    Button {
      router[router.selectedTab].removeLast()
    } label: {
      Image(systemName: "chevron.left")
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary)
        .imageScale(.medium)
        .foregroundStyle(
          .linearGradient(
            colors: [.indigo, .secondary],
            startPoint: .top, endPoint: .bottom)
        )
        .shadow(color: .clear, radius: 1, x: 0, y: 0)
        .frame(width: 50, height: 50)
    }
    .buttonStyle(.circle)
    .animation(.bouncy, value: router.selectedTabPath)
    .offset(x: router.selectedTabPath.isEmpty ? 0 : -164)
  }

  private var tabbarView: some View {
    HStack(spacing: 32) {
      ForEach(AppTab.allCases, id: \.rawValue) { tab in
        Button {
          withAnimation {
            if router.selectedTab == tab {
              router.popToRoot(for: tab)
            }
            router.selectedTab = tab
          }
        } label: {
          Image(systemName: tab.icon)
            .symbolRenderingMode(.palette)
            .symbolVariant(router.selectedTab == tab ? .fill : .none)
            .symbolEffect(
              .bounce,
              options: .repeat(router.selectedTab == tab ? 1 : 0),
              value: router.selectedTab
            )
            .imageScale(.medium)
            .foregroundStyle(
              .linearGradient(
                colors: router.selectedTab == tab ? [.indigo, .purple] : [.indigo, .secondary],
                startPoint: .top, endPoint: .bottom)
            )
            .shadow(color: router.selectedTab == tab ? .indigo : .clear, radius: 1, x: 0, y: 0)
        }
      }
    }
    .padding()
    .pillStyle(material: .regular)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  TabBarView()
    .padding()
    .environment(\.colorScheme, .light)
    .environment(Router())

  TabBarView()
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
    .environment(Router())
}
