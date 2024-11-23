import ATProtoKit
import Auth
import AuthUI
import DesignSystem
import Network
import Router
import SwiftUI
import User
import VariableBlur

@main
struct IcySkyApp: App {
  @State var client: BSkyClient?
  @State var auth: Auth = .init()
  @State var currentUser: CurrentUser?
  @State var router: Router = .init()
  
  var body: some Scene {
    @Bindable var router = router
    
    WindowGroup {
      TabView(selection: $router.selectedTab) {
        if client != nil && currentUser != nil {
          ForEach(AppTab.allCases) { tab in
            AppTabRootView(tab: tab)
              .tag(tab)
              .toolbarVisibility(.hidden, for: .tabBar)
          }
        } else {
          ProgressView()
            .containerRelativeFrame([.horizontal, .vertical])
        }
      }
      .environment(client)
      .environment(currentUser)
      .environment(auth)
      .environment(router)
      .sheet(item: $router.presentedSheet, content: { presentedSheet in
        switch presentedSheet {
        case .auth:
          AuthView()
            .environment(auth)
        }
      })
      .task {
        if await auth.refresh() == nil {
          router.presentedSheet = .auth
        }
      }
      .onChange(of: auth.session) { old, new in
        if let newSession = new {
          refreshEnvWith(session: newSession)
          router.presentedSheet = nil
        } else if old != nil && new == nil {
          router.presentedSheet = .auth
        }
      }
      .overlay(
        alignment: .top,
        content: {
          VariableBlurView(
            maxBlurRadius: 10,
            direction: .blurredTopClearBottom
          )
          .frame(height: 70)
          .ignoresSafeArea()
        }
      )
      .overlay(
        alignment: .bottom,
        content: {
          ZStack(alignment: .center) {
            VariableBlurView(
              maxBlurRadius: 10,
              direction: .blurredBottomClearTop
            )
            .frame(height: 100)
            .offset(y: 40)
            .ignoresSafeArea()

            if client != nil {
              TabBarView()
                .environment(router)
                .ignoresSafeArea(.keyboard)
            }
          }
        }
      )
      .ignoresSafeArea(.keyboard)
    }
  }

  private func refreshEnvWith(session: UserSession) {
    let client = BSkyClient(session: session, protoClient: ATProtoKit(session: session))
    self.client = client
    self.currentUser = CurrentUser(client: client)
  }
}
