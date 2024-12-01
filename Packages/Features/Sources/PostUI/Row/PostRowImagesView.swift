import ATProtoKit
import DesignSystem
import Models
import NukeUI
import SwiftUI

struct PostRowImagesView: View {
  @Namespace private var namespace
  @Environment(\.isQuote) var isQuote

  let quoteMaxSize: CGFloat = 100
  
  let images: AppBskyLexicon.Embed.ImagesDefinition.View
  @State private var firstImageSize: CGSize?

  @State private var isMediaExpanded: Bool = false

  var body: some View {
    ZStack(alignment: .topLeading) {
      ForEach(images.images.indices.reversed(), id: \.self) { index in
        makeImageView(image: images.images[index], index: index)
          .frame(maxWidth: isQuote ? quoteMaxSize : nil)
          .rotationEffect(
            index == images.images.indices.first ? .degrees(0) : .degrees(Double(index) * -2),
            anchor: .bottomTrailing
          )
      }
    }
    .padding(.bottom, images.images.count > 1 && !isQuote ? 15 : 0)
    .onTapGesture {
      isMediaExpanded.toggle()
    }
    .fullScreenCover(isPresented: $isMediaExpanded) {
      expandedView
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
            .frame(width: finalWidth, height: finalHeight)
            .aspectRatio(contentMode: .fit)
        } else {
          RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
            .frame(width: finalWidth, height: finalHeight)
        }
      }
      .processors([.resize(size: .init(width: finalWidth, height: finalHeight))])
      .matchedTransitionSource(id: image.fullSizeImageURL, in: namespace)
      .glowingRoundedRectangle()
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

  private var expandedView: some View {
    ScrollView(.horizontal) {
      LazyHStack {
        ForEach(images.images, id: \.thumbnailImageURL) { image in
          LazyImage(url: image.fullSizeImageURL) { state in
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
    .navigationTransition(.zoom(sourceID: images.images[0].fullSizeImageURL, in: namespace))
  }
}
