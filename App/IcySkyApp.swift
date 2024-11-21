import ATProtoKit
import DesignSystem
import Network
import SwiftUI
import VariableBlur
import Auth
import AuthUI

@main
struct IcySkyApp: App {
  @State var client: BSkyClient?
  @State var selectedTab: AppTab? = .feed
  @State var isAUthPresented = false
  
  var body: some Scene {
    WindowGroup {
      ScrollView(.horizontal) {
        if let client {
          LazyHStack {
            ForEach(AppTab.allCases) { tab in
              tab.rootView
                .id(tab)
            }
          }
          .scrollTargetLayout()
          .environment(client)
        } else {
          ProgressView()
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
            self.client = BSkyClient(session: userSession, protoClient: ATProtoKit(session: userSession))
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
}
