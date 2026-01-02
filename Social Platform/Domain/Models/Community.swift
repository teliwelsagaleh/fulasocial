//
//  Community.swift
//  Social Platform
//

import Foundation

struct Community: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var imageURL: String?
    var category: String
    var isPrivate: Bool
    let createdAt: Date
    let creatorID: UUID
    var memberCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageURL: String? = nil,
        category: String,
        isPrivate: Bool = false,
        createdAt: Date = Date(),
        creatorID: UUID,
        memberCount: Int = 1
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.category = category
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.creatorID = creatorID
        self.memberCount = memberCount
    }
}

enum CommunityCategory: String, CaseIterable {
    case technology = "Technology"
    case art = "Art"
    case music = "Music"
    case sports = "Sports"
    case gaming = "Gaming"
    case photography = "Photography"
    case travel = "Travel"
    case food = "Food"
    case fitness = "Fitness"
    case books = "Books"
    case movies = "Movies"
    case science = "Science"
    case nature = "Nature"
    case fashion = "Fashion"
    case diy = "DIY"
    case other = "Other"

    var icon: String {
        switch self {
        case .technology: return "laptopcomputer"
        case .art: return "paintpalette"
        case .music: return "music.note"
        case .sports: return "sportscourt"
        case .gaming: return "gamecontroller"
        case .photography: return "camera"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .fitness: return "figure.run"
        case .books: return "book"
        case .movies: return "film"
        case .science: return "atom"
        case .nature: return "leaf"
        case .fashion: return "tshirt"
        case .diy: return "hammer"
        case .other: return "square.grid.2x2"
        }
    }
}
