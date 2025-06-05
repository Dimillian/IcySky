import DesignSystem
import Destinations
import SwiftUI

struct AppTabView: View {
  @Environment(AppRouter.self) var router
  @State private var loadedTabs: Set<AppTab> = []

  let tabs: [AppTab] = AppTab.allCases

  var body: some View {
    ZStack {
      ForEach(Array(loadedTabs), id: \.id) { tab in
        AppTabRootView(tab: tab)
          .opacity(router.selectedTab == tab ? 1.0 : 0.0)
      }
    }
    .onAppear {
      loadedTabs.insert(router.selectedTab)
    }
    .onChange(of: router.selectedTab) { _, newTab in
      loadedTabs.insert(newTab)
    }
  }
}

#Preview {
  AppTabView()
    .environment(AppRouter(initialTab: .feed))
}
