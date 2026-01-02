//
//  UserMapper.swift
//  Social Platform
//

import Foundation
import CoreData

enum UserMapper {
    static func toDomain(_ entity: UserEntity) -> User {
        User(
            id: entity.id ?? UUID(),
            username: entity.username ?? "",
            displayName: entity.displayName ?? "",
            email: entity.email ?? "",
            avatarURL: entity.avatarURL,
            bio: entity.bio,
            interests: entity.interests ?? [],
            createdAt: entity.createdAt ?? Date()
        )
    }

    static func toEntity(_ user: User, context: NSManagedObjectContext) -> UserEntity {
        let entity = UserEntity(context: context)
        entity.id = user.id
        entity.username = user.username
        entity.displayName = user.displayName
        entity.email = user.email
        entity.avatarURL = user.avatarURL
        entity.bio = user.bio
        entity.interests = user.interests
        entity.createdAt = user.createdAt
        return entity
    }

    static func update(_ entity: UserEntity, with user: User) {
        entity.username = user.username
        entity.displayName = user.displayName
        entity.email = user.email
        entity.avatarURL = user.avatarURL
        entity.bio = user.bio
        entity.interests = user.interests
    }
}
