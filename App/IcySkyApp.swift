import ATProtoKit
import Auth
import AuthUI
import DesignSystem
import Network
import SwiftUI
import User
import VariableBlur

@main
struct IcySkyApp: App {
  @State var client: BSkyClient?
  @State var currentUser: CurrentUser?
  @State var selectedTab: AppTab? = .feed
  @State var isAUthPresented = false

  var body: some Scene {
    WindowGroup {
      ScrollView(.horizontal) {
        if let client, let currentUser {
          LazyHStack {
            ForEach(AppTab.allCases) { tab in
              tab.rootView
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

            TabBarView(selectedtab: $selectedTab)
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
