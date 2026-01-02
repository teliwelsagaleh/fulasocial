//
//  MockDataGenerator.swift
//  Social Platform
//

import Foundation
import CoreData

final class MockDataGenerator {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func generateAllMockData() throws {
        // Check if data already exists
        let userRequest = UserEntity.fetchRequest()
        let userCount = try context.count(for: userRequest)
        guard userCount == 0 else { return }

        // Create users
        let users = try createUsers()

        // Create communities
        let communities = try createCommunities(creators: users)

        // Add memberships
        try addMemberships(users: users, communities: communities)

        // Create posts
        try createPosts(users: users, communities: communities)

        // Create conversations and messages
        try createConversationsAndMessages(users: users)

        try context.save()
        print("Mock data generated successfully!")
    }

    private func createUsers() throws -> [UserEntity] {
        let userData = [
            ("alex_tech", "Alex Chen", "Technology enthusiast and iOS developer", ["Technology", "Gaming", "Science"]),
            ("sarah_art", "Sarah Miller", "Digital artist and creative soul", ["Art", "Photography", "Music"]),
            ("mike_fitness", "Mike Johnson", "Fitness coach and health advocate", ["Fitness", "Sports", "Food"]),
            ("emma_travel", "Emma Wilson", "World traveler and adventure seeker", ["Travel", "Photography", "Nature"]),
            ("david_books", "David Brown", "Bookworm and aspiring writer", ["Books", "Movies", "Art"]),
            ("lisa_music", "Lisa Anderson", "Music producer and DJ", ["Music", "Technology", "Art"]),
            ("james_gaming", "James Taylor", "Professional gamer and streamer", ["Gaming", "Technology", "Movies"]),
            ("nina_food", "Nina Garcia", "Chef and food blogger", ["Food", "Travel", "Photography"])
        ]

        var users: [UserEntity] = []

        for (username, displayName, bio, interests) in userData {
            let user = UserEntity(context: context)
            user.id = UUID()
            user.username = username
            user.displayName = displayName
            user.bio = bio
            user.interests = interests
            user.createdAt = Date().addingTimeInterval(-Double.random(in: 86400...2592000))
            users.append(user)
        }

        return users
    }

    private func createCommunities(creators: [UserEntity]) throws -> [CommunityEntity] {
        let communityData = [
            ("Swift Developers", "A community for iOS and macOS developers using Swift", "Technology"),
            ("Digital Artists Guild", "Share your digital artwork and get feedback from fellow artists", "Art"),
            ("Indie Game Club", "Discover and discuss the best indie games", "Gaming"),
            ("Fitness Warriors", "Motivation, tips, and support for your fitness journey", "Fitness"),
            ("World Travelers", "Share your adventures and travel tips from around the globe", "Travel"),
            ("Music Producers Hub", "Connect with fellow producers and share your tracks", "Music"),
            ("Bookworms United", "Discuss your favorite books and discover new reads", "Books"),
            ("Food Lovers", "Share recipes, restaurant recommendations, and food photography", "Food"),
            ("Photography Enthusiasts", "Tips, critiques, and inspiration for photographers", "Photography"),
            ("Science & Technology", "Explore the latest in science and tech innovations", "Science")
        ]

        var communities: [CommunityEntity] = []

        for (index, (name, description, category)) in communityData.enumerated() {
            let community = CommunityEntity(context: context)
            community.id = UUID()
            community.name = name
            community.descriptionText = description
            community.category = category
            community.isPrivate = false
            community.memberCount = Int32.random(in: 50...5000)
            community.createdAt = Date().addingTimeInterval(-Double.random(in: 604800...7776000))
            community.creator = creators[index % creators.count]
            communities.append(community)
        }

        return communities
    }

    private func addMemberships(users: [UserEntity], communities: [CommunityEntity]) throws {
        for user in users {
            // Each user joins 2-5 random communities based on interests
            let userInterests = user.interests ?? []
            let relevantCommunities = communities.filter { community in
                userInterests.contains(community.category ?? "")
            }

            let communitiesToJoin = relevantCommunities.isEmpty ?
                Array(communities.shuffled().prefix(3)) :
                Array(relevantCommunities.prefix(5))

            for community in communitiesToJoin {
                let membership = CommunityMembershipEntity(context: context)
                membership.id = UUID()
                membership.user = user
                membership.community = community
                membership.role = community.creator == user ? "owner" : "member"
                membership.joinedAt = Date().addingTimeInterval(-Double.random(in: 86400...604800))
            }
        }
    }

    private func createPosts(users: [UserEntity], communities: [CommunityEntity]) throws {
        let postContents = [
            "Just discovered an amazing new technique! Can't wait to share more about it.",
            "What are your thoughts on the latest updates? I'm really impressed with the improvements.",
            "Sharing my latest project - would love to hear your feedback!",
            "Quick tip that changed my workflow: always plan before you execute.",
            "Had an incredible experience today. This community is amazing!",
            "Looking for recommendations - what's your favorite tool for getting started?",
            "Finally finished my project after weeks of work. Feeling accomplished!",
            "Pro tip: consistency is key. Small steps lead to big results.",
            "Anyone else excited about the upcoming event? Count me in!",
            "Just joined this community and already learning so much. Thanks everyone!",
            "Here's what I learned this week - hope it helps someone else!",
            "Collaboration opportunity! Who wants to work on something together?",
            "The journey of a thousand miles begins with a single step. Started mine today!",
            "Grateful for this supportive community. You all inspire me daily.",
            "New to this, any advice for beginners? Excited to learn!"
        ]

        for community in communities {
            let communityMembers = (community.memberships as? Set<CommunityMembershipEntity>)?
                .compactMap { $0.user } ?? []

            guard !communityMembers.isEmpty else { continue }

            // Create 3-8 posts per community
            let postCount = Int.random(in: 3...8)

            for _ in 0..<postCount {
                let post = PostEntity(context: context)
                post.id = UUID()
                post.content = postContents.randomElement()!
                post.createdAt = Date().addingTimeInterval(-Double.random(in: 3600...604800))
                post.author = communityMembers.randomElement()
                post.community = community
                post.likeCount = Int32.random(in: 0...100)
                post.commentCount = Int32.random(in: 0...20)

                // Some posts have links
                if Bool.random() {
                    post.linkURL = "https://example.com/article/\(UUID().uuidString.prefix(8))"
                    post.linkPreviewTitle = "Interesting Article Title"
                    post.linkPreviewDescription = "A brief description of what this article covers..."
                }

                // Create some comments
                let commentCount = Int.random(in: 0...5)
                for _ in 0..<commentCount {
                    let comment = CommentEntity(context: context)
                    comment.id = UUID()
                    comment.content = ["Great post!", "Thanks for sharing!", "This is really helpful!", "I agree!", "Interesting perspective!"].randomElement()!
                    comment.createdAt = post.createdAt!.addingTimeInterval(Double.random(in: 60...86400))
                    comment.author = communityMembers.randomElement()
                    comment.post = post
                }
            }
        }
    }

    private func createConversationsAndMessages(users: [UserEntity]) throws {
        guard users.count >= 2 else { return }

        // Create conversations between the first user and several other users
        let currentUser = users[0] // alex_tech
        let otherUsers = Array(users.dropFirst().prefix(5)) // First 5 other users

        let messageTemplates = [
            ["Hey! How are you doing?", "I'm great! Just working on a new project. How about you?", "That's awesome! I'd love to hear more about it."],
            ["Did you see the latest update?", "Yes! It's incredible. The new features are amazing.", "I know! Can't wait to try them out."],
            ["Want to grab coffee sometime?", "Sure! How about tomorrow afternoon?", "Sounds perfect! See you then."],
            ["Thanks for your help yesterday!", "No problem! Happy to help anytime.", "You're the best!"],
            ["What are you working on these days?", "Building a new app. It's been challenging but fun!", "That sounds exciting! Let me know if you need any feedback."]
        ]

        for (index, otherUser) in otherUsers.enumerated() {
            // Create conversation
            let conversation = ConversationEntity(context: context)
            conversation.id = UUID()
            conversation.participantIDs = [currentUser.id!, otherUser.id!]
            conversation.participants = NSSet(array: [currentUser, otherUser])

            // Create messages for this conversation
            let messages = messageTemplates[index % messageTemplates.count]
            var lastMessageTime = Date().addingTimeInterval(-Double.random(in: 3600...86400))

            for (msgIndex, messageContent) in messages.enumerated() {
                let message = MessageEntity(context: context)
                message.id = UUID()
                message.content = messageContent
                message.sentAt = lastMessageTime
                message.isRead = msgIndex < messages.count - 1 // Last message is unread
                message.sender = msgIndex.isMultiple(of: 2) ? currentUser : otherUser
                message.conversation = conversation

                lastMessageTime = lastMessageTime.addingTimeInterval(Double.random(in: 300...1800))
            }

            conversation.lastMessageAt = lastMessageTime
        }
    }
}
