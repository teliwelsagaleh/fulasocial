//
//  ProfileView.swift
//  Social Platform
//

import SwiftUI

struct ProfileView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = ProfileViewModel()
    @State private var showingEditSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 100, height: 100)
                            .overlay {
                                Text(viewModel.user?.displayName.prefix(1).uppercased() ?? "?")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }

                        VStack(spacing: 4) {
                            Text(viewModel.user?.displayName ?? "Unknown")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("@\(viewModel.user?.username ?? "unknown")")
                                .foregroundStyle(.secondary)
                        }

                        if let bio = viewModel.user?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Interests
                        if let interests = viewModel.user?.interests, !interests.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundStyle(.blue)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()

                    Divider()

                    // Stats
                    HStack(spacing: 40) {
                        StatView(value: viewModel.communitiesCount, label: "Communities")
                        StatView(value: viewModel.postsCount, label: "Posts")
                    }
                    .padding()

                    Divider()

                    // My Communities
                    VStack(alignment: .leading, spacing: 12) {
                        Text("My Communities")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.myCommunities.isEmpty {
                            Text("You haven't joined any communities yet")
                                .foregroundStyle(.secondary)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.myCommunities) { community in
                                        NavigationLink(destination: CommunityDetailView(community: community)) {
                                            MiniCommunityCard(community: community)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingEditSheet = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                        }

                        Button(role: .destructive, action: { authService.logout() }) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(user: viewModel.user) { updatedUser in
                    viewModel.user = updatedUser
                }
            }
            .task {
                viewModel.setup(
                    communityRepository: container.communityRepository,
                    postRepository: container.postRepository,
                    user: authService.currentUser
                )
                await viewModel.loadData()
            }
        }
    }
}

struct StatView: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MiniCommunityCard: View {
    let community: Community

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: CommunityCategory(rawValue: community.category)?.icon ?? "person.3")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

            Text(community.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

// Simple flow layout for interests
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        let maxX = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxX, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX)
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

@MainActor @Observable
class ProfileViewModel {
    var user: User?
    var myCommunities: [Community] = []
    var postsCount = 0
    var communitiesCount = 0

    private var communityRepository: CommunityRepositoryProtocol?
    private var postRepository: PostRepositoryProtocol?

    func setup(communityRepository: CommunityRepositoryProtocol,
               postRepository: PostRepositoryProtocol,
               user: User?) {
        self.communityRepository = communityRepository
        self.postRepository = postRepository
        self.user = user
    }

    func loadData() async {
        guard let user, let communityRepository, let postRepository else { return }

        do {
            myCommunities = try await communityRepository.fetchUserCommunities(userID: user.id)
            communitiesCount = myCommunities.count

            let posts = try await postRepository.fetchUserPosts(userID: user.id)
            postsCount = posts.count
        } catch {
            print("Error loading profile data: \(error)")
        }
    }
}

#Preview {
    ProfileView()
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
