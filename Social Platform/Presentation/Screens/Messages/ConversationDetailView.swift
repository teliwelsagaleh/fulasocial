//
//  ConversationDetailView.swift
//  Social Platform
//

import SwiftUI

struct ConversationDetailView: View {
    @Environment(DependencyContainer.self) var container
    let conversation: Conversation
    let currentUserID: UUID

    @State private var viewModel = ConversationDetailViewModel()
    @State private var messageText = ""
    @FocusState private var isMessageFieldFocused: Bool

    var otherUser: User? {
        conversation.otherParticipant(currentUserID: currentUserID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderID == currentUserID,
                                senderName: message.senderID == currentUserID ?
                                    "You" : otherUser?.displayName ?? "Unknown"
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .task {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            // Message Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isMessageFieldFocused)
                    .lineLimit(1...5)
                    .onSubmit {
                        sendMessage()
                    }
                    .submitLabel(.send)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(otherUser?.displayName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { simulateIncomingMessage() }) {
                        Label("Simulate Incoming Message (Test)", systemImage: "arrow.down.message")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            viewModel.setup(
                messageRepository: container.messageRepository,
                conversationID: conversation.id,
                currentUserID: currentUserID
            )
            await viewModel.loadMessages()
            await viewModel.markAsRead()
        }
    }

    private func simulateIncomingMessage() {
        guard let otherUserID = otherUser?.id else { return }

        let responses = [
            "Hey! Thanks for the message!",
            "That sounds great!",
            "Sure, I'd love to!",
            "Absolutely! Count me in.",
            "Thanks for reaching out!",
            "Sounds good to me!",
            "Let's do it!",
            "I'm free tomorrow afternoon.",
            "That works perfectly for me!",
            "Looking forward to it!"
        ]

        let randomResponse = responses.randomElement() ?? "Got your message!"

        Task {
            await viewModel.simulateIncomingMessage(
                content: randomResponse,
                senderID: otherUserID
            )
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let content = messageText
        messageText = ""

        Task {
            await viewModel.sendMessage(content: content)
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let senderName: String

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isFromCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.sentAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}

@MainActor @Observable
class ConversationDetailViewModel {
    var messages: [Message] = []
    var isLoading = false

    private var messageRepository: MessageRepositoryProtocol?
    private var conversationID: UUID?
    private var currentUserID: UUID?

    func setup(messageRepository: MessageRepositoryProtocol, conversationID: UUID, currentUserID: UUID) {
        self.messageRepository = messageRepository
        self.conversationID = conversationID
        self.currentUserID = currentUserID
    }

    func loadMessages() async {
        guard let messageRepository, let conversationID else { return }

        isLoading = true
        do {
            messages = try await messageRepository.fetchMessages(conversationID: conversationID)
        } catch {
            print("Error loading messages: \(error)")
        }
        isLoading = false
    }

    func sendMessage(content: String) async {
        guard let messageRepository, let conversationID, let currentUserID else { return }

        let newMessage = Message(
            conversationID: conversationID,
            senderID: currentUserID,
            content: content
        )

        do {
            let sentMessage = try await messageRepository.sendMessage(newMessage)
            messages.append(sentMessage)
        } catch {
            print("Error sending message: \(error)")
        }
    }

    func simulateIncomingMessage(content: String, senderID: UUID) async {
        guard let messageRepository, let conversationID else { return }

        let incomingMessage = Message(
            conversationID: conversationID,
            senderID: senderID,
            content: content,
            isRead: false
        )

        do {
            let receivedMessage = try await messageRepository.sendMessage(incomingMessage)
            messages.append(receivedMessage)
        } catch {
            print("Error simulating incoming message: \(error)")
        }
    }

    func markAsRead() async {
        guard let messageRepository, let conversationID, let currentUserID else { return }

        do {
            try await messageRepository.markConversationAsRead(conversationID: conversationID, userID: currentUserID)
        } catch {
            print("Error marking messages as read: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ConversationDetailView(
            conversation: Conversation(
                participantIDs: [UUID(), UUID()],
                participants: [
                    User(username: "john_doe", displayName: "John Doe"),
                    User(username: "jane_smith", displayName: "Jane Smith")
                ]
            ),
            currentUserID: UUID()
        )
        .environment(DependencyContainer.preview)
    }
}
