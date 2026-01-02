//
//  AuthService.swift
//  Social Platform
//

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class AuthService {
    private(set) var currentUser: User?
    private(set) var isAuthenticated = false

    private var storedUserID: String {
        get { UserDefaults.standard.string(forKey: "currentUserID") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "currentUserID") }
    }

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func restoreSession() async {
        guard !storedUserID.isEmpty,
              let uuid = UUID(uuidString: storedUserID) else { return }

        do {
            if let user = try await userRepository.fetchUser(id: uuid) {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("Failed to restore session: \(error)")
        }
    }

    func login(username: String) async throws {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedUsername.isEmpty else {
            throw AuthError.invalidUsername
        }

        // Try to find existing user
        if let existingUser = try await userRepository.fetchUser(username: trimmedUsername) {
            self.currentUser = existingUser
            self.isAuthenticated = true
            self.storedUserID = existingUser.id.uuidString
            return
        }

        // Create new user
        let newUser = User(
            username: trimmedUsername,
            displayName: trimmedUsername.capitalized
        )

        let createdUser = try await userRepository.createUser(newUser)
        self.currentUser = createdUser
        self.isAuthenticated = true
        self.storedUserID = createdUser.id.uuidString
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        storedUserID = ""
    }

    func updateProfile(_ user: User) async throws {
        let updatedUser = try await userRepository.updateUser(user)
        self.currentUser = updatedUser
    }
}

enum AuthError: LocalizedError {
    case invalidUsername
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            return "Please enter a valid username"
        case .userNotFound:
            return "User not found"
        }
    }
}
