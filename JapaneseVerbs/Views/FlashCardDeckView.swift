//
//  FlashCardDeckView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI

struct FlashCardDeckView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var showingFlashCards = false
    @State private var numberOfVerbs = 10
    @State private var selectedCards: [Verb] = []
    @State private var selectedMode = FlashCardMode.romaji

    enum FlashCardMode: String, CaseIterable, Identifiable {
        case romaji = "Romaji → Japanese"
        case japanese = "Japanese → Romaji"
        case meaning = "Meaning → Verb"

        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(spacing: 20) {
            if dataManager.verbs.isEmpty {
                ProgressView("Loading verbs...")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        GroupBox(label: Text("Setup Flash Cards").font(.headline)) {
                            VStack(alignment: .leading, spacing: 16) {
                                Stepper(
                                    "Number of Verbs: \(numberOfVerbs)", value: $numberOfVerbs,
                                    in: 5...50, step: 5)

                                Divider()

                                Text("Card Mode:")
                                    .font(.subheadline)

                                Picker("Flash Card Mode", selection: $selectedMode) {
                                    ForEach(FlashCardMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)

                        // Selected Verb List
                        if !dataManager.selectedVerbs.isEmpty {
                            GroupBox(
                                label: Text("Selected Verbs (\(dataManager.selectedVerbs.count))")
                                    .font(.headline)
                            ) {
                                VStack(alignment: .leading) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(dataManager.selectedVerbs) { verb in
                                                HStack {
                                                    Text(verb.romaji)
                                                        .lineLimit(1)

                                                    Button(action: {
                                                        dataManager.toggleVerbSelection(verb)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 8)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(8)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }

                                    Button(action: {
                                        showingFlashCards = true
                                        selectedCards = dataManager.selectedVerbs
                                    }) {
                                        Label("Study Selected Verbs", systemImage: "play.fill")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.top, 8)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal)
                        }

                        // Random Verbs Option
                        GroupBox(label: Text("Quick Study").font(.headline)) {
                            Button(action: {
                                showingFlashCards = true
                                selectedCards = Array(
                                    dataManager.verbs.shuffled().prefix(numberOfVerbs))
                            }) {
                                Label(
                                    "Start with \(numberOfVerbs) Random Verbs",
                                    systemImage: "shuffle"
                                )
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)

                        // Selection guide
                        GroupBox(label: Text("Tip").font(.headline)) {
                            Text(
                                "You can select verbs for study from the Browse tab. Swipe left on a verb or tap the star in its detail view to add it to your study deck."
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showingFlashCards) {
            if !selectedCards.isEmpty {
                FlashCardView(verbs: selectedCards, mode: selectedMode)
            }
        }
    }
}

struct FlashCardView: View {
    let verbs: [Verb]
    var mode: FlashCardDeckView.FlashCardMode = .romaji

    @State private var currentIndex = 0
    @State private var isShowingAnswer = false
    @State private var offset: CGSize = .zero
    @State private var cardsCompleted = 0

    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                Text("Card \(currentIndex + 1) of \(verbs.count)")
                    .font(.headline)

                Spacer()

                Button(action: {
                    // Reset and exit
                    currentIndex = 0
                    isShowingAnswer = false
                    offset = .zero
                }) {
                    Text("Done")
                        .bold()
                }
            }
            .padding()

            // Progress bar
            ProgressView(value: Double(cardsCompleted), total: Double(verbs.count))
                .padding(.horizontal)

            Spacer()

            // Flash card
            if currentIndex < verbs.count {
                ZStack {
                    // Card background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 8)

                    // Card content
                    VStack(spacing: 20) {
                        if !isShowingAnswer {
                            // Question side
                            Text(questionText(for: verbs[currentIndex]))
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            // Answer side
                            Text(answerText(for: verbs[currentIndex]))
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)

                            Divider()

                            // Additional info
                            VStack(alignment: .leading, spacing: 12) {
                                Text(verbs[currentIndex].presentIndicativeMeaningPositive)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Class: \(verbs[currentIndex].verbClass)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }

                        Spacer()

                        // Info or Action button
                        Button(action: {
                            withAnimation {
                                isShowingAnswer.toggle()
                            }
                        }) {
                            Text(isShowingAnswer ? "Hide Answer" : "Show Answer")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isShowingAnswer ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                .frame(width: 320, height: 400)
                .offset(offset)
                .rotationEffect(.degrees(Double(offset.width / 20)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.offset = gesture.translation
                        }
                        .onEnded { gesture in
                            withAnimation {
                                if abs(gesture.translation.width) > 100 {
                                    // Swipe left or right
                                    self.offset = CGSize(
                                        width: gesture.translation.width > 0 ? 500 : -500,
                                        height: 0
                                    )

                                    // Move to next card after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        self.cardsCompleted += 1
                                        self.currentIndex += 1
                                        self.isShowingAnswer = false
                                        self.offset = .zero
                                    }
                                } else {
                                    self.offset = .zero
                                }
                            }
                        }
                )
            } else {
                // Completed all cards
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("Well done!")
                        .font(.largeTitle)
                        .bold()

                    Text("You've completed all \(verbs.count) cards")
                        .font(.headline)

                    Button(action: {
                        // Reset
                        currentIndex = 0
                        cardsCompleted = 0
                        isShowingAnswer = false
                    }) {
                        Text("Start Again")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                }
            }

            Spacer()

            if currentIndex < verbs.count {
                // Instruction
                Text("Swipe left or right to proceed to the next card")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Flash Cards")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper methods for the flash card content
    private func questionText(for verb: Verb) -> String {
        switch mode {
        case .romaji:
            return verb.romaji
        case .japanese:
            return verb.presentIndicativePlainPositive.first ?? ""
        case .meaning:
            return verb.presentIndicativeMeaningPositive
        }
    }

    private func answerText(for verb: Verb) -> String {
        switch mode {
        case .romaji:
            return verb.presentIndicativePlainPositive.first ?? ""
        case .japanese:
            return verb.romaji
        case .meaning:
            return "\(verb.romaji) (\(verb.presentIndicativePlainPositive.first ?? ""))"
        }
    }
}
