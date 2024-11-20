import ATProtoKit
import DesignSystem
import Models
import SwiftUI

struct PostRowImagesView: View {
  let images: AppBskyLexicon.Embed.ImagesDefinition.View

  var body: some View {
    ForEach(images.images, id: \.self.thumbnailImageURL) { image in
      let width: CGFloat = CGFloat(image.aspectRatio?.width ?? 300)
      let height: CGFloat = CGFloat(image.aspectRatio?.height ?? 200)
      GeometryReader { geometry in
        let maxWidth = geometry.size.width
        let aspectRatio = width / height
        let displayWidth = min(maxWidth, width)
        let displayHeight = displayWidth / aspectRatio

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
      .aspectRatio(width / height, contentMode: .fit)
    }
  }
}
