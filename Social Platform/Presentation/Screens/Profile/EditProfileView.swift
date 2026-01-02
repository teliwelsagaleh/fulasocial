//
//  EditProfileView.swift
//  Social Platform
//

import SwiftUI

struct EditProfileView: View {
    @Environment(AuthService.self) var authService
    @Environment(\.dismiss) var dismiss

    let user: User?
    let onSaved: (User) -> Void

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var selectedInterests: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let allInterests = CommunityCategory.allCases.map { $0.rawValue }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Display Name", text: $displayName)

                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Interests") {
                    ForEach(allInterests, id: \.self) { interest in
                        Button(action: { toggleInterest(interest) }) {
                            HStack {
                                if let category = CommunityCategory(rawValue: interest) {
                                    Image(systemName: category.icon)
                                        .foregroundStyle(.blue)
                                        .frame(width: 24)
                                }

                                Text(interest)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if selectedInterests.contains(interest) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveProfile() }
                    }
                    .disabled(displayName.isEmpty || isLoading)
                }
            }
            .onAppear {
                if let user {
                    displayName = user.displayName
                    bio = user.bio ?? ""
                    selectedInterests = Set(user.interests)
                }
            }
        }
    }

    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    private func saveProfile() async {
        guard var updatedUser = user else { return }

        isLoading = true
        errorMessage = nil

        updatedUser.displayName = displayName
        updatedUser.bio = bio.isEmpty ? nil : bio
        updatedUser.interests = Array(selectedInterests)

        do {
            try await authService.updateProfile(updatedUser)
            onSaved(updatedUser)
            dismiss()
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    EditProfileView(user: User(
        username: "johndoe",
        displayName: "John Doe",
        bio: "iOS Developer",
        interests: ["Technology", "Gaming"]
    )) { _ in }
    .environment(DependencyContainer.preview.authService)
}
