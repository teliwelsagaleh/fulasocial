//
//  CommunityLocalDataSource.swift
//  Social Platform
//

import Foundation
import CoreData

final class CommunityLocalDataSource {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(id: UUID) throws -> CommunityEntity? {
        let request = CommunityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetchAll() throws -> [CommunityEntity] {
        let request = CommunityEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommunityEntity.memberCount, ascending: false)]
        return try context.fetch(request)
    }

    func fetch(category: String) throws -> [CommunityEntity] {
        let request = CommunityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommunityEntity.memberCount, ascending: false)]
        return try context.fetch(request)
    }

    func search(query: String) throws -> [CommunityEntity] {
        let request = CommunityEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommunityEntity.memberCount, ascending: false)]
        return try context.fetch(request)
    }

    func fetchForUser(userID: UUID) throws -> [CommunityEntity] {
        let request = CommunityMembershipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", userID as CVarArg)
        let memberships = try context.fetch(request)
        return memberships.compactMap { $0.community }
    }

    func create(_ community: Community, creator: UserEntity) throws -> CommunityEntity {
        let entity = CommunityMapper.toEntity(community, context: context)
        entity.creator = creator

        // Create membership for creator as owner
        let membership = CommunityMembershipEntity(context: context)
        membership.id = UUID()
        membership.user = creator
        membership.community = entity
        membership.role = MemberRole.owner.rawValue
        membership.joinedAt = Date()

        try context.save()
        return entity
    }

    func update(_ entity: CommunityEntity, with community: Community) throws {
        CommunityMapper.update(entity, with: community)
        try context.save()
    }

    func delete(_ entity: CommunityEntity) throws {
        context.delete(entity)
        try context.save()
    }

    func addMember(community: CommunityEntity, user: UserEntity, role: MemberRole = .member) throws {
        let membership = CommunityMembershipEntity(context: context)
        membership.id = UUID()
        membership.user = user
        membership.community = community
        membership.role = role.rawValue
        membership.joinedAt = Date()

        community.memberCount += 1
        try context.save()
    }

    func removeMember(community: CommunityEntity, user: UserEntity) throws {
        let request = CommunityMembershipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "community.id == %@ AND user.id == %@",
                                         community.id! as CVarArg, user.id! as CVarArg)
        if let membership = try context.fetch(request).first {
            context.delete(membership)
            community.memberCount = max(0, community.memberCount - 1)
            try context.save()
        }
    }

    func isMember(communityID: UUID, userID: UUID) throws -> Bool {
        let request = CommunityMembershipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "community.id == %@ AND user.id == %@",
                                         communityID as CVarArg, userID as CVarArg)
        request.fetchLimit = 1
        return try context.count(for: request) > 0
    }

    func fetchMembers(communityID: UUID) throws -> [UserEntity] {
        let request = CommunityMembershipEntity.fetchRequest()
        request.predicate = NSPredicate(format: "community.id == %@", communityID as CVarArg)
        let memberships = try context.fetch(request)
        return memberships.compactMap { $0.user }
    }
}
