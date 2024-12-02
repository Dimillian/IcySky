import ATProtoKit
import DesignSystem
import Models
import NukeUI
import Router
import SwiftUI

struct PostRowImagesView: View {
  @Environment(\.isQuote) var isQuote
  @Environment(Router.self) var router

  @Namespace private var namespace

  let quoteMaxSize: CGFloat = 100
  let images: AppBskyLexicon.Embed.ImagesDefinition.View

  @State private var firstImageSize: CGSize?
  @State private var isMediaExpanded: Bool = false
  @State private var shouldRotate = true

  var body: some View {
    ZStack(alignment: .topLeading) {
      ForEach(images.images.indices.reversed(), id: \.self) { index in
        makeImageView(image: images.images[index], index: index)
          .frame(maxWidth: isQuote ? quoteMaxSize : nil)
          .rotationEffect(
            index == images.images.indices.first
              ? .degrees(0) : .degrees(shouldRotate ? Double(index) * -2 : 0),
            anchor: .bottomTrailing
          )
      }
    }
    .padding(.bottom, images.images.count > 1 && !isQuote ? CGFloat(images.images.count) * 7 : 0)
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.1)) {
        shouldRotate = false
      } completion: {
        router.presentedSheet = .fullScreenMedia(
          images: images.images.map { .init(url: $0.fullSizeImageURL, alt: $0.altText) },
          preloadedImage: images.images.first?.thumbnailImageURL,
          namespace: namespace
        )
      }
    }
    .onChange(of: router.presentedSheet) {
      if router.presentedSheet == nil {
        withAnimation(.bouncy) {
          shouldRotate = true
        }
      }
    }
  }

  @ViewBuilder
  private func makeImageView(image: AppBskyLexicon.Embed.ImagesDefinition.ViewImage, index: Int)
    -> some View
  {
    let width: CGFloat = CGFloat(image.aspectRatio?.width ?? 300)
    let height: CGFloat = CGFloat(image.aspectRatio?.height ?? 200)
    GeometryReader { geometry in
      let displayWidth = isQuote ? quoteMaxSize : min(geometry.size.width, width)
      let displayHeight = isQuote ? quoteMaxSize : displayWidth / (width / height)
      let finalWidth = firstImageSize?.width ?? displayWidth
      let finalHeight = firstImageSize?.height ?? displayHeight
      LazyImage(url: image.thumbnailImageURL) { state in
        if let image = state.image {
          image
            .resizable()
            .scaledToFill()
            .aspectRatio(contentMode: index == images.images.indices.first ? .fit : .fill)
            .clipped()
        } else {
          RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
        }
      }
      .processors([.resize(size: .init(width: finalWidth, height: finalHeight))])
      .frame(width: finalWidth, height: finalHeight)
      .matchedTransitionSource(id: image.fullSizeImageURL, in: namespace)
      .glowingRoundedRectangle()
      .shadow(color: images.images.count > 1 ? .black.opacity(0.3) : .clear, radius: 3)
      .onAppear {
        if index == images.images.indices.first {
          self.firstImageSize = CGSize(width: displayWidth, height: displayHeight)
        }
      }
    }
    .aspectRatio(
      isQuote ? 1 : (firstImageSize?.width ?? width) / (firstImageSize?.height ?? height),
      contentMode: .fit)
  }
}
