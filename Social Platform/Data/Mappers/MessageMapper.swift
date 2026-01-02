//
//  MessageMapper.swift
//  Social Platform
//

import Foundation
import CoreData

enum MessageMapper {
    static func toDomain(_ entity: MessageEntity) -> Message {
        Message(
            id: entity.id ?? UUID(),
            conversationID: entity.conversation?.id ?? UUID(),
            senderID: entity.sender?.id ?? UUID(),
            content: entity.content ?? "",
            isRead: entity.isRead,
            sentAt: entity.sentAt ?? Date()
        )
    }

    static func toEntity(_ message: Message, context: NSManagedObjectContext) -> MessageEntity {
        let entity = MessageEntity(context: context)
        entity.id = message.id
        entity.content = message.content
        entity.isRead = message.isRead
        entity.sentAt = message.sentAt
        return entity
    }

    static func update(_ entity: MessageEntity, with message: Message) {
        entity.content = message.content
        entity.isRead = message.isRead
    }
}

enum ConversationMapper {
    static func toDomain(_ entity: ConversationEntity) -> Conversation {
        let participants = (entity.participants as? Set<UserEntity>)?
            .map { UserMapper.toDomain($0) } ?? []

        let messages = (entity.messages as? Set<MessageEntity>)?
            .sorted { ($0.sentAt ?? Date()) > ($1.sentAt ?? Date()) }

        let lastMessage = messages?.first.map { MessageMapper.toDomain($0) }

        return Conversation(
            id: entity.id ?? UUID(),
            participantIDs: entity.participantIDs ?? [],
            participants: participants,
            lastMessage: lastMessage,
            lastMessageAt: entity.lastMessageAt ?? Date()
        )
    }

    static func toEntity(_ conversation: Conversation, context: NSManagedObjectContext) -> ConversationEntity {
        let entity = ConversationEntity(context: context)
        entity.id = conversation.id
        entity.participantIDs = conversation.participantIDs
        entity.lastMessageAt = conversation.lastMessageAt
        return entity
    }
}
