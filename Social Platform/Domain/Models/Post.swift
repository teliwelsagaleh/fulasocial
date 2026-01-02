//
//  Post.swift
//  Social Platform
//

import Foundation

struct Post: Identifiable, Equatable, Hashable {
    let id: UUID
    var content: String
    var imageURLs: [String]
    var linkURL: String?
    var linkPreviewTitle: String?
    var linkPreviewDescription: String?
    var linkPreviewImage: String?
    let createdAt: Date
    let authorID: UUID
    let communityID: UUID
    var likeCount: Int
    var commentCount: Int

    // Transient properties for display
    var author: User?
    var community: Community?

    init(
        id: UUID = UUID(),
        content: String,
        imageURLs: [String] = [],
        linkURL: String? = nil,
        linkPreviewTitle: String? = nil,
        linkPreviewDescription: String? = nil,
        linkPreviewImage: String? = nil,
        createdAt: Date = Date(),
        authorID: UUID,
        communityID: UUID,
        likeCount: Int = 0,
        commentCount: Int = 0,
        author: User? = nil,
        community: Community? = nil
    ) {
        self.id = id
        self.content = content
        self.imageURLs = imageURLs
        self.linkURL = linkURL
        self.linkPreviewTitle = linkPreviewTitle
        self.linkPreviewDescription = linkPreviewDescription
        self.linkPreviewImage = linkPreviewImage
        self.createdAt = createdAt
        self.authorID = authorID
        self.communityID = communityID
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.author = author
        self.community = community
    }
}

struct Comment: Identifiable, Equatable, Hashable {
    let id: UUID
    var content: String
    let createdAt: Date
    let authorID: UUID
    let postID: UUID

    // Transient property for display
    var author: User?

    init(
        id: UUID = UUID(),
        content: String,
        createdAt: Date = Date(),
        authorID: UUID,
        postID: UUID,
        author: User? = nil
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.authorID = authorID
        self.postID = postID
        self.author = author
    }
}
