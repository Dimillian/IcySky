import ATProtoKit
import DesignSystem
import Models
import SwiftUI

struct PostRowEmbedExternalView: View {
  @Environment(\.openURL) var openURL

  let externalView: AppBskyLexicon.Embed.ExternalDefinition.View

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      GeometryReader { proxy in
        AsyncImage(url: externalView.external.thumbnailImageURL) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: proxy.size.width)
              .frame(height: 200)
              .clipped()
          default:
            Rectangle()
              .fill(Color.gray.opacity(0.2))
          }
        }
      }
      .frame(height: 200)

      Text(externalView.external.title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
        .lineLimit(3)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 8)
        .padding(.top, 8)
      Text(externalView.external.description)
        .font(.body)
        .foregroundStyle(.secondary)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(.ultraThinMaterial)
    )
    .glowingRoundedRectangle()
    .contentShape(Rectangle())
    .onTapGesture {
      if let url = URL(string: externalView.external.uri) {
        openURL(url)
      }
    }
  }
}
