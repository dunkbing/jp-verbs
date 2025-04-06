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
            SearchBar(text: $searchText, placeholder: "Search verbs")
                .padding(.horizontal)

            if dataManager.isLoading {
                ProgressView("Loading verbs...")
                    .foregroundColor(Color.appText)
            } else if let error = dataManager.error {
                ErrorView(message: error) {
                    dataManager.loadVerbs()
                }
            } else if filteredVerbs.isEmpty {
                Text("No verbs found")
                    .foregroundColor(Color.appSubtitle)
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
                            .tint(verb.isSelected ? Color.appRed : Color.appGreen)
                        }
                    }
                }
                #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                #endif
                .background(Color.appBackground)
            }

            if !dataManager.selectedVerbs.isEmpty {
                Button(action: {
                    showingAddToFlashcards = true
                }) {
                    Text("Study \(dataManager.selectedVerbs.count) selected verbs")
                        .font(.system(.headline, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showingAddToFlashcards) {
                    FlashCardView(verbs: dataManager.selectedVerbs)
                        .withTheming()
                }
            }
        }
        .background(Color.appBackground)
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)? = nil

    // Animation states
    @State private var isFocused: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? Color.appAccent : Color.appSubtitle)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            TextField(placeholder, text: $text)
                .foregroundColor(Color.appText)
                .font(.system(size: 16))
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { focused in
                    withAnimation {
                        isFocused = focused
                    }
                }
                .submitLabel(.search)
                .onSubmit {
                    onCommit?()
                }

            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.appSubtitle)
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface2.opacity(isFocused ? 0.15 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? Color.appAccent.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text)
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

                    if !verb.presentIndicativePlainPositive.isEmpty {
                        Text(verb.presentIndicativePlainPositive[0])
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

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(Color.appRed)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.appText)

            Button("Retry", action: retryAction)
                .padding()
                .background(Color.appAccent)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.appBackground)
    }
}
