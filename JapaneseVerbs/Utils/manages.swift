//
//  manages.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class PersistenceManager {
    static let shared = PersistenceManager()

    private init() {}

    func modelContainer() throws -> ModelContainer {
        let schema = Schema([Verb.self])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    func clearDatabase() throws {
        let container = try modelContainer()
        let context = container.mainContext

        try context.delete(model: Verb.self)
        try context.save()
    }

    func resetDatabase() {
        // Get the application support directory
        if let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first {
            do {
                // Find the SwiftData database files
                let fileURLs = try FileManager.default.contentsOfDirectory(
                    at: appSupportURL,
                    includingPropertiesForKeys: nil)

                // Delete any SwiftData database files
                for fileURL in fileURLs where fileURL.lastPathComponent.contains("VerbModel") {
                    try FileManager.default.removeItem(at: fileURL)
                }

                print("Database files deleted successfully")
            } catch {
                print("Failed to delete database files: \(error)")
            }
        }
    }
}
