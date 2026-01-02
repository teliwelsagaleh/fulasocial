//
//  CommunitiesListView.swift
//  Social Platform
//

import SwiftUI

struct CommunitiesListView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var viewModel = CommunitiesListViewModel()
    @State private var showingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading communities...")
                } else if viewModel.filteredCommunities.isEmpty {
                    EmptyCommunitiesView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    CategoryChip(
                                        title: "All",
                                        isSelected: viewModel.selectedCategory == nil
                                    ) {
                                        viewModel.selectedCategory = nil
                                    }

                                    ForEach(CommunityCategory.allCases, id: \.self) { category in
                                        CategoryChip(
                                            title: category.rawValue,
                                            icon: category.icon,
                                            isSelected: viewModel.selectedCategory == category.rawValue
                                        ) {
                                            viewModel.selectedCategory = category.rawValue
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)

                            // Communities List
                            ForEach(viewModel.filteredCommunities) { community in
                                NavigationLink(destination: CommunityDetailView(community: community)) {
                                    CommunityCardView(community: community)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .refreshable {
                        await viewModel.loadCommunities()
                    }
                }
            }
            .navigationTitle("Communities")
            .searchable(text: $viewModel.searchText, prompt: "Search communities")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateCommunityView { community in
                    viewModel.addCommunity(community)
                }
            }
            .task {
                viewModel.setup(
                    communityRepository: container.communityRepository,
                    userID: authService.currentUser?.id
                )
                await viewModel.loadCommunities()
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

struct EmptyCommunitiesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No communities found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Be the first to create one!")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

@MainActor @Observable
class CommunitiesListViewModel {
    var communities: [Community] = []
    var isLoading = false
    var searchText = ""
    var selectedCategory: String?

    private var communityRepository: CommunityRepositoryProtocol?
    private var userID: UUID?

    var filteredCommunities: [Community] {
        var result = communities

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    func setup(communityRepository: CommunityRepositoryProtocol, userID: UUID?) {
        self.communityRepository = communityRepository
        self.userID = userID
    }

    func loadCommunities() async {
        guard let communityRepository else { return }

        isLoading = true
        do {
            communities = try await communityRepository.fetchAllCommunities()
        } catch {
            print("Error loading communities: \(error)")
        }
        isLoading = false
    }

    func addCommunity(_ community: Community) {
        communities.insert(community, at: 0)
    }
}

#Preview {
    CommunitiesListView()
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
