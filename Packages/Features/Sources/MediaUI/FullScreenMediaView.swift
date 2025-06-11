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
  @State private var isOverlayVisible: Bool = false
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
    .overlay(alignment: .topTrailing) {
      topActionsView
    }
    .overlay(alignment: .bottom) {
      bottomActionsView
    }
    .scrollContentBackground(.hidden)
    .scrollTargetBehavior(.viewAligned)
    .navigationTransition(.zoom(sourceID: images[0].id, in: namespace))
    .containerBackground(.clear, for: .navigation)
    .background(.clear)
    .toolbarBackground(.clear, for: .navigationBar)
    .onTapGesture {
      withAnimation {
        isOverlayVisible.toggle()
      }
    }
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

  private var topActionsView: some View {
    HStack {
      if isOverlayVisible {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .padding()
        }
        .buttonStyle(.glass)
        .foregroundColor(.indigo)
        .padding(.trailing, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }

  private var bottomActionsView: some View {
    HStack(spacing: 16) {
      if isOverlayVisible {
        saveButton
        shareButton
      }
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
      if isSaved {
        Label("Saved", systemImage: "checkmark")
          .padding()
      } else {
        Label("Save", systemImage: "square.and.arrow.down")
          .padding()
      }
    }
    .foregroundColor(.indigo)
    .buttonStyle(.glass)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }

  @ViewBuilder
  private var shareButton: some View {
    if let imageURL = scrollPosition?.url {
      ShareLink(item: imageURL) {
        Label("Share", systemImage: "square.and.arrow.up")
          .padding()
      }
      .foregroundColor(.indigo)
      .buttonStyle(.glass)
      .transition(.move(edge: .bottom).combined(with: .opacity))
    }
  }
}
