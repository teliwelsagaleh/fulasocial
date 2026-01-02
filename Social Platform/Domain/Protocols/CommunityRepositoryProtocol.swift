//
//  CommunityRepositoryProtocol.swift
//  Social Platform
//

import Foundation

protocol CommunityRepositoryProtocol {
    func fetchCommunity(id: UUID) async throws -> Community?
    func fetchAllCommunities() async throws -> [Community]
    func fetchCommunities(category: String) async throws -> [Community]
    func searchCommunities(query: String) async throws -> [Community]
    func fetchUserCommunities(userID: UUID) async throws -> [Community]
    func createCommunity(_ community: Community) async throws -> Community
    func updateCommunity(_ community: Community) async throws -> Community
    func deleteCommunity(id: UUID) async throws
    func joinCommunity(communityID: UUID, userID: UUID) async throws
    func leaveCommunity(communityID: UUID, userID: UUID) async throws
    func isUserMember(communityID: UUID, userID: UUID) async throws -> Bool
    func fetchMembers(communityID: UUID) async throws -> [User]
}
