//
//  SearchFilter.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 24/4/25.
//

import SwiftUI
import TikimUI

enum SearchFilterType: String, CaseIterable, Identifiable {
    case romaji = "Romaji"
    case meaning = "Meaning"
    case japanese = "Japanese"
    case stem = "Stem"
    case teForm = "Te Form"
    case infinitive = "Infinitive"
    case verbClass = "Verb Class"

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .romaji:
            return "Roman alphabet representation"
        case .meaning:
            return "English translation"
        case .japanese:
            return "Japanese characters (all forms)"
        case .stem:
            return "Verb stem"
        case .teForm:
            return "Te form of the verb"
        case .infinitive:
            return "Infinitive form"
        case .verbClass:
            return "Verb classification (godan, ichidan)"
        }
    }
}

@MainActor
class SearchFilterManager: ObservableObject {
    @AppStorage("romaji_filter") private var romajiEnabled: Bool = true
    @AppStorage("meaning_filter") private var meaningEnabled: Bool = true
    @AppStorage("japanese_filter") private var japaneseEnabled: Bool = true
    @AppStorage("stem_filter") private var stemEnabled: Bool = true
    @AppStorage("teform_filter") private var teFormEnabled: Bool = true
    @AppStorage("infinitive_filter") private var infinitiveEnabled: Bool = true
    @AppStorage("verbclass_filter") private var verbClassEnabled: Bool = true

    @Published var filters: [SearchFilter] = []

    init() {
        loadFilters()
    }

    private func loadFilters() {
        filters = [
            SearchFilter(type: .romaji, isSelected: romajiEnabled),
            SearchFilter(type: .meaning, isSelected: meaningEnabled),
            SearchFilter(type: .japanese, isSelected: japaneseEnabled),
            SearchFilter(type: .stem, isSelected: stemEnabled),
            SearchFilter(type: .teForm, isSelected: teFormEnabled),
            SearchFilter(type: .infinitive, isSelected: infinitiveEnabled),
            SearchFilter(type: .verbClass, isSelected: verbClassEnabled),
        ]
    }

    func saveFilters() {
        for filter in filters {
            switch filter.type {
            case .romaji:
                romajiEnabled = filter.isSelected
            case .meaning:
                meaningEnabled = filter.isSelected
            case .japanese:
                japaneseEnabled = filter.isSelected
            case .stem:
                stemEnabled = filter.isSelected
            case .teForm:
                teFormEnabled = filter.isSelected
            case .infinitive:
                infinitiveEnabled = filter.isSelected
            case .verbClass:
                verbClassEnabled = filter.isSelected
            }
        }
        // Notify observers that the filters have changed
        objectWillChange.send()
    }

    func updateFilter(type: SearchFilterType, isSelected: Bool) {
        if let index = filters.firstIndex(where: { $0.type == type }) {
            filters[index].isSelected = isSelected
            saveFilters()
        }
    }

    func selectAll() {
        for i in 0..<filters.count {
            filters[i].isSelected = true
        }
        saveFilters()
    }

    func clearAll() {
        for i in 0..<filters.count {
            filters[i].isSelected = false
        }
        saveFilters()
    }
}

struct SearchFilter: Identifiable, Hashable {
    let id = UUID()
    var type: SearchFilterType
    var isSelected: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SearchFilter, rhs: SearchFilter) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
}

struct SearchFilterView: View {
    @ObservedObject var filterManager: SearchFilterManager
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Select Search Filters")) {
                    ForEach(filterManager.filters) { filter in
                        FilterRowView(
                            filter: filter,
                            isSelected: Binding<Bool>(
                                get: { filter.isSelected },
                                set: { newValue in
                                    filterManager.updateFilter(
                                        type: filter.type, isSelected: newValue)
                                }
                            )
                        )
                    }
                }

                Section {
                    Button(action: {
                        filterManager.selectAll()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.appGreen)
                            Text("Select All")
                                .foregroundColor(Color.appAccent)
                        }
                    }

                    Button(action: {
                        filterManager.clearAll()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.appRed)
                            Text("Clear All")
                                .foregroundColor(Color.appRed)
                        }
                    }
                }
            }
            .navigationTitle("Search Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color.appBackground)
        }
        #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
        #else
            .frame(minWidth: 400, minHeight: 500)
        #endif
    }
}

// Separate view for filter row to ensure correct updates
struct FilterRowView: View {
    let filter: SearchFilter
    @Binding var isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(filter.type.rawValue)
                    .font(.headline)
                    .foregroundColor(Color.appText)

                Text(filter.type.description)
                    .font(.caption)
                    .foregroundColor(Color.appSubtitle)
            }

            Spacer()

            Toggle("", isOn: $isSelected)
                .toggleStyle(SwitchToggleStyle(tint: Color.appAccent))
                .labelsHidden()
                #if os(macOS)
                    .scaleEffect(0.8)
                #endif
        }
        #if os(macOS)
            .padding(.vertical, 4)
        #endif
    }
}
