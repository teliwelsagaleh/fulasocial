//
//  PostRepositoryProtocol.swift
//  Social Platform
//

import Foundation

protocol PostRepositoryProtocol {
    func fetchPost(id: UUID) async throws -> Post?
    func fetchPosts(communityID: UUID) async throws -> [Post]
    func fetchUserPosts(userID: UUID) async throws -> [Post]
    func fetchHomeFeedPosts(userID: UUID) async throws -> [Post]
    func createPost(_ post: Post) async throws -> Post
    func updatePost(_ post: Post) async throws -> Post
    func deletePost(id: UUID) async throws
    func likePost(postID: UUID, userID: UUID) async throws
    func unlikePost(postID: UUID, userID: UUID) async throws

    // Comments
    func fetchComments(postID: UUID) async throws -> [Comment]
    func createComment(_ comment: Comment) async throws -> Comment
    func deleteComment(id: UUID) async throws
}
