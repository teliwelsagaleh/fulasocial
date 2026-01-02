//
//  Persistence.swift
//  Social Platform
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Generate mock data for previews
        let generator = MockDataGenerator(context: viewContext)
        try? generator.generateAllMockData()

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Social_Platform")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // Seed mock data on first launch
    func seedMockDataIfNeeded() {
        let context = container.viewContext
        let generator = MockDataGenerator(context: context)

        do {
            try generator.generateAllMockData()
        } catch {
            print("Failed to seed mock data: \(error)")
        }
    }
}
