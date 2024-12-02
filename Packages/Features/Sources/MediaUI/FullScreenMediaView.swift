import Foundation
import Nuke
import NukeUI
import SwiftUI

public struct FullScreenMediaView: View {
  let images: [URL]
  let preloadedImage: URL?
  let namespace: Namespace.ID

  @State private var isFirstImageLoaded: Bool = false

  public init(images: [URL], preloadedImage: URL?, namespace: Namespace.ID) {
    self.images = images
    self.preloadedImage = preloadedImage
    self.namespace = namespace
  }

  var firstImageURL: URL? {
    if let preloadedImage, !isFirstImageLoaded {
      return preloadedImage
    }
    return images.first
  }

  public var body: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(images.indices, id: \.self) { index in
          LazyImage(url: index == 0 ? firstImageURL : images[index]) { state in
            if let image = state.image {
              image
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
            } else {
              RoundedRectangle(cornerRadius: 8)
                .fill(.thinMaterial)
            }
          }
          .containerRelativeFrame([.horizontal, .vertical])
        }
      }
      .scrollTargetLayout()
    }
    .scrollContentBackground(.hidden)
    .scrollTargetBehavior(.viewAligned)
    .navigationTransition(.zoom(sourceID: images[0], in: namespace))
    .task {
      do {
        let data = try await Nuke.ImagePipeline.shared.data(for: .init(url: images.first))
        if !data.0.isEmpty {
          self.isFirstImageLoaded = true
        }
      } catch {}
    }
  }
}
