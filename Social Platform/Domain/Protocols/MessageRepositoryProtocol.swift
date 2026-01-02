//
//  MessageRepositoryProtocol.swift
//  Social Platform
//

import Foundation

protocol MessageRepositoryProtocol {
    // Conversations
    func fetchConversations(userID: UUID) async throws -> [Conversation]
    func fetchConversation(id: UUID) async throws -> Conversation?
    func findOrCreateConversation(participantIDs: [UUID]) async throws -> Conversation
    func createConversation(_ conversation: Conversation) async throws -> Conversation
    func deleteConversation(id: UUID) async throws

    // Messages
    func fetchMessages(conversationID: UUID) async throws -> [Message]
    func sendMessage(_ message: Message) async throws -> Message
    func markMessageAsRead(messageID: UUID) async throws
    func markConversationAsRead(conversationID: UUID, userID: UUID) async throws
}
