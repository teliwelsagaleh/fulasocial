//
//  PostLocalDataSource.swift
//  Social Platform
//

import Foundation
import CoreData

final class PostLocalDataSource {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(id: UUID) throws -> PostEntity? {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetchForCommunity(communityID: UUID) throws -> [PostEntity] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "community.id == %@", communityID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PostEntity.createdAt, ascending: false)]
        return try context.fetch(request)
    }

    func fetchForUser(userID: UUID) throws -> [PostEntity] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "author.id == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PostEntity.createdAt, ascending: false)]
        return try context.fetch(request)
    }

    func fetchHomeFeed(userID: UUID) throws -> [PostEntity] {
        // Get communities the user is a member of
        let membershipRequest = CommunityMembershipEntity.fetchRequest()
        membershipRequest.predicate = NSPredicate(format: "user.id == %@", userID as CVarArg)
        let memberships = try context.fetch(membershipRequest)
        let communityIDs = memberships.compactMap { $0.community?.id }

        guard !communityIDs.isEmpty else { return [] }

        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "community.id IN %@", communityIDs)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PostEntity.createdAt, ascending: false)]
        request.fetchLimit = 50
        return try context.fetch(request)
    }

    func create(_ post: Post, author: UserEntity, community: CommunityEntity) throws -> PostEntity {
        let entity = PostMapper.toEntity(post, context: context)
        entity.author = author
        entity.community = community
        try context.save()
        return entity
    }

    func update(_ entity: PostEntity, with post: Post) throws {
        PostMapper.update(entity, with: post)
        try context.save()
    }

    func delete(_ entity: PostEntity) throws {
        context.delete(entity)
        try context.save()
    }

    func incrementLikeCount(_ entity: PostEntity) throws {
        entity.likeCount += 1
        try context.save()
    }

    func decrementLikeCount(_ entity: PostEntity) throws {
        entity.likeCount = max(0, entity.likeCount - 1)
        try context.save()
    }

    // Comments
    func fetchComments(postID: UUID) throws -> [CommentEntity] {
        let request = CommentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "post.id == %@", postID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommentEntity.createdAt, ascending: true)]
        return try context.fetch(request)
    }

    func createComment(_ comment: Comment, author: UserEntity, post: PostEntity) throws -> CommentEntity {
        let entity = CommentMapper.toEntity(comment, context: context)
        entity.author = author
        entity.post = post
        post.commentCount += 1
        try context.save()
        return entity
    }

    func deleteComment(_ entity: CommentEntity) throws {
        if let post = entity.post {
            post.commentCount = max(0, post.commentCount - 1)
        }
        context.delete(entity)
        try context.save()
    }
}
