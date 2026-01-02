//
//  PostCardView.swift
//  Social Platform
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    var onCommentTap: (() -> Void)?
    var onShareTap: (() -> Void)?

    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 14) {
                // Author Avatar - clean, minimal
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Text(post.author?.displayName.prefix(1).uppercased() ?? "?")
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(post.author?.displayName ?? "Unknown")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 5) {
                        Text(post.community?.name ?? "")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)

                        Text("·")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary.opacity(0.5))

                        Text(post.createdAt.timeAgoDisplay())
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Menu button
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 34, height: 34)
                }
            }

            // Content
            Text(post.content)
                .font(.system(size: 16, design: .default))
                .lineSpacing(4)
                .foregroundStyle(.primary)

            // Images
            if !post.imageURLs.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
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
            HStack(spacing: 24) {
                // Like button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                    }
                }) {
                    HStack(spacing: 7) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(isLiked ? .red : .primary.opacity(0.6))
                            .symbolEffect(.bounce, value: isLiked)
                        if post.likeCount > 0 || isLiked {
                            Text("\(post.likeCount + (isLiked ? 1 : 0))")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Comment button
                Button(action: { onCommentTap?() }) {
                    HStack(spacing: 7) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.primary.opacity(0.6))
                        if post.commentCount > 0 {
                            Text("\(post.commentCount)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Share button
                Button(action: { onShareTap?() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.primary.opacity(0.6))
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 2)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
        )
    }
}

struct ActionButton: View {
    let icon: String
    let count: Int?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            if let count, count > 0 {
                Text("\(count)")
                    .font(.caption)
            }
        }
    }
}

struct LinkPreviewCard: View {
    let url: String
    let title: String?
    let description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }

            if let description {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Text(url)
                .font(.caption2)
                .foregroundStyle(.blue)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    PostCardView(post: Post(
        content: "Just discovered this amazing SwiftUI animation technique! Check it out!",
        createdAt: Date().addingTimeInterval(-3600),
        authorID: UUID(),
        communityID: UUID(),
        likeCount: 42,
        commentCount: 12,
        author: User(username: "johndoe", displayName: "John Doe"),
        community: Community(name: "Swift Developers", description: "", category: "Technology", creatorID: UUID())
    ))
    .padding()
}
