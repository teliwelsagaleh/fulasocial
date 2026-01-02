# Fula Social

A modern iOS social platform built with SwiftUI and Clean Architecture principles, featuring an Apple-inspired design language.

## Features

### 🏠 Home Feed
- Beautiful post cards with like, comment, and share functionality
- Pull-to-refresh for latest content
- Floating action button for quick post creation
- Smooth animations and interactions

### 💬 Messaging
- Real-time conversations with other users
- Clean chat interface with message bubbles
- Unread message indicators
- Create new conversations with any user
- Support for Enter key to send messages
- Test mode for simulating incoming messages

### 👥 Communities
- Browse and discover communities by category
- Create and join communities
- Community-specific feeds
- Member management
- Category filtering and search

### 👤 Profile
- User profiles with avatars
- Edit profile information
- View user posts and activity
- Interest tags

### 📝 Posts
- Create posts with text content
- Like and comment on posts
- Share posts with native iOS share sheet
- Link previews
- Post detail view with comments

## Design Philosophy

The app follows Apple's design principles:
- **Simplicity** - Clean, minimal interface with focus on content
- **Elegance** - Refined typography and subtle animations
- **Consistency** - System colors, fonts, and behaviors
- **Clarity** - Easy to read and understand
- **Quality** - Attention to micro-details and polish

### Design Highlights
- Sophisticated color palette using iOS system colors
- Continuous corner radius for premium feel
- Subtle dual-layer shadows for depth
- Spring physics animations
- SF Symbols throughout
- Proper spacing and breathing room

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Views, ViewModels, Components)   │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│          Domain Layer               │
│     (Models, Protocols, Rules)      │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│           Data Layer                │
│  (Repositories, DataSources, DTOs)  │
└─────────────────────────────────────┘
```

### Layer Responsibilities

**Presentation Layer**
- SwiftUI views and components
- ViewModels with `@Observable` macro
- Navigation and routing
- User interaction handling

**Domain Layer**
- Business logic and rules
- Domain models (User, Post, Community, Message)
- Repository protocols
- Platform-independent code

**Data Layer**
- Repository implementations
- Core Data persistence
- Data mappers (Entity ↔ Model)
- Local data sources

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** Clean Architecture + MVVM
- **Persistence:** Core Data
- **Dependency Injection:** Custom container
- **State Management:** `@Observable` macro
- **Minimum iOS:** 17.0+

## Project Structure

```
Social Platform/
├── App/
│   ├── Social_PlatformApp.swift
│   ├── DependencyContainer.swift
│   └── AuthService.swift
├── Domain/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Post.swift
│   │   ├── Community.swift
│   │   ├── Message.swift
│   │   └── Membership.swift
│   └── Protocols/
│       ├── UserRepositoryProtocol.swift
│       ├── PostRepositoryProtocol.swift
│       ├── CommunityRepositoryProtocol.swift
│       └── MessageRepositoryProtocol.swift
├── Data/
│   ├── Repositories/
│   ├── DataSources/Local/
│   └── Mappers/
├── Presentation/
│   ├── Screens/
│   │   ├── Home/
│   │   ├── Communities/
│   │   ├── Messages/
│   │   ├── Profile/
│   │   ├── Posts/
│   │   └── Auth/
│   ├── Components/
│   └── Navigation/
├── Core/
│   └── Persistence/
│       └── Social_Platform.xcdatamodeld
└── Mock/
    └── MockDataGenerator.swift
```

## Getting Started

### Requirements

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/teliwelsagaleh/fulasocial.git
cd fulasocial
```

2. Open the project in Xcode:
```bash
open "Social Platform.xcodeproj"
```

3. Select a simulator or device

4. Build and run (⌘R)

### First Launch

The app automatically generates mock data on first launch, including:
- 8 sample users
- 10 communities across different categories
- Multiple posts in each community
- 5 conversation threads with messages
- Community memberships

You'll be logged in as `alex_tech` (Alex Chen) by default.

## Key Features Implementation

### Messaging System
- **Conversation List:** View all your conversations sorted by recent activity
- **Chat Interface:** Real-time message sending and receiving
- **New Conversation:** Start chatting with any user
- **Read Receipts:** Track read/unread messages
- **Test Mode:** Simulate incoming messages for testing

### Post Interactions
- **Like Animation:** Smooth spring animation with symbol effects
- **Comments:** Navigate to post detail to view and add comments
- **Share:** Native iOS share sheet integration
- **Visual Feedback:** Immediate UI updates for all interactions

### Community Features
- **Category Filtering:** Browse communities by category
- **Search:** Find communities by name or description
- **Create:** Start new communities with customizable settings
- **Join/Leave:** Manage community memberships

## Design Patterns

- **Repository Pattern:** Abstraction over data sources
- **Dependency Injection:** Container-based DI
- **MVVM:** ViewModels manage presentation logic
- **Observer Pattern:** SwiftUI's `@Observable` for state management
- **Mapper Pattern:** Entity-to-Model transformation

## Future Enhancements

- [ ] Real authentication system
- [ ] Push notifications for messages
- [ ] Image upload for posts and profiles
- [ ] Video/audio message support
- [ ] Community moderator tools
- [ ] Post reactions (beyond like)
- [ ] Trending communities
- [ ] User search and discovery
- [ ] Dark mode refinements
- [ ] iPad optimization

## Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to open an issue.

## Author

**Abdoulie Teliwel Jallow**

## License

This project is private and proprietary.

---

Built with ❤️ using SwiftUI and Clean Architecture
