//
//  LegacyVerbDataManager.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Foundation
import Combine

// A version of the data manager that works on iOS 15/macOS 12
// This is a fallback for older systems that don't support SwiftData
class LegacyVerbDataManager: ObservableObject {
    @Published var verbs: [LegacyVerb] = []
    @Published var selectedVerbs: [LegacyVerb] = []
    @Published var isLoading = false
    @Published var error: String?

    init() {
        loadVerbs()
    }

    func loadVerbs() {
        isLoading = true

        // Load verbs from JSON
        do {
            guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json") else {
                self.error = "verbs.json file not found"
                self.isLoading = false
                return
            }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let verbJSONs = try decoder.decode([Verb.VerbJSON].self, from: data)

            self.verbs = verbJSONs.map { LegacyVerb(from: $0) }

            // Load selected verbs - now using nonisolated method
            let selectedIds = PersistenceManager.shared.getSelectedVerbIds()
            for index in 0..<self.verbs.count {
                if selectedIds.contains(self.verbs[index].id) {
                    self.verbs[index].isSelected = true
                    self.selectedVerbs.append(self.verbs[index])
                }
            }

            self.isLoading = false
        } catch {
            self.error = "Failed to load verbs: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func toggleVerbSelection(_ verb: LegacyVerb) {
        if let index = verbs.firstIndex(where: { $0.id == verb.id }) {
            verbs[index].isSelected.toggle()

            if verbs[index].isSelected {
                selectedVerbs.append(verbs[index])
            } else {
                selectedVerbs.removeAll { $0.id == verb.id }
            }

            // Save selected verb IDs - now using nonisolated method
            PersistenceManager.shared.saveSelectedVerbs(selectedVerbs.map { $0.id })
        }
    }

    func search(text: String) -> [LegacyVerb] {
        if text.isEmpty {
            return verbs
        }

        return verbs.filter { verb in
            let romaji = verb.romaji.lowercased()
            let meaning = verb.presentIndicativeMeaningPositive.lowercased()

            return romaji.contains(text.lowercased()) ||
                   meaning.contains(text.lowercased())
        }
    }
}

// Factory pattern remains the same
class DataManagerFactory {
    @MainActor static func createDataManager() -> Any {
        if isCompatibleWithSwiftData {
            return VerbDataManager()
        } else {
            return LegacyVerbDataManager()
        }
    }
}
