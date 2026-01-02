//
//  Social_PlatformApp.swift
//  Social Platform
//

import SwiftUI

@main
struct Social_PlatformApp: App {
    @State private var container = DependencyContainer()
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isReady {
                    if container.authService.isAuthenticated {
                        MainTabView()
                            .environment(container)
                            .environment(container.authService)
                    } else {
                        LoginView()
                            .environment(container.authService)
                    }
                } else {
                    LaunchView()
                }
            }
            .task {
                await initialize()
            }
        }
    }

    private func initialize() async {
        // Seed mock data
        container.persistenceController.seedMockDataIfNeeded()

        // Restore user session
        await container.authService.restoreSession()

        // Small delay for smooth transition
        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            withAnimation {
                isReady = true
            }
        }
    }
}

struct LaunchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            ProgressView()
        }
    }
}
