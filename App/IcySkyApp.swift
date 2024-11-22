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
  
  @State var isAUthPresented = false

  var body: some Scene {
    @Bindable var router = router
    
    WindowGroup {
      ScrollView(.horizontal) {
        if let client, let currentUser {
          LazyHStack {
            ForEach(AppTab.allCases) { tab in
              AppTabRootView(tab: tab)
                .id(tab)
            }
          }
          .scrollTargetLayout()
          .environment(client)
          .environment(currentUser)
          .environment(auth)
          .environment(router)
        } else {
          ProgressView()
            .containerRelativeFrame([.horizontal, .vertical])
        }
      }
      .sheet(isPresented: $isAUthPresented) {
        AuthView()
          .environment(auth)
      }
      .task {
        if await auth.refresh() == nil {
          isAUthPresented = true
        }
      }
      .onChange(of: auth.session) { old, new in
        if let newSession = new {
          refreshEnvWith(session: newSession)
          isAUthPresented = false
        } else if old != nil && new == nil {
          isAUthPresented = true
        }
      }
      .ignoresSafeArea(.keyboard, edges: .all)
      .scrollDisabled(router.selectedTabPath.isEmpty == false)
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: $router.selectedTab)
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
            }
          }
        }
      )
    }
  }

  private func refreshEnvWith(session: UserSession) {
    let client = BSkyClient(session: session, protoClient: ATProtoKit(session: session))
    self.client = client
    self.currentUser = CurrentUser(client: client)
  }
}
