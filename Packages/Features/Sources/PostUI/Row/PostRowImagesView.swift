import ATProtoKit
import DesignSystem
import Models
import SwiftUI

struct PostRowImagesView: View {
  @Environment(\.isQuote) var isQuote

  let images: AppBskyLexicon.Embed.ImagesDefinition.View

  var body: some View {
    ForEach(images.images, id: \.self.thumbnailImageURL) { image in
      makeImageView(image: image)
        .frame(maxWidth: isQuote ? 100 : nil)
    }
  }

  @ViewBuilder
  private func makeImageView(image: AppBskyLexicon.Embed.ImagesDefinition.ViewImage) -> some View {
    let width: CGFloat = CGFloat(image.aspectRatio?.width ?? 300)
    let height: CGFloat = CGFloat(image.aspectRatio?.height ?? 200)
    GeometryReader { geometry in
      let maxWidth = geometry.size.width
      let aspectRatio = width / height
      let displayWidth = isQuote ? 80 : min(maxWidth, width)
      let displayHeight = isQuote ? 80 : displayWidth / aspectRatio

      AsyncImage(url: image.thumbnailImageURL) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .frame(width: displayWidth, height: displayHeight)
            .scaledToFit()
        default:
          RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
            .frame(width: displayWidth, height: displayHeight)
        }
      }
      .frame(width: displayWidth, height: displayHeight)
      .glowingRoundedRectangle()
    }
    .aspectRatio(isQuote ? 1 : width / height, contentMode: .fit)
  }
}
