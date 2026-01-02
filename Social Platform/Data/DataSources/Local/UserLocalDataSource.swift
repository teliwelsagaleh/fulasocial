//
//  UserLocalDataSource.swift
//  Social Platform
//

import Foundation
import CoreData

final class UserLocalDataSource {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(id: UUID) throws -> UserEntity? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetch(username: String) throws -> UserEntity? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "username ==[c] %@", username)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetchAll() throws -> [UserEntity] {
        let request = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserEntity.createdAt, ascending: false)]
        return try context.fetch(request)
    }

    func create(_ user: User) throws -> UserEntity {
        let entity = UserMapper.toEntity(user, context: context)
        try context.save()
        return entity
    }

    func update(_ entity: UserEntity, with user: User) throws {
        UserMapper.update(entity, with: user)
        try context.save()
    }

    func delete(_ entity: UserEntity) throws {
        context.delete(entity)
        try context.save()
    }
}
