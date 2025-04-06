//
//  VerbDataManager.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
class VerbDataManager: ObservableObject {
    @Published var verbs: [Verb] = []
    @Published var selectedVerbs: [Verb] = []
    @Published var isLoading = false
    @Published var error: String?

    private var modelContainer: ModelContainer?

    init() {
        setupModelContainer()
    }

    private func setupModelContainer() {
        do {
            let schema = Schema([Verb.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            self.error = "Failed to create model container: \(error.localizedDescription)"
        }
    }

    func loadVerbs() {
        guard let modelContainer = modelContainer else {
            self.error = "Model container not initialized"
            return
        }

        isLoading = true

        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<Verb>()

        do {
            let existingVerbs = try context.fetch(descriptor)

            if existingVerbs.isEmpty {
                // Load from JSON file if no verbs in the database
                loadVerbsFromJSON(context: context)
            } else {
                self.verbs = existingVerbs
                self.isLoading = false
            }
        } catch {
            self.error = "Failed to fetch verbs: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    private func loadVerbsFromJSON(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json") else {
            self.error = "verbs.json file not found"
            self.isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let verbJSONs = try decoder.decode([Verb.VerbJSON].self, from: data)

            var newVerbs: [Verb] = []

            for verbJSON in verbJSONs {
                let verb = Verb.fromJSON(verbJSON)
                context.insert(verb)
                newVerbs.append(verb)
            }

            try context.save()

            self.verbs = newVerbs
            self.isLoading = false
        } catch {
            self.error = "Failed to load verbs from JSON: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func toggleVerbSelection(_ verb: Verb) {
        if let index = verbs.firstIndex(where: { $0.id == verb.id }) {
            verbs[index].isSelected.toggle()

            if verbs[index].isSelected {
                selectedVerbs.append(verbs[index])
            } else {
                selectedVerbs.removeAll { $0.id == verb.id }
            }
        }
    }

    func search(text: String) -> [Verb] {
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
