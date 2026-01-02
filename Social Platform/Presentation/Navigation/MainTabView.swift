//
//  MainTabView.swift
//  Social Platform
//

import SwiftUI

struct MainTabView: View {
    @Environment(DependencyContainer.self) var container
    @Environment(AuthService.self) var authService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    }
                }
                .tag(0)

            CommunitiesListView()
                .tabItem {
                    Label {
                        Text("Communities")
                    } icon: {
                        Image(systemName: selectedTab == 1 ? "person.3.fill" : "person.3")
                    }
                }
                .tag(1)

            ConversationListView()
                .tabItem {
                    Label {
                        Text("Messages")
                    } icon: {
                        Image(systemName: selectedTab == 2 ? "message.fill" : "message")
                    }
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                    }
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
        .environment(DependencyContainer.preview)
        .environment(DependencyContainer.preview.authService)
}
