import ATProtoKit
import Foundation
import Network
import SwiftUI

@MainActor
@Observable
public class PostDataControllerProvider {
  private var dataControllers: [String: PostDataController] = [:]

  public init() {}

  public func getController(for post: PostItem, client: BSkyClient) -> PostDataController {
    if let controller = dataControllers[post.uri] {
      return controller
    } else {
      let controller = PostDataController(post: post, client: client)
      dataControllers[post.uri] = controller
      return controller
    }
  }
}

@MainActor
@Observable
public class PostDataController {
  private var post: PostItem
  private let client: BSkyClient

  public var isLiked: Bool { likeURI != nil }
  public var isReposted: Bool { repostURI != nil }

  public var likeCount: Int { post.likeCount + (isLiked ? 1 : 0) }
  public var repostCount: Int { post.repostCount + (isReposted ? 1 : 0) }

  private var likeURI: String?
  private var repostURI: String?

  public init(post: PostItem, client: BSkyClient) {
    self.post = post
    self.client = client

    likeURI = post.likeURI
    repostURI = post.repostURI
  }

  public func update(with post: PostItem) {
    self.post = post

    likeURI = post.likeURI
    repostURI = post.repostURI
  }

  public func toggleLike() async {
    let previousState = likeURI
    do {
      if let likeURI {
        self.likeURI = nil
        try await client.blueskyClient.deleteLikeRecord(.recordURI(atURI: likeURI))
      } else {
        self.likeURI = try await client.blueskyClient.createLikeRecord(
          .init(recordURI: post.uri, cidHash: post.cid)
        ).recordURI
      }
    } catch {
      self.likeURI = previousState
    }
  }

  public func toggleRepost() async {
    // TODO: Implement
  }
}
