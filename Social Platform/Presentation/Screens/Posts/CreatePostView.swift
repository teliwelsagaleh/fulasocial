//
//  CreatePostView.swift
//  Social Platform
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    let community: Community
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @Environment(\.dismiss) var dismiss

    @State private var content = ""
    @State private var linkURL = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    let onCreated: (Post) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Community Badge
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: CommunityCategory(rawValue: community.category)?.icon ?? "person.3")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }

                    Text("Posting to \(community.name)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                // Content Editor
                TextEditor(text: $content)
                    .padding()
                    .frame(minHeight: 150)

                Divider()

                // Link Input
                HStack {
                    Image(systemName: "link")
                        .foregroundStyle(.secondary)

                    TextField("Add a link (optional)", text: $linkURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
                .padding()

                Divider()

                // Photo Picker
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 4, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Add Photos")
                        Spacer()
                        if !selectedPhotos.isEmpty {
                            Text("\(selectedPhotos.count) selected")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task { await createPost() }
                    }
                    .disabled(content.isEmpty || isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func createPost() async {
        guard let userID = authService.currentUser?.id else { return }

        isLoading = true
        errorMessage = nil

        let post = Post(
            content: content,
            linkURL: linkURL.isEmpty ? nil : linkURL,
            authorID: userID,
            communityID: community.id,
            author: authService.currentUser,
            community: community
        )

        do {
            let created = try await container.postRepository.createPost(post)
            // Add author and community info for display
            var displayPost = created
            displayPost.author = authService.currentUser
            displayPost.community = community
            onCreated(displayPost)
            dismiss()
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

#Preview {
    CreatePostView(community: Community(
        name: "Swift Developers",
        description: "",
        category: "Technology",
        creatorID: UUID()
    )) { _ in }
    .environment(DependencyContainer.preview)
    .environment(DependencyContainer.preview.authService)
}
