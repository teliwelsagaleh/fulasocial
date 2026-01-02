//
//  CommunityDetailView.swift
//  Social Platform
//

import SwiftUI

struct CommunityDetailView: View {
    let community: Community
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = CommunityDetailViewModel()
    @State private var showingCreatePost = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: CommunityCategory(rawValue: community.category)?.icon ?? "person.3")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)
                        }

                    VStack(spacing: 4) {
                        Text(community.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(community.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 24) {
                        StatView(value: community.memberCount, label: "Members")
                        StatView(value: viewModel.posts.count, label: "Posts")
                    }

                    // Join/Leave Button
                    Button(action: { Task { await viewModel.toggleMembership() } }) {
                        HStack {
                            Image(systemName: viewModel.isMember ? "checkmark" : "plus")
                            Text(viewModel.isMember ? "Joined" : "Join")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isMember ? Color(.systemGray5) : Color.blue)
                        .foregroundStyle(viewModel.isMember ? Color.primary : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // Posts Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Posts")
                            .font(.headline)

                        Spacer()

                        if viewModel.isMember {
                            Button(action: { showingCreatePost = true }) {
                                Label("New Post", systemImage: "plus")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    if viewModel.posts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)

                            Text("No posts yet")
                                .foregroundStyle(.secondary)

                            if viewModel.isMember {
                                Text("Be the first to post!")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.posts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCardView(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(community: community) { post in
                viewModel.addPost(post)
            }
        }
        .task {
            viewModel.setup(
                community: community,
                communityRepository: container.communityRepository,
                postRepository: container.postRepository,
                userID: authService.currentUser?.id
            )
            await viewModel.loadData()
        }
    }
}

@MainActor @Observable
class CommunityDetailViewModel {
    var posts: [Post] = []
    var isMember = false
    var isLoading = false

    private var community: Community?
    private var communityRepository: CommunityRepositoryProtocol?
    private var postRepository: PostRepositoryProtocol?
    private var userID: UUID?

    func setup(community: Community,
               communityRepository: CommunityRepositoryProtocol,
               postRepository: PostRepositoryProtocol,
               userID: UUID?) {
        self.community = community
        self.communityRepository = communityRepository
        self.postRepository = postRepository
        self.userID = userID
    }

    func loadData() async {
        guard let community, let communityRepository, let postRepository, let userID else { return }

        isLoading = true
        do {
            isMember = try await communityRepository.isUserMember(communityID: community.id, userID: userID)
            posts = try await postRepository.fetchPosts(communityID: community.id)
        } catch {
            print("Error loading community data: \(error)")
        }
        isLoading = false
    }

    func toggleMembership() async {
        guard let community, let communityRepository, let userID else { return }

        do {
            if isMember {
                try await communityRepository.leaveCommunity(communityID: community.id, userID: userID)
            } else {
                try await communityRepository.joinCommunity(communityID: community.id, userID: userID)
            }
            isMember.toggle()
        } catch {
            print("Error toggling membership: \(error)")
        }
    }

    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(community: Community(
            name: "Swift Developers",
            description: "A community for iOS developers",
            category: "Technology",
            creatorID: UUID(),
            memberCount: 1234
        ))
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
    }
}
