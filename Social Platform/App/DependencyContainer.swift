//
//  DependencyContainer.swift
//  Social Platform
//

import Foundation
import CoreData

@MainActor @Observable
final class DependencyContainer {
    // MARK: - Core Data
    let persistenceController: PersistenceController

    // MARK: - Data Sources
    private(set) var userLocalDataSource: UserLocalDataSource
    private(set) var communityLocalDataSource: CommunityLocalDataSource
    private(set) var postLocalDataSource: PostLocalDataSource
    private(set) var messageLocalDataSource: MessageLocalDataSource

    // MARK: - Repositories
    private(set) var userRepository: UserRepositoryProtocol
    private(set) var communityRepository: CommunityRepositoryProtocol
    private(set) var postRepository: PostRepositoryProtocol
    private(set) var messageRepository: MessageRepositoryProtocol

    // MARK: - Services
    private(set) var authService: AuthService

    // MARK: - Initialization
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController

        let viewContext = persistenceController.container.viewContext

        // Initialize Data Sources
        let userDS = UserLocalDataSource(context: viewContext)
        let communityDS = CommunityLocalDataSource(context: viewContext)
        let postDS = PostLocalDataSource(context: viewContext)
        let messageDS = MessageLocalDataSource(context: viewContext)

        self.userLocalDataSource = userDS
        self.communityLocalDataSource = communityDS
        self.postLocalDataSource = postDS
        self.messageLocalDataSource = messageDS

        // Initialize Repositories
        let userRepo = UserRepository(localDataSource: userDS)
        self.userRepository = userRepo

        self.communityRepository = CommunityRepository(
            communityDataSource: communityDS,
            userDataSource: userDS
        )

        self.postRepository = PostRepository(
            postDataSource: postDS,
            userDataSource: userDS,
            communityDataSource: communityDS
        )

        self.messageRepository = MessageRepository(
            messageDataSource: messageDS,
            userDataSource: userDS
        )

        // Initialize Services
        self.authService = AuthService(userRepository: userRepo)
    }

    // MARK: - Preview
    static var preview: DependencyContainer = {
        DependencyContainer(persistenceController: .preview)
    }()
}
