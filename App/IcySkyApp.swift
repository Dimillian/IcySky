import ATProtoKit
import Auth
import AuthUI
import DesignSystem
import MediaUI
import Models
import Network
import Nuke
import NukeUI
import Router
import SwiftUI
import User
import VariableBlur

@main
struct IcySkyApp: App {
  @Environment(\.scenePhase) var scenePhase

  @State var client: BSkyClient?
  @State var auth: Auth = .init()
  @State var currentUser: CurrentUser?
  @State var router: Router = .init()
  @State var isLoadingInitialSession: Bool = true
  @State var postDataControllerProvider: PostDataControllerProvider = .init()

  init() {
    ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
  }

  var body: some Scene {
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
      .environment(postDataControllerProvider)
      .modelContainer(for: RecentFeedItem.self)
      .sheet(
        item: $router.presentedSheet,
        content: { presentedSheet in
          switch presentedSheet {
          case .auth:
            AuthView()
              .environment(auth)
          case let .fullScreenMedia(images, preloadedImage, namespace):
            FullScreenMediaView(
              images: images,
              preloadedImage: preloadedImage,
              namespace: namespace
            )
          }
        }
      )
      .task(id: auth.session) {
        if let newSession = auth.session {
          await refreshEnvWith(session: newSession)
          if router.presentedSheet == .auth {
            router.presentedSheet = nil
          }
        } else if auth.session == nil && !isLoadingInitialSession {
          router.presentedSheet = .auth
        }
        isLoadingInitialSession = false
      }
      .task(id: scenePhase) {
        if scenePhase == .active {
          await auth.refresh()
          if auth.session == nil {
            router.presentedSheet = .auth
          }
        }
      }
      .overlay(
        alignment: .top,
        content: {
          topFrostView
        }
      )
      .overlay(
        alignment: .bottom,
        content: {
          ZStack(alignment: .center) {
            bottomFrostView

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

  private var topFrostView: some View {
    VariableBlurView(
      maxBlurRadius: 10,
      direction: .blurredTopClearBottom
    )
    .frame(height: 70)
    .ignoresSafeArea()
    .overlay(alignment: .top) {
      LinearGradient(
        colors: [.purple.opacity(0.07), .indigo.opacity(0.07), .clear],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 70)
      .ignoresSafeArea()
    }
  }

  private var bottomFrostView: some View {
    VariableBlurView(
      maxBlurRadius: 10,
      direction: .blurredBottomClearTop
    )
    .frame(height: 100)
    .offset(y: 40)
    .ignoresSafeArea()
    .overlay(alignment: .bottom) {
      LinearGradient(
        colors: [.purple.opacity(0.07), .indigo.opacity(0.07), .clear],
        startPoint: .bottom,
        endPoint: .top
      )
      .frame(height: 100)
      .offset(y: 40)
      .ignoresSafeArea()
    }
  }

  private func refreshEnvWith(session: UserSession) async {
    let client = BSkyClient(session: session)
    self.client = client
    self.currentUser = await CurrentUser(client: client)
  }
}
