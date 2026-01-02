//
//  PostRepository.swift
//  Social Platform
//

import Foundation
import CoreData

final class PostRepository: PostRepositoryProtocol {
    private let postDataSource: PostLocalDataSource
    private let userDataSource: UserLocalDataSource
    private let communityDataSource: CommunityLocalDataSource

    init(postDataSource: PostLocalDataSource,
         userDataSource: UserLocalDataSource,
         communityDataSource: CommunityLocalDataSource) {
        self.postDataSource = postDataSource
        self.userDataSource = userDataSource
        self.communityDataSource = communityDataSource
    }

    func fetchPost(id: UUID) async throws -> Post? {
        guard let entity = try postDataSource.fetch(id: id) else { return nil }
        return PostMapper.toDomain(entity)
    }

    func fetchPosts(communityID: UUID) async throws -> [Post] {
        let entities = try postDataSource.fetchForCommunity(communityID: communityID)
        return entities.map { PostMapper.toDomain($0) }
    }

    func fetchUserPosts(userID: UUID) async throws -> [Post] {
        let entities = try postDataSource.fetchForUser(userID: userID)
        return entities.map { PostMapper.toDomain($0) }
    }

    func fetchHomeFeedPosts(userID: UUID) async throws -> [Post] {
        let entities = try postDataSource.fetchHomeFeed(userID: userID)
        return entities.map { PostMapper.toDomain($0) }
    }

    func createPost(_ post: Post) async throws -> Post {
        guard let authorEntity = try userDataSource.fetch(id: post.authorID),
              let communityEntity = try communityDataSource.fetch(id: post.communityID) else {
            throw RepositoryError.notFound
        }
        let entity = try postDataSource.create(post, author: authorEntity, community: communityEntity)
        return PostMapper.toDomain(entity)
    }

    func updatePost(_ post: Post) async throws -> Post {
        guard let entity = try postDataSource.fetch(id: post.id) else {
            throw RepositoryError.notFound
        }
        try postDataSource.update(entity, with: post)
        return PostMapper.toDomain(entity)
    }

    func deletePost(id: UUID) async throws {
        guard let entity = try postDataSource.fetch(id: id) else {
            throw RepositoryError.notFound
        }
        try postDataSource.delete(entity)
    }

    func likePost(postID: UUID, userID: UUID) async throws {
        guard let entity = try postDataSource.fetch(id: postID) else {
            throw RepositoryError.notFound
        }
        try postDataSource.incrementLikeCount(entity)
    }

    func unlikePost(postID: UUID, userID: UUID) async throws {
        guard let entity = try postDataSource.fetch(id: postID) else {
            throw RepositoryError.notFound
        }
        try postDataSource.decrementLikeCount(entity)
    }

    // Comments
    func fetchComments(postID: UUID) async throws -> [Comment] {
        let entities = try postDataSource.fetchComments(postID: postID)
        return entities.map { CommentMapper.toDomain($0) }
    }

    func createComment(_ comment: Comment) async throws -> Comment {
        guard let authorEntity = try userDataSource.fetch(id: comment.authorID),
              let postEntity = try postDataSource.fetch(id: comment.postID) else {
            throw RepositoryError.notFound
        }
        let entity = try postDataSource.createComment(comment, author: authorEntity, post: postEntity)
        return CommentMapper.toDomain(entity)
    }

    func deleteComment(id: UUID) async throws {
        let request = CommentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        // Note: This needs access to context - simplified for now
        throw RepositoryError.notFound
    }
}
