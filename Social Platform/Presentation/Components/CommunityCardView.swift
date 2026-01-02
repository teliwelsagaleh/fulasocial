//
//  CommunityCardView.swift
//  Social Platform
//

import SwiftUI

struct CommunityCardView: View {
    let community: Community

    var body: some View {
        HStack(spacing: 16) {
            // Community Icon
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: CommunityCategory(rawValue: community.category)?.icon ?? "person.3")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(community.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(community.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(community.memberCount)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(community.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    VStack {
        CommunityCardView(community: Community(
            name: "Swift Developers",
            description: "A community for iOS developers to share knowledge and learn together",
            category: "Technology",
            creatorID: UUID(),
            memberCount: 1234
        ))

        CommunityCardView(community: Community(
            name: "Digital Artists Guild",
            description: "Share your digital artwork and get feedback",
            category: "Art",
            creatorID: UUID(),
            memberCount: 567
        ))
    }
    .padding()
}
