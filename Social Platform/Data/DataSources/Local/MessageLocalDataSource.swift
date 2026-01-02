//
//  MessageLocalDataSource.swift
//  Social Platform
//

import Foundation
import CoreData

final class MessageLocalDataSource {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Conversations
    func fetchConversation(id: UUID) throws -> ConversationEntity? {
        let request = ConversationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func fetchConversations(userID: UUID) throws -> [ConversationEntity] {
        let request = ConversationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY participants.id == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ConversationEntity.lastMessageAt, ascending: false)]
        return try context.fetch(request)
    }

    func findConversation(participantIDs: [UUID]) throws -> ConversationEntity? {
        let request = ConversationEntity.fetchRequest()
        // Find conversation where participantIDs match exactly
        let conversations = try context.fetch(request)
        return conversations.first { conversation in
            let conversationParticipantIDs = Set(conversation.participantIDs ?? [])
            let searchParticipantIDs = Set(participantIDs)
            return conversationParticipantIDs == searchParticipantIDs
        }
    }

    func createConversation(_ conversation: Conversation, participants: [UserEntity]) throws -> ConversationEntity {
        let entity = ConversationMapper.toEntity(conversation, context: context)
        entity.participants = NSSet(array: participants)
        try context.save()
        return entity
    }

    func deleteConversation(_ entity: ConversationEntity) throws {
        context.delete(entity)
        try context.save()
    }

    // MARK: - Messages
    func fetchMessages(conversationID: UUID) throws -> [MessageEntity] {
        let request = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.id == %@", conversationID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MessageEntity.sentAt, ascending: true)]
        return try context.fetch(request)
    }

    func fetchMessage(id: UUID) throws -> MessageEntity? {
        let request = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    func createMessage(_ message: Message, sender: UserEntity, conversation: ConversationEntity) throws -> MessageEntity {
        let entity = MessageMapper.toEntity(message, context: context)
        entity.sender = sender
        entity.conversation = conversation

        // Update conversation's last message timestamp
        conversation.lastMessageAt = message.sentAt

        try context.save()
        return entity
    }

    func markAsRead(_ entity: MessageEntity) throws {
        entity.isRead = true
        try context.save()
    }

    func markConversationMessagesAsRead(conversationID: UUID, excludingSenderID: UUID) throws {
        let request = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "conversation.id == %@ AND sender.id != %@ AND isRead == NO",
            conversationID as CVarArg,
            excludingSenderID as CVarArg
        )
        let messages = try context.fetch(request)

        for message in messages {
            message.isRead = true
        }

        if !messages.isEmpty {
            try context.save()
        }
    }
}
