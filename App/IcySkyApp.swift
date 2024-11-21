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
  @State var currentUser: CurrentUser?
  @State var selectedTab: AppTab? = .feed
  @State var isAUthPresented = false
  @State var paths: [AppTab: [RouterDestination]] = [:]

  var body: some Scene {
    WindowGroup {
      ScrollView(.horizontal) {
        if let client, let currentUser {
          LazyHStack {
            ForEach(AppTab.allCases) { tab in
              AppTabRootView(
                tab: tab,
                path: .init(
                  get: { paths[tab] ?? [] },
                  set: { paths[tab] = $0 })
              )
              .id(tab)
            }
          }
          .scrollTargetLayout()
          .environment(client)
          .environment(currentUser)
        } else {
          ProgressView()
            .containerRelativeFrame([.horizontal, .vertical])
        }
      }
      .ignoresSafeArea(.keyboard, edges: .all)
      .scrollDisabled(paths[selectedTab ?? .feed]?.isEmpty == false)
      .sheet(isPresented: $isAUthPresented) {
        AuthView { session in
          self.client = BSkyClient(session: session, protoClient: ATProtoKit(session: session))
          isAUthPresented = false
        }
      }
      .task {
        do {
          if let userSession = try await Auth().session {
            refreshEnvWith(session: userSession)
          } else {
            isAUthPresented = true
          }
        } catch {
          print(error)
        }
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: $selectedTab)
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

            TabBarView(
              selectedtab: $selectedTab,
              selectedTapPath: .init(
                get: { paths[selectedTab ?? .feed] ?? [] },
                set: { paths[selectedTab ?? .feed] = $0 }
              )
            )
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
