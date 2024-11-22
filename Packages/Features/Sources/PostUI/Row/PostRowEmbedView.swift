import ATProtoKit
import DesignSystem
import Models
import SwiftUI

struct PostRowEmbedView: View {
  let post: PostItem

  var body: some View {
    if let embed = post.embed {
      switch embed {
      case .embedImagesView(let images):
        PostRowImagesView(images: images)
      case .embedExternalView(let externalView):
        PostRowEmbedExternalView(externalView: externalView)
      case .embedRecordView(let record):
        switch record.record {
        case .viewRecord(let post):
          PostRowEmbedQuoteView(post: post.postItem)
        default:
          EmptyView()
        }
      default:
        EmptyView()
      }
    }
  }
}
