//
//  UserRepository.swift
//  Social Platform
//

import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let localDataSource: UserLocalDataSource

    init(localDataSource: UserLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchUser(id: UUID) async throws -> User? {
        guard let entity = try localDataSource.fetch(id: id) else { return nil }
        return UserMapper.toDomain(entity)
    }

    func fetchUser(username: String) async throws -> User? {
        guard let entity = try localDataSource.fetch(username: username) else { return nil }
        return UserMapper.toDomain(entity)
    }

    func fetchAllUsers() async throws -> [User] {
        let entities = try localDataSource.fetchAll()
        return entities.map { UserMapper.toDomain($0) }
    }

    func createUser(_ user: User) async throws -> User {
        let entity = try localDataSource.create(user)
        return UserMapper.toDomain(entity)
    }

    func updateUser(_ user: User) async throws -> User {
        guard let entity = try localDataSource.fetch(id: user.id) else {
            throw RepositoryError.notFound
        }
        try localDataSource.update(entity, with: user)
        return UserMapper.toDomain(entity)
    }

    func deleteUser(id: UUID) async throws {
        guard let entity = try localDataSource.fetch(id: id) else {
            throw RepositoryError.notFound
        }
        try localDataSource.delete(entity)
    }
}

enum RepositoryError: Error {
    case notFound
    case invalidData
    case saveFailed
}
