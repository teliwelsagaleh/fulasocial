//
//  HomeView.swift
//  Social Platform
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct HomeView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = HomeViewModel()
    @State private var showingCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if viewModel.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading your feed...")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if viewModel.posts.isEmpty {
                        EmptyFeedView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.posts) { post in
                                    PostCardView(
                                        post: post,
                                        onCommentTap: {
                                            viewModel.selectedPost = post
                                        },
                                        onShareTap: {
                                            viewModel.postToShare = post
                                        }
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectedPost = post
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 80) // Space for FAB
                        }
                        .refreshable {
                            await viewModel.loadPosts()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))

                // Floating Action Button - Refined Apple style
                Button(action: { showingCreatePost = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $viewModel.selectedPost) { post in
                PostDetailView(post: post)
            }
            .sheet(isPresented: $showingCreatePost) {
                if let community = viewModel.posts.first?.community {
                    CreatePostView(community: community) { newPost in
                        viewModel.addPost(newPost)
                    }
                }
            }
            .sheet(item: $viewModel.postToShare) { post in
                ShareSheet(items: [generateShareText(for: post)])
            }
            .task {
                viewModel.setup(
                    postRepository: container.postRepository,
                    userID: authService.currentUser?.id
                )
                await viewModel.loadPosts()
            }
        }
    }

    private func generateShareText(for post: Post) -> String {
        let author = post.author?.displayName ?? "Someone"
        let community = post.community?.name ?? "a community"
        return "\(author) shared in \(community):\n\n\(post.content)"
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper")
                .font(.system(size: 70, weight: .thin))
                .foregroundStyle(.secondary.opacity(0.5))
                .padding(.bottom, 8)

            VStack(spacing: 10) {
                Text("No Posts Yet")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Join communities to see posts\nand connect with others")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
    }
}

@MainActor @Observable
class HomeViewModel {
    var posts: [Post] = []
    var isLoading = false
    var error: Error?
    var selectedPost: Post?
    var postToShare: Post?

    private var postRepository: PostRepositoryProtocol?
    private var userID: UUID?

    func setup(postRepository: PostRepositoryProtocol, userID: UUID?) {
        self.postRepository = postRepository
        self.userID = userID
    }

    func loadPosts() async {
        guard let postRepository, let userID else { return }

        isLoading = true
        do {
            posts = try await postRepository.fetchHomeFeedPosts(userID: userID)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
}

#Preview {
    HomeView()
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
