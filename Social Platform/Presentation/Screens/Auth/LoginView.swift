//
//  LoginView.swift
//  Social Platform
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) var authService
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // Logo / Title
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)

                    Text("Social Platform")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Connect with communities that share your interests")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("Enter your username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button(action: login) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(username.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(username.isEmpty || isLoading)
                }
                .padding(.horizontal, 32)

                Spacer()

                Text("New here? Just enter a username to get started!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.login(username: username)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environment(DependencyContainer.preview.authService)
}
