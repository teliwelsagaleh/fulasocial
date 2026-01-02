//
//  Message.swift
//  Social Platform
//

import Foundation

struct Message: Identifiable, Equatable, Hashable {
    let id: UUID
    let conversationID: UUID
    let senderID: UUID
    var content: String
    var isRead: Bool
    let sentAt: Date

    init(
        id: UUID = UUID(),
        conversationID: UUID,
        senderID: UUID,
        content: String,
        isRead: Bool = false,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.content = content
        self.isRead = isRead
        self.sentAt = sentAt
    }
}

struct Conversation: Identifiable, Equatable, Hashable {
    let id: UUID
    var participantIDs: [UUID]
    var participants: [User]
    var lastMessage: Message?
    var lastMessageAt: Date

    init(
        id: UUID = UUID(),
        participantIDs: [UUID],
        participants: [User] = [],
        lastMessage: Message? = nil,
        lastMessageAt: Date = Date()
    ) {
        self.id = id
        self.participantIDs = participantIDs
        self.participants = participants
        self.lastMessage = lastMessage
        self.lastMessageAt = lastMessageAt
    }

    func otherParticipant(currentUserID: UUID) -> User? {
        participants.first { $0.id != currentUserID }
    }

    var hasUnreadMessages: Bool {
        lastMessage?.isRead == false
    }
}
