import ATProtoKit
import AppRouter
import Auth
import AuthUI
import ComposerUI
import DesignSystem
import Destinations
import MediaUI
import Models
import Network
import Nuke
import NukeUI
import SwiftUI
import User
import VariableBlur

@main
struct IcySkyApp: App {
  @Environment(\.scenePhase) var scenePhase

  @State var appState: AppState = .resuming
  @State var auth: Auth = .init()
  @State var router: AppRouter = .init(initialTab: .feed)
  @State var postDataControllerProvider: PostContextProvider = .init()

  init() {
    ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
  }

  var body: some Scene {
    WindowGroup {
      Group {
        switch appState {
        case .resuming:
          ProgressView()
            .containerRelativeFrame([.horizontal, .vertical])
        case .authenticated(let client, let currentUser):
          TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
              AppTabRootView(tab: tab)
                .tag(tab)
                .toolbarVisibility(.hidden, for: .tabBar)
            }
          }
          .environment(client)
          .environment(currentUser)
          .environment(auth)
          .environment(router)
          .environment(postDataControllerProvider)
        case .unauthenticated:
          Text("Unauthenticated")
        case .error(let error):
          Text("Error: \(error.localizedDescription)")
        }
      }
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
          case .composer:
            ComposerView()
          }
        }
      )
      .task(id: scenePhase) {
        if scenePhase == .active {
          await auth.refresh()
        }
      }
      .task {
        for await configuration in auth.configurationUpdates {
          if let configuration {
            router.presentedSheet = nil
            await refreshEnvWith(configuration: configuration)
          } else {
            appState = .unauthenticated
            router.presentedSheet = .auth
          }
        }
      }
      .overlay(
        alignment: .top,
        content: {
          if case .authenticated = appState {
            topFrostView
          }
        }
      )
      .overlay(
        alignment: .bottom,
        content: {
          ZStack(alignment: .center) {
            if case .authenticated = appState {
              bottomFrostView
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

  private func refreshEnvWith(configuration: ATProtocolConfiguration) async {
    do {
      let client = await BSkyClient(configuration: configuration)
      let currentUser = try await CurrentUser(client: client)
      appState = .authenticated(client: client, currentUser: currentUser)
    } catch {
      appState = .error(error)
    }
  }
}
