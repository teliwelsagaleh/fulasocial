//
//  MessageRepository.swift
//  Social Platform
//

import Foundation
import CoreData

final class MessageRepository: MessageRepositoryProtocol {
    private let messageDataSource: MessageLocalDataSource
    private let userDataSource: UserLocalDataSource

    init(messageDataSource: MessageLocalDataSource, userDataSource: UserLocalDataSource) {
        self.messageDataSource = messageDataSource
        self.userDataSource = userDataSource
    }

    // MARK: - Conversations
    func fetchConversations(userID: UUID) async throws -> [Conversation] {
        let entities = try messageDataSource.fetchConversations(userID: userID)
        return entities.map { ConversationMapper.toDomain($0) }
    }

    func fetchConversation(id: UUID) async throws -> Conversation? {
        guard let entity = try messageDataSource.fetchConversation(id: id) else { return nil }
        return ConversationMapper.toDomain(entity)
    }

    func findOrCreateConversation(participantIDs: [UUID]) async throws -> Conversation {
        // Check if conversation already exists
        if let existingEntity = try messageDataSource.findConversation(participantIDs: participantIDs) {
            return ConversationMapper.toDomain(existingEntity)
        }

        // Create new conversation
        let participantEntities = try participantIDs.compactMap { participantID in
            try userDataSource.fetch(id: participantID)
        }

        guard participantEntities.count == participantIDs.count else {
            throw RepositoryError.notFound
        }

        let newConversation = Conversation(
            participantIDs: participantIDs,
            participants: participantEntities.map { UserMapper.toDomain($0) }
        )

        let entity = try messageDataSource.createConversation(newConversation, participants: participantEntities)
        return ConversationMapper.toDomain(entity)
    }

    func createConversation(_ conversation: Conversation) async throws -> Conversation {
        let participantEntities = try conversation.participantIDs.compactMap { participantID in
            try userDataSource.fetch(id: participantID)
        }

        guard participantEntities.count == conversation.participantIDs.count else {
            throw RepositoryError.notFound
        }

        let entity = try messageDataSource.createConversation(conversation, participants: participantEntities)
        return ConversationMapper.toDomain(entity)
    }

    func deleteConversation(id: UUID) async throws {
        guard let entity = try messageDataSource.fetchConversation(id: id) else {
            throw RepositoryError.notFound
        }
        try messageDataSource.deleteConversation(entity)
    }

    // MARK: - Messages
    func fetchMessages(conversationID: UUID) async throws -> [Message] {
        let entities = try messageDataSource.fetchMessages(conversationID: conversationID)
        return entities.map { MessageMapper.toDomain($0) }
    }

    func sendMessage(_ message: Message) async throws -> Message {
        guard let senderEntity = try userDataSource.fetch(id: message.senderID),
              let conversationEntity = try messageDataSource.fetchConversation(id: message.conversationID) else {
            throw RepositoryError.notFound
        }

        let entity = try messageDataSource.createMessage(message, sender: senderEntity, conversation: conversationEntity)
        return MessageMapper.toDomain(entity)
    }

    func markMessageAsRead(messageID: UUID) async throws {
        guard let entity = try messageDataSource.fetchMessage(id: messageID) else {
            throw RepositoryError.notFound
        }
        try messageDataSource.markAsRead(entity)
    }

    func markConversationAsRead(conversationID: UUID, userID: UUID) async throws {
        try messageDataSource.markConversationMessagesAsRead(conversationID: conversationID, excludingSenderID: userID)
    }
}
