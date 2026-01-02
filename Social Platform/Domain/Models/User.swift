//
//  User.swift
//  Social Platform
//

import Foundation

struct User: Identifiable, Equatable, Hashable {
    let id: UUID
    var username: String
    var displayName: String
    var email: String
    var avatarURL: String?
    var bio: String?
    var interests: [String]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        email: String = "",
        avatarURL: String? = nil,
        bio: String? = nil,
        interests: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.bio = bio
        self.interests = interests
        self.createdAt = createdAt
    }
}
