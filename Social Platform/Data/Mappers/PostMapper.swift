//
//  PostMapper.swift
//  Social Platform
//

import Foundation
import CoreData

enum PostMapper {
    static func toDomain(_ entity: PostEntity) -> Post {
        var post = Post(
            id: entity.id ?? UUID(),
            content: entity.content ?? "",
            imageURLs: entity.imageURLs ?? [],
            linkURL: entity.linkURL,
            linkPreviewTitle: entity.linkPreviewTitle,
            linkPreviewDescription: entity.linkPreviewDescription,
            linkPreviewImage: entity.linkPreviewImage,
            createdAt: entity.createdAt ?? Date(),
            authorID: entity.author?.id ?? UUID(),
            communityID: entity.community?.id ?? UUID(),
            likeCount: Int(entity.likeCount),
            commentCount: Int(entity.commentCount)
        )

        if let authorEntity = entity.author {
            post.author = UserMapper.toDomain(authorEntity)
        }

        if let communityEntity = entity.community {
            post.community = CommunityMapper.toDomain(communityEntity)
        }

        return post
    }

    static func toEntity(_ post: Post, context: NSManagedObjectContext) -> PostEntity {
        let entity = PostEntity(context: context)
        entity.id = post.id
        entity.content = post.content
        entity.imageURLs = post.imageURLs
        entity.linkURL = post.linkURL
        entity.linkPreviewTitle = post.linkPreviewTitle
        entity.linkPreviewDescription = post.linkPreviewDescription
        entity.linkPreviewImage = post.linkPreviewImage
        entity.createdAt = post.createdAt
        entity.likeCount = Int32(post.likeCount)
        entity.commentCount = Int32(post.commentCount)
        return entity
    }

    static func update(_ entity: PostEntity, with post: Post) {
        entity.content = post.content
        entity.imageURLs = post.imageURLs
        entity.linkURL = post.linkURL
        entity.linkPreviewTitle = post.linkPreviewTitle
        entity.linkPreviewDescription = post.linkPreviewDescription
        entity.linkPreviewImage = post.linkPreviewImage
        entity.likeCount = Int32(post.likeCount)
        entity.commentCount = Int32(post.commentCount)
    }
}

enum CommentMapper {
    static func toDomain(_ entity: CommentEntity) -> Comment {
        var comment = Comment(
            id: entity.id ?? UUID(),
            content: entity.content ?? "",
            createdAt: entity.createdAt ?? Date(),
            authorID: entity.author?.id ?? UUID(),
            postID: entity.post?.id ?? UUID()
        )

        if let authorEntity = entity.author {
            comment.author = UserMapper.toDomain(authorEntity)
        }

        return comment
    }

    static func toEntity(_ comment: Comment, context: NSManagedObjectContext) -> CommentEntity {
        let entity = CommentEntity(context: context)
        entity.id = comment.id
        entity.content = comment.content
        entity.createdAt = comment.createdAt
        return entity
    }
}
