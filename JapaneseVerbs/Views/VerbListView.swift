//
//  VerbListView.swift
//  JapaneseVerbs
//
//  Updated by Claude on 24/4/25.
//

import SwiftUI
import TikimUI

struct VerbListView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @StateObject private var filterManager = SearchFilterManager()
    @Binding var searchText: String
    @State private var showingAddToFlashcards = false
    @State private var isSearchFocused = false
    @State private var showingFilters = false

    var filteredVerbs: [Verb] {
        dataManager.search(text: searchText, filters: filterManager.filters)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack {
                    SearchBar(
                        text: $searchText,
                        placeholder: "Search verbs",
                        onSearchTextChanged: { newText in
                            print(newText)
                        },
                        onFocusChange: { focused in
                            withAnimation {
                                isSearchFocused = focused
                            }
                        }
                    )

                    // Filter button
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                            .foregroundColor(
                                hasActiveFilters ? Color.appAccent : Color.appText
                            )
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                if hasActiveFilters {
                    activeFiltersView
                }

                if !dataManager.selectedVerbs.isEmpty && !isSearchFocused {
                    studyButton
                }

                if dataManager.isLoading {
                    loadingView
                } else if let error = dataManager.error {
                    errorView(message: error)
                } else if filteredVerbs.isEmpty {
                    emptyStateView
                } else {
                    verbsList
                }

                #if os(iOS)
                    Spacer(minLength: 80)
                #endif
            }
        }
        .background(Color.appBackground)
        .sheet(isPresented: $showingFilters) {
            SearchFilterView(filterManager: filterManager, isPresented: $showingFilters)
                .withTheming()
        }
    }

    private var hasActiveFilters: Bool {
        !filterManager.filters.isEmpty && filterManager.filters.contains(where: { $0.isSelected })
    }

    private var activeFiltersView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Filters:")
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)
                .padding(.horizontal)
                .padding(.top, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filterManager.filters.filter { $0.isSelected }, id: \.id) { filter in
                        HStack(spacing: 6) {
                            Text(filter.type.rawValue)
                                .font(.caption)
                                .foregroundColor(Color.appAccent)
                                .lineLimit(1)

                            Button(action: {
                                if filterManager.filters.firstIndex(where: {
                                    $0.type == filter.type
                                }) != nil {
                                    filterManager.updateFilter(type: filter.type, isSelected: false)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.appSubtitle.opacity(0.7))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appAccent.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                        )
                    }

                    if filterManager.filters.filter({ $0.isSelected }).count
                        < filterManager.filters.count
                    {
                        Button(action: {
                            filterManager.selectAll()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10))
                                Text("Reset")
                                    .font(.caption)
                            }
                            .foregroundColor(Color.appText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appSurface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appSurface2, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading verbs...")
                .foregroundColor(Color.appText)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        ErrorView(message: message) {
            dataManager.loadVerbs()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(Color.appSubtitle)

            Text("No verbs found")
                .font(.headline)
                .foregroundColor(Color.appSubtitle)

            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundColor(Color.appSubtitle.opacity(0.7))

                // Added text about filters
                if !hasActiveFilters || !filterManager.filters.allSatisfy({ $0.isSelected }) {
                    Text("Or check your search filters")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle.opacity(0.7))
                        .padding(.top, -8)
                }

                Button(action: {
                    searchText = ""
                }) {
                    Text("Clear Search")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
    }

    private var verbsList: some View {
        List {
            ForEach(filteredVerbs) { verb in
                NavigationLink(destination: VerbDetailView(verb: verb)) {
                    VerbRowView(verb: verb)
                }
                .swipeActions {
                    Button(verb.isSelected ? "Remove" : "Add") {
                        dataManager.toggleVerbSelection(verb)
                    }
                    .tint(verb.isSelected ? Color.appRed : Color.appGreen)
                }
            }
        }
        #if os(iOS)
            .listStyle(InsetGroupedListStyle())
        #endif
        .background(Color.appBackground)
        // Add extra padding at bottom to account for the study button
        .padding(.bottom, dataManager.selectedVerbs.isEmpty ? 0 : 60)
    }

    private var studyButton: some View {
        Button(action: {
            showingAddToFlashcards = true
        }) {
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .font(.headline)

                Text("Study \(dataManager.selectedVerbs.count) selected verbs")
                    .font(.system(.headline, design: .rounded))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.appAccent)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding()
        .sheet(isPresented: $showingAddToFlashcards) {
            FlashCardView(verbs: dataManager.selectedVerbs)
                .withTheming()
        }
    }
}

struct VerbRowView: View {
    let verb: Verb

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(verb.romaji)
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    if verb.presentIndicativePlainPositive.count > 1 {
                        Text(verb.presentIndicativePlainPositive[1])
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                    }
                }

                Text(verb.presentIndicativeMeaningPositive)
                    .font(.caption)
                    .foregroundColor(Color.appSubtitle)
                    .lineLimit(1)
            }

            Spacer()

            if verb.isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.appGreen)
            }
        }
        .padding(.vertical, 4)
    }
}
