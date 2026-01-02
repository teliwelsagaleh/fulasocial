//
//  ConversationListView.swift
//  Social Platform
//

import SwiftUI

struct ConversationListView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = ConversationListViewModel()
    @State private var showingNewConversation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading conversations...")
                } else if viewModel.conversations.isEmpty {
                    EmptyConversationsView()
                } else {
                    List(viewModel.conversations) { conversation in
                        if let currentUserID = authService.currentUser?.id {
                            NavigationLink(destination: ConversationDetailView(
                                conversation: conversation,
                                currentUserID: currentUserID
                            )) {
                                ConversationRowView(
                                    conversation: conversation,
                                    currentUserID: currentUserID
                                )
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadConversations()
                    }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewConversation = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingNewConversation) {
                NewConversationView { conversation in
                    viewModel.addConversation(conversation)
                }
            }
            .task {
                viewModel.setup(
                    messageRepository: container.messageRepository,
                    userID: authService.currentUser?.id
                )
                await viewModel.loadConversations()
            }
        }
    }
}

struct ConversationRowView: View {
    let conversation: Conversation
    let currentUserID: UUID

    var otherUser: User? {
        conversation.otherParticipant(currentUserID: currentUserID)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AvatarView(
                name: otherUser?.displayName ?? "Unknown",
                size: 50,
                imageURL: otherUser?.avatarURL
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherUser?.displayName ?? "Unknown User")
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.lastMessageAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let lastMessage = conversation.lastMessage {
                    HStack {
                        Text(lastMessage.content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        Spacer()

                        if !lastMessage.isRead && lastMessage.senderID != currentUserID {
                            Circle()
                                .fill(.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyConversationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Messages Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start a conversation with someone!")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

@MainActor @Observable
class ConversationListViewModel {
    var conversations: [Conversation] = []
    var isLoading = false

    private var messageRepository: MessageRepositoryProtocol?
    private var userID: UUID?

    func setup(messageRepository: MessageRepositoryProtocol, userID: UUID?) {
        self.messageRepository = messageRepository
        self.userID = userID
    }

    func loadConversations() async {
        guard let messageRepository, let userID else { return }

        isLoading = true
        do {
            conversations = try await messageRepository.fetchConversations(userID: userID)
        } catch {
            print("Error loading conversations: \(error)")
        }
        isLoading = false
    }

    func addConversation(_ conversation: Conversation) {
        // Check if conversation already exists
        if !conversations.contains(where: { $0.id == conversation.id }) {
            conversations.insert(conversation, at: 0)
        }
    }
}

#Preview {
    ConversationListView()
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
