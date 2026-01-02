//
//  UserRepositoryProtocol.swift
//  Social Platform
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(id: UUID) async throws -> User?
    func fetchUser(username: String) async throws -> User?
    func fetchAllUsers() async throws -> [User]
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: UUID) async throws
}
