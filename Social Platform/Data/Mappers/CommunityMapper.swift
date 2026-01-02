//
//  CommunityMapper.swift
//  Social Platform
//

import Foundation
import CoreData

enum CommunityMapper {
    static func toDomain(_ entity: CommunityEntity) -> Community {
        Community(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            description: entity.descriptionText ?? "",
            imageURL: entity.imageURL,
            category: entity.category ?? "Other",
            isPrivate: entity.isPrivate,
            createdAt: entity.createdAt ?? Date(),
            creatorID: entity.creator?.id ?? UUID(),
            memberCount: Int(entity.memberCount)
        )
    }

    static func toEntity(_ community: Community, context: NSManagedObjectContext) -> CommunityEntity {
        let entity = CommunityEntity(context: context)
        entity.id = community.id
        entity.name = community.name
        entity.descriptionText = community.description
        entity.imageURL = community.imageURL
        entity.category = community.category
        entity.isPrivate = community.isPrivate
        entity.createdAt = community.createdAt
        entity.memberCount = Int32(community.memberCount)
        return entity
    }

    static func update(_ entity: CommunityEntity, with community: Community) {
        entity.name = community.name
        entity.descriptionText = community.description
        entity.imageURL = community.imageURL
        entity.category = community.category
        entity.isPrivate = community.isPrivate
        entity.memberCount = Int32(community.memberCount)
    }
}
