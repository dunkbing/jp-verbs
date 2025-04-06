//
//  manages.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Foundation
import SwiftData
import SwiftUI

// This class manages the database versioning, migration, etc.
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
}

// SwiftData only supports iOS 17 and macOS 14, so for backward compatibility
// This is a mock implementation for iOS 15/macOS 12
#if os(iOS)
    import UIKit
    let isCompatibleWithSwiftData =
        UIDevice.current.systemVersion.compare("17.0", options: .numeric) != .orderedAscending
#elseif os(macOS)
    import AppKit
    let isCompatibleWithSwiftData =
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 14
#endif

// For devices that don't support SwiftData - these methods are explicitly nonisolated
extension PersistenceManager {
    // Mark these legacy methods as nonisolated since they don't interact with SwiftData
    nonisolated func loadLegacyVerbs() -> [LegacyVerb] {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let verbJSONs = try decoder.decode([Verb.VerbJSON].self, from: data)

            return verbJSONs.map { LegacyVerb(from: $0) }
        } catch {
            print("Error loading verbs from JSON: \(error)")
            return []
        }
    }

    // For legacy systems, use UserDefaults to store selected verbs
    nonisolated func saveSelectedVerbs(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: "selectedVerbIds")
    }

    nonisolated func getSelectedVerbIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "selectedVerbIds") ?? []
    }
}
