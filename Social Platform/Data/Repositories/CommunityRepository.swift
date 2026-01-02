//
//  CommunityRepository.swift
//  Social Platform
//

import Foundation

final class CommunityRepository: CommunityRepositoryProtocol {
    private let communityDataSource: CommunityLocalDataSource
    private let userDataSource: UserLocalDataSource

    init(communityDataSource: CommunityLocalDataSource, userDataSource: UserLocalDataSource) {
        self.communityDataSource = communityDataSource
        self.userDataSource = userDataSource
    }

    func fetchCommunity(id: UUID) async throws -> Community? {
        guard let entity = try communityDataSource.fetch(id: id) else { return nil }
        return CommunityMapper.toDomain(entity)
    }

    func fetchAllCommunities() async throws -> [Community] {
        let entities = try communityDataSource.fetchAll()
        return entities.map { CommunityMapper.toDomain($0) }
    }

    func fetchCommunities(category: String) async throws -> [Community] {
        let entities = try communityDataSource.fetch(category: category)
        return entities.map { CommunityMapper.toDomain($0) }
    }

    func searchCommunities(query: String) async throws -> [Community] {
        let entities = try communityDataSource.search(query: query)
        return entities.map { CommunityMapper.toDomain($0) }
    }

    func fetchUserCommunities(userID: UUID) async throws -> [Community] {
        let entities = try communityDataSource.fetchForUser(userID: userID)
        return entities.map { CommunityMapper.toDomain($0) }
    }

    func createCommunity(_ community: Community) async throws -> Community {
        guard let creatorEntity = try userDataSource.fetch(id: community.creatorID) else {
            throw RepositoryError.notFound
        }
        let entity = try communityDataSource.create(community, creator: creatorEntity)
        return CommunityMapper.toDomain(entity)
    }

    func updateCommunity(_ community: Community) async throws -> Community {
        guard let entity = try communityDataSource.fetch(id: community.id) else {
            throw RepositoryError.notFound
        }
        try communityDataSource.update(entity, with: community)
        return CommunityMapper.toDomain(entity)
    }

    func deleteCommunity(id: UUID) async throws {
        guard let entity = try communityDataSource.fetch(id: id) else {
            throw RepositoryError.notFound
        }
        try communityDataSource.delete(entity)
    }

    func joinCommunity(communityID: UUID, userID: UUID) async throws {
        guard let communityEntity = try communityDataSource.fetch(id: communityID),
              let userEntity = try userDataSource.fetch(id: userID) else {
            throw RepositoryError.notFound
        }
        try communityDataSource.addMember(community: communityEntity, user: userEntity)
    }

    func leaveCommunity(communityID: UUID, userID: UUID) async throws {
        guard let communityEntity = try communityDataSource.fetch(id: communityID),
              let userEntity = try userDataSource.fetch(id: userID) else {
            throw RepositoryError.notFound
        }
        try communityDataSource.removeMember(community: communityEntity, user: userEntity)
    }

    func isUserMember(communityID: UUID, userID: UUID) async throws -> Bool {
        try communityDataSource.isMember(communityID: communityID, userID: userID)
    }

    func fetchMembers(communityID: UUID) async throws -> [User] {
        let entities = try communityDataSource.fetchMembers(communityID: communityID)
        return entities.map { UserMapper.toDomain($0) }
    }
}
