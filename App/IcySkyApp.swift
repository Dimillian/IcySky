import ATProtoKit
import AppRouter
import Auth
import DesignSystem
import Destinations
import Models
import Network
import Nuke
import NukeUI
import SwiftUI
import User

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
          AppTabView()
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
      .withSheetDestinations(
        router: $router,
        auth: auth,
        client: appState.client,
        currentUser: appState.currentUser
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
