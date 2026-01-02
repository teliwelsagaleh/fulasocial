//
//  PostDetailView.swift
//  Social Platform
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = PostDetailViewModel()
    @State private var newComment = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Post Content
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack(spacing: 12) {
                        AvatarView(name: post.author?.displayName ?? "?", size: 48)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.author?.displayName ?? "Unknown")
                                .font(.headline)

                            HStack(spacing: 4) {
                                Text(post.community?.name ?? "")
                                    .foregroundStyle(.blue)

                                Text("·")
                                    .foregroundStyle(.secondary)

                                Text(post.createdAt.timeAgoDisplay())
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }

                        Spacer()
                    }

                    // Content
                    Text(post.content)
                        .font(.body)

                    // Images
                    if !post.imageURLs.isEmpty {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 250)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            }
                    }

                    // Link Preview
                    if let linkURL = post.linkURL, !linkURL.isEmpty {
                        LinkPreviewCard(
                            url: linkURL,
                            title: post.linkPreviewTitle,
                            description: post.linkPreviewDescription
                        )
                    }

                    // Actions
                    HStack(spacing: 32) {
                        Button(action: { Task { await viewModel.toggleLike() } }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                    .foregroundStyle(viewModel.isLiked ? .red : .secondary)
                                Text("\(viewModel.likeCount)")
                            }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text("\(viewModel.comments.count)")
                        }
                        .foregroundStyle(.secondary)

                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // Comments Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.headline)
                        .padding(.horizontal)

                    if viewModel.comments.isEmpty {
                        Text("No comments yet. Be the first to comment!")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(viewModel.comments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                }

                Spacer(minLength: 80)
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Comment Input
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(.roundedBorder)

                Button(action: { Task { await addComment() } }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(newComment.isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.setup(
                post: post,
                postRepository: container.postRepository,
                userID: authService.currentUser?.id
            )
            await viewModel.loadComments()
        }
    }

    private func addComment() async {
        guard let userID = authService.currentUser?.id else { return }

        let comment = Comment(
            content: newComment,
            authorID: userID,
            postID: post.id,
            author: authService.currentUser
        )

        await viewModel.addComment(comment)
        newComment = ""
    }
}

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(name: comment.author?.displayName ?? "?", size: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.author?.displayName ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(comment.createdAt.timeAgoDisplay())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(comment.content)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@MainActor @Observable
class PostDetailViewModel {
    var comments: [Comment] = []
    var isLiked = false
    var likeCount = 0

    private var post: Post?
    private var postRepository: PostRepositoryProtocol?
    private var userID: UUID?

    func setup(post: Post, postRepository: PostRepositoryProtocol, userID: UUID?) {
        self.post = post
        self.postRepository = postRepository
        self.userID = userID
        self.likeCount = post.likeCount
    }

    func loadComments() async {
        guard let post, let postRepository else { return }

        do {
            comments = try await postRepository.fetchComments(postID: post.id)
        } catch {
            print("Error loading comments: \(error)")
        }
    }

    func toggleLike() async {
        guard let post, let postRepository, let userID else { return }

        do {
            if isLiked {
                try await postRepository.unlikePost(postID: post.id, userID: userID)
                likeCount -= 1
            } else {
                try await postRepository.likePost(postID: post.id, userID: userID)
                likeCount += 1
            }
            isLiked.toggle()
        } catch {
            print("Error toggling like: \(error)")
        }
    }

    func addComment(_ comment: Comment) async {
        guard let postRepository else { return }

        do {
            let created = try await postRepository.createComment(comment)
            comments.append(created)
        } catch {
            print("Error adding comment: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post(
            content: "Just discovered this amazing SwiftUI animation technique!",
            createdAt: Date().addingTimeInterval(-3600),
            authorID: UUID(),
            communityID: UUID(),
            likeCount: 42,
            commentCount: 5,
            author: User(username: "johndoe", displayName: "John Doe"),
            community: Community(name: "Swift Developers", description: "", category: "Technology", creatorID: UUID())
        ))
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
    }
}
