import DesignSystem
import Destinations
import SwiftUI

struct AppTabView: View {
  @Environment(AppRouter.self) var router

  let tabs: [AppTab] = AppTab.allCases

  var body: some View {
    ZStack {
      ForEach(tabs, id: \.id) { tab in
        AppTabRootView(tab: tab)
          .opacity(router.selectedTab == tab ? 1.0 : 0.0)
      }
    }
  }
}

#Preview {
  AppTabView()
    .environment(AppRouter(initialTab: .feed))
}
