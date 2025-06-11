import DesignSystem
import Foundation
import Models
import Nuke
import NukeUI
import SwiftUI

public struct FullScreenMediaView: View {
  @Environment(\.dismiss) private var dismiss

  let images: [Media]
  let preloadedImage: URL?
  let namespace: Namespace.ID

  @State private var isFirstImageLoaded: Bool = false
  @State private var isSaved: Bool = false
  @State private var scrollPosition: Media?
  @State private var isAltVisible: Bool = false

  @GestureState private var zoom = 1.0

  public init(images: [Media], preloadedImage: URL?, namespace: Namespace.ID) {
    self.images = images
    self.preloadedImage = preloadedImage
    self.namespace = namespace
  }

  var firstImageURL: URL? {
    if let preloadedImage, !isFirstImageLoaded {
      return preloadedImage
    }
    return images.first?.url
  }

  public var body: some View {
    NavigationStack {
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(images.indices, id: \.self) { index in
            LazyImage(
              request: .init(
                url: index == 0 ? firstImageURL : images[index].url,
                priority: .veryHigh)
            ) { state in
              if let image = state.image {
                image
                  .resizable()
                  .scaledToFill()
                  .aspectRatio(contentMode: .fit)
                  .scaleEffect(zoom)
                  .gesture(
                    MagnifyGesture()
                      .updating($zoom) { value, gestureState, transaction in
                        gestureState = value.magnification
                      }
                  )
              } else {
                RoundedRectangle(cornerRadius: 8)
                  .fill(.thinMaterial)
              }
            }
            .containerRelativeFrame([.horizontal, .vertical])
            .id(images[index])
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $scrollPosition)
      .toolbar {
        leadingToolbar
        trailingToolbar
      }
      .scrollContentBackground(.hidden)
      .scrollTargetBehavior(.viewAligned)
      .task {
        scrollPosition = images.first
        do {
          let data = try await ImagePipeline.shared.data(for: .init(url: images.first?.url))
          if !data.0.isEmpty {
            self.isFirstImageLoaded = true
          }
        } catch {}
      }
    }
    .navigationTransition(.zoom(sourceID: images[0].id, in: namespace))
  }

  private var leadingToolbar: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .foregroundStyle(.redPurple)
      }
    }
  }

  private var trailingToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      saveButton
      shareButton
    }
  }

  private var saveButton: some View {
    Button {
      Task {
        do {
          guard let imageURL = scrollPosition?.url else { return }
          let data = try await ImagePipeline.shared.data(for: .init(url: imageURL))
          if !data.0.isEmpty, let image = UIImage(data: data.0) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            withAnimation {
              isSaved = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              withAnimation {
                isSaved = false
              }
            }
          }
        } catch {}
      }
    } label: {
      Image(systemName: isSaved ? "checkmark" : "arrow.down.circle")
        .foregroundStyle(.indigoPurple)
    }
  }

  @ViewBuilder
  private var shareButton: some View {
    if let imageURL = scrollPosition?.url {
      ShareLink(item: imageURL) {
        Image(systemName: "square.and.arrow.up")
          .foregroundStyle(.indigoPurple)
      }
    }
  }
}
