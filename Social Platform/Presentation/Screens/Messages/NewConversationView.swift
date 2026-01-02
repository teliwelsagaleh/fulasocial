//
//  NewConversationView.swift
//  Social Platform
//

import SwiftUI

struct NewConversationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = NewConversationViewModel()
    @State private var searchText = ""

    let onConversationCreated: (Conversation) -> Void

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return viewModel.users
        }
        return viewModel.users.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else if filteredUsers.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text("No users found")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                } else {
                    List(filteredUsers) { user in
                        Button(action: {
                            Task {
                                await createConversation(with: user)
                            }
                        }) {
                            HStack(spacing: 12) {
                                AvatarView(
                                    name: user.displayName,
                                    size: 50,
                                    imageURL: user.avatarURL
                                )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.displayName)
                                        .font(.headline)

                                    Text("@\(user.username)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search users")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                viewModel.setup(
                    userRepository: container.userRepository,
                    currentUserID: authService.currentUser?.id
                )
                await viewModel.loadUsers()
            }
        }
    }

    private func createConversation(with user: User) async {
        guard let currentUserID = authService.currentUser?.id else { return }

        viewModel.isCreating = true
        do {
            let conversation = try await container.messageRepository.findOrCreateConversation(
                participantIDs: [currentUserID, user.id]
            )
            onConversationCreated(conversation)
            dismiss()
        } catch {
            print("Error creating conversation: \(error)")
        }
        viewModel.isCreating = false
    }
}

@MainActor @Observable
class NewConversationViewModel {
    var users: [User] = []
    var isLoading = false
    var isCreating = false

    private var userRepository: UserRepositoryProtocol?
    private var currentUserID: UUID?

    func setup(userRepository: UserRepositoryProtocol, currentUserID: UUID?) {
        self.userRepository = userRepository
        self.currentUserID = currentUserID
    }

    func loadUsers() async {
        guard let userRepository, let currentUserID else { return }

        isLoading = true
        do {
            // Fetch all users except the current user
            let allUsers = try await userRepository.fetchAllUsers()
            users = allUsers.filter { $0.id != currentUserID }
        } catch {
            print("Error loading users: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    NewConversationView { _ in }
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
