import DesignSystem
import Destinations
import SwiftUI
import AppRouter

struct AppTabView: View {
  @Environment(AppRouter.self) var router
  let tabs: [AppTab] = AppTab.allCases

  var body: some View {
    @Bindable var router = router
    TabView(selection: $router.selectedTab) {
      ForEach(AppTab.allCases) { tab in
        Tab(value: tab, role: tab == .compose ? .search : .none) {
          AppTabRootView(tab: tab)
        } label: {
          Label(tab.title, systemImage: tab.icon)
        }
      }
    }
    .tint(.indigo)
    .tabBarMinimizeBehavior(.onScrollDown)
    .onChange(of: router.selectedTab, { oldTab, newTab in
      if newTab == .compose {
        router.presentedSheet = .composer(mode: .newPost)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          router.selectedTab = oldTab
        }
      }
    })
  }
}

#Preview {
  AppTabView()
    .environment(AppRouter(initialTab: .feed))
}
