import SwiftUI

@Observable
@MainActor
public final class Router {
  private var paths: [AppTab: [RouterDestination]] = [:]
  public subscript(tab: AppTab) -> [RouterDestination] {
    get { paths[tab] ?? [] }
    set { paths[tab] = newValue }
  }

  public var selectedTab: AppTab = .feed

  public var presentedSheet: SheetDestination?

  public init() {}

  public var selectedTabPath: [RouterDestination] {
    paths[selectedTab] ?? []
  }

  public func popToRoot(for tab: AppTab? = nil) {
    paths[tab ?? selectedTab] = []
  }

  public func popNavigation(for tab: AppTab? = nil) {
    paths[tab ?? selectedTab]?.removeLast()
  }

  public func navigateTo(_ destination: RouterDestination, for tab: AppTab? = nil) {
    if paths[tab ?? selectedTab] == nil {
      paths[tab ?? selectedTab] = [destination]
    } else {
      paths[tab ?? selectedTab]?.append(destination)
    }
  }
}
