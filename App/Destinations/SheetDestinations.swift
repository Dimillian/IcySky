import AppRouter
import Auth
import AuthUI
import ComposerUI
import Destinations
import MediaUI
import SwiftUI

public struct SheetDestinations: ViewModifier {
  @Binding var auth: Auth
  @Binding var router: AppRouter

  public func body(content: Content) -> some View {
    content
      .sheet(item: $router.presentedSheet) { presentedSheet in
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
  }
}

extension View {
  public func withSheetDestinations(auth: Binding<Auth>, router: Binding<AppRouter>) -> some View {
    modifier(SheetDestinations(auth: auth, router: router))
  }
}
