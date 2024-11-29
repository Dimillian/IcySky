import ATProtoKit
import DesignSystem
import Models
import SwiftUI

struct PostRowImagesView: View {
  @Environment(\.isQuote) var isQuote

  let images: AppBskyLexicon.Embed.ImagesDefinition.View

  var body: some View {
    if isQuote {
      ZStack(alignment: .topLeading) {
        ForEach(images.images.indices, id: \.self) { index in
          makeImageView(image: images.images[images.images.count - 1 - index])
            .frame(maxWidth: 100)
            .rotationEffect(.degrees(Double(index) * 10))
            .offset(
              x: 5 * CGFloat(index),
              y: images.images.count <= 2 ? 0 : 10
            )
        }
      }
    } else {
      ForEach(images.images, id: \.self.thumbnailImageURL) { image in
        makeImageView(image: image)
          .frame(maxWidth: nil)
      }
    }
  }

  @ViewBuilder
  private func makeImageView(image: AppBskyLexicon.Embed.ImagesDefinition.ViewImage) -> some View {
    let width: CGFloat = CGFloat(image.aspectRatio?.width ?? 300)
    let height: CGFloat = CGFloat(image.aspectRatio?.height ?? 200)
    GeometryReader { geometry in
      let maxWidth = geometry.size.width
      let aspectRatio = width / height
      let displayWidth = isQuote ? 100 : min(maxWidth, width)
      let displayHeight = isQuote ? 100 : displayWidth / aspectRatio

      AsyncImage(url: image.thumbnailImageURL) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(width: displayWidth, height: displayHeight)
            .aspectRatio(contentMode: .fit)
        default:
          RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
            .frame(width: displayWidth, height: displayHeight)
        }
      }

      .glowingRoundedRectangle()
    }
    .aspectRatio(isQuote ? 1 : width / height, contentMode: .fit)
  }
}
