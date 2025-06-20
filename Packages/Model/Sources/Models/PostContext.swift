import ATProtoKit
import Foundation
import Client
import SwiftUI

@MainActor
@Observable
public class PostContextProvider {
  @ObservationIgnored
  private var contexts: [String: PostContext] = [:]

  public init() {}

  public func get(for post: PostItem, client: BSkyClient) -> PostContext {
    if let context = contexts[post.uri] {
      return context
    } else {
      let context = PostContext(post: post, client: client)
      contexts[post.uri] = context
      return context
    }
  }
}

@MainActor
@Observable
public final class PostContext: Sendable {
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
        try await client.blueskyClient.deleteRecord(.recordURI(atURI: likeURI))
      } else {
        self.likeURI = "ui.optimistic.like"
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
