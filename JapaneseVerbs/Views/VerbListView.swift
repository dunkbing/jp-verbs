//
//  VerbListView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI

struct VerbListView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @Binding var searchText: String
    @State private var showingAddToFlashcards = false

    var filteredVerbs: [Verb] {
        dataManager.search(text: searchText)
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.horizontal)

            if dataManager.isLoading {
                ProgressView("Loading verbs...")
            } else if let error = dataManager.error {
                ErrorView(message: error) {
                    dataManager.loadVerbs()
                }
            } else if filteredVerbs.isEmpty {
                Text("No verbs found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(filteredVerbs) { verb in
                        NavigationLink(destination: VerbDetailView(verb: verb)) {
                            VerbRowView(verb: verb)
                        }
                        .swipeActions {
                            Button(verb.isSelected ? "Remove" : "Add") {
                                dataManager.toggleVerbSelection(verb)
                            }
                            .tint(verb.isSelected ? .red : .green)
                        }
                    }
                }
                #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                #endif
            }

            if !dataManager.selectedVerbs.isEmpty {
                Button(action: {
                    showingAddToFlashcards = true
                }) {
                    Text("Study \(dataManager.selectedVerbs.count) selected verbs")
                        .font(.system(.headline, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showingAddToFlashcards) {
                    FlashCardView(verbs: dataManager.selectedVerbs)
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search verbs", text: $text)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .cornerRadius(10)
        //        .background(Color(.systemGray6))
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

                    if !verb.presentIndicativePlainPositive.isEmpty {
                        Text(verb.presentIndicativePlainPositive[0])
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Text(verb.presentIndicativeMeaningPositive)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if verb.isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text(message)
                .multilineTextAlignment(.center)

            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
