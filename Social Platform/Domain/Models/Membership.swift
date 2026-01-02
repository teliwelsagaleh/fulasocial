//
//  Membership.swift
//  Social Platform
//

import Foundation

struct CommunityMembership: Identifiable, Equatable, Hashable {
    let id: UUID
    let userID: UUID
    let communityID: UUID
    var role: MemberRole
    let joinedAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        communityID: UUID,
        role: MemberRole = .member,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.communityID = communityID
        self.role = role
        self.joinedAt = joinedAt
    }
}

enum MemberRole: String, CaseIterable {
    case owner = "owner"
    case admin = "admin"
    case moderator = "moderator"
    case member = "member"

    var displayName: String {
        switch self {
        case .owner: return "Owner"
        case .admin: return "Admin"
        case .moderator: return "Moderator"
        case .member: return "Member"
        }
    }
}
