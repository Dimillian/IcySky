import SwiftUI

@Observable
@MainActor
public final class Router {
  private var paths: [AppTab: [RouterDestination]] = [:]
  public subscript(tab: AppTab) -> [RouterDestination] {
    get { paths[tab] ?? [] }
    set { paths[tab] = newValue }
  }
  
  public var selectedTab: AppTab? = .feed

  public init() {}
  
  public var selectedTabPath: [RouterDestination] {
    paths[selectedTab ?? .feed] ?? []
  }

  public func popToRoot(for tab: AppTab? = nil) {
    paths[tab ?? selectedTab ?? .feed] = []
  }

  public func popNavigation(for tab: AppTab? = nil) {
    paths[tab ?? selectedTab ?? .feed]?.removeLast()
  }

  public func navigateTo(_ destination: RouterDestination, for tab: AppTab? = nil) {
    paths[tab ?? selectedTab ?? .feed]?.append(destination)
  }
}
