//
//  CreateCommunityView.swift
//  Social Platform
//

import SwiftUI

struct CreateCommunityView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: CommunityCategory = .other
    @State private var isPrivate = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    let onCreated: (Community) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Community Info") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CommunityCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section {
                    Toggle("Private Community", isOn: $isPrivate)
                } footer: {
                    Text("Private communities require approval to join")
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task { await createCommunity() }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }

    private func createCommunity() async {
        guard let userID = authService.currentUser?.id else { return }

        isLoading = true
        errorMessage = nil

        let community = Community(
            name: name,
            description: description,
            category: selectedCategory.rawValue,
            isPrivate: isPrivate,
            creatorID: userID
        )

        do {
            let created = try await container.communityRepository.createCommunity(community)
            onCreated(created)
            dismiss()
        } catch {
            errorMessage = "Failed to create community: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    CreateCommunityView { _ in }
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
