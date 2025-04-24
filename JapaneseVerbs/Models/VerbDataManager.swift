//
//  VerbDataManager.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import Combine
import Foundation
import SwiftData

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
        let descriptor = FetchDescriptor<Verb>(sortBy: [SortDescriptor(\.romaji)])

        do {
            let existingVerbs = try context.fetch(descriptor)

            if existingVerbs.isEmpty {
                print("fetching from verbs.json")
                try loadVerbsFromJSON(context: context)
            } else {
                print("fetched from db")
                self.verbs = existingVerbs
                loadSelectedVerbs(context: context)
                self.isLoading = false
            }
        } catch {
            self.error = "Failed to fetch verbs: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    private func loadSelectedVerbs(context: ModelContext) {
        // Fetch selected verb IDs from UserDefaults
        let selectedVerbIds = UserDefaults.standard.stringArray(forKey: "selectedVerbIds") ?? []

        // Filter and set selected verbs
        self.selectedVerbs = verbs.filter { selectedVerbIds.contains($0.id) }

        // Ensure each selected verb has its isSelected flag set
        for index in 0..<verbs.count {
            verbs[index].isSelected = selectedVerbIds.contains(verbs[index].id)
        }
    }

    private func loadVerbsFromJSON(context: ModelContext) throws {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json") else {
            throw NSError(
                domain: "VerbDataManager", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "verbs.json file not found"])
        }

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

        // sort by romaji
        self.verbs = newVerbs.sorted { $0.romaji < $1.romaji }
        loadSelectedVerbs(context: context)

        self.isLoading = false
    }

    func toggleVerbSelection(_ verb: Verb) {
        if let index = verbs.firstIndex(where: { $0.id == verb.id }) {
            verbs[index].isSelected.toggle()

            if verbs[index].isSelected {
                selectedVerbs.append(verbs[index])
            } else {
                selectedVerbs.removeAll { $0.id == verb.id }
            }

            selectedVerbs.sort { $0.romaji < $1.romaji }

            let selectedVerbIds = selectedVerbs.map { $0.id }
            UserDefaults.standard.set(selectedVerbIds, forKey: "selectedVerbIds")
        }
    }

    func search(text: String, filters: [SearchFilter]? = nil) -> [Verb] {
        if text.isEmpty {
            return verbs
        }

        let searchText = text.lowercased()
        let enabledFilters = filters?.filter { $0.isSelected } ?? []

        if enabledFilters.isEmpty {
            return []
        }

        // Search only in selected fields
        return verbs.filter { verb in
            for filter in enabledFilters {
                switch filter.type {
                case .romaji:
                    if verb.romaji.lowercased().contains(searchText) {
                        return true
                    }
                case .meaning:
                    if verb.presentIndicativeMeaningPositive.lowercased().contains(searchText)
                        || verb.presentIndicativeMeaningNegative.lowercased().contains(searchText)
                    {
                        return true
                    }
                case .japanese:
                    // Check all Japanese forms
                    if verb.presentIndicativePlainPositive.contains(where: {
                        $0.lowercased().contains(searchText)
                    })
                        || verb.presentIndicativePlainNegative.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.presentIndicativePolitePositive.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.presentIndicativePoliteNegative.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.pastIndicativePlainPositive.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.pastIndicativePlainNegative.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.pastIndicativePolitePositive.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                        || verb.pastIndicativePoliteNegative.contains(where: {
                            $0.lowercased().contains(searchText)
                        })
                    {
                        return true
                    }
                case .stem:
                    if verb.stem.lowercased().contains(searchText) {
                        return true
                    }
                case .teForm:
                    if verb.teForm.lowercased().contains(searchText) {
                        return true
                    }
                case .infinitive:
                    if verb.infinitive.lowercased().contains(searchText) {
                        return true
                    }
                case .verbClass:
                    if verb.verbClass.lowercased().contains(searchText) {
                        return true
                    }
                }
            }
            return false
        }
    }
}
