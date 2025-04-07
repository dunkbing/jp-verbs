//
//  FlashCardDeckView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct CardSet: Identifiable {
    let id = UUID()
    let cards: [Verb]
}

struct FlashCardDeckView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var showingFlashCards = false
    @State private var numberOfVerbs = 10
    @State private var selectedCards: [Verb] = []
    @State private var cardsToPresent: CardSet?
    @State private var selectedMode = FlashCardMode.romaji

    enum FlashCardMode: String, CaseIterable, Identifiable {
        case romaji = "Romaji → Japanese"
        case japanese = "Japanese → Romaji"
        case meaning = "Meaning → Verb"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if dataManager.verbs.isEmpty {
                    ProgressView("Loading verbs...")
                        .foregroundColor(Color.appText)
                        .padding(.top, 50)
                } else {
                    // Header Image
                    headerView

                    // Main Content
                    mainContent
                        .padding(.bottom, 80)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: dataManager.selectedVerbs.count)
        }
        .background(Color.appBackground)
        .sheet(item: $cardsToPresent) { cardSet in
            FlashCardView(verbs: cardSet.cards, mode: selectedMode)
                .withTheming()
        }
        .onAppear {
            selectedCards = Array(
                dataManager.verbs.shuffled().prefix(numberOfVerbs))
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.appAccent)
                .padding()
                .background(
                    Circle()
                        .fill(Color.appSurface2.opacity(0.3))
                )
                .padding(.top, 20)

            Text("Flash Cards")
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundColor(Color.appText)

            Text("Review and memorize Japanese verbs")
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }

    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            setupSection

            // Selected Verb List
            if !dataManager.selectedVerbs.isEmpty {
                selectedVerbsSection
            }

            // Random Verbs Option
            quickStudySection

            // Selection guide
            tipSection
            Spacer(minLength: 80)
        }
        .padding(.vertical)
        .padding(.horizontal)
    }

    private var setupSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(Color.appAccent)

                    Text("Setup Flash Cards")
                        .font(.headline)
                        .foregroundColor(Color.appText)
                }
                .padding(.bottom, 4)

                Stepper(
                    "Number of Verbs: \(numberOfVerbs)",
                    value: $numberOfVerbs,
                    in: 5...50,
                    step: 5
                )
                .foregroundColor(Color.appText)

                Divider()
                    .background(Color.appSurface2)

                Text("Card Mode:")
                    .font(.subheadline)
                    .foregroundColor(Color.appText)

                TabPickerView(
                    selection: $selectedMode,
                    options: FlashCardMode.allCases.map { (value: $0, title: $0.rawValue) }
                )
            }
            .padding(.vertical, 8)
        }
        .groupBoxStyle(CatppuccinGroupBoxStyle())
    }

    private var selectedVerbsSection: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(Color.appYellow)

                    Text("Selected Verbs (\(dataManager.selectedVerbs.count))")
                        .font(.headline)
                        .foregroundColor(Color.appText)
                }
                .padding(.bottom, 8)

                selectedVerbsScrollView

                startStudyButton
            }
            .padding(.vertical, 8)
        }
        .groupBoxStyle(CatppuccinGroupBoxStyle())
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var selectedVerbsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(dataManager.selectedVerbs) { verb in
                    selectedVerbChip(for: verb)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func selectedVerbChip(for verb: Verb) -> some View {
        HStack {
            Text(verb.romaji)
                .lineLimit(1)
                .foregroundColor(Color.appText)

            Button(action: {
                dataManager.toggleVerbSelection(verb)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.appRed)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.appSurface)
        .cornerRadius(8)
    }

    private var startStudyButton: some View {
        Button(action: {
            if !dataManager.selectedVerbs.isEmpty {
                cardsToPresent = CardSet(cards: dataManager.selectedVerbs)
            }
        }) {
            Label("Study Selected Verbs", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.appAccent)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 8)
    }

    private var quickStudySection: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "shuffle")
                        .font(.title2)
                        .foregroundColor(Color.appGreen)

                    Text("Quick Study")
                        .font(.headline)
                        .foregroundColor(Color.appText)
                }
                .padding(.bottom, 8)

                Button(action: {
                    let selectedCards = Array(dataManager.verbs.shuffled().prefix(numberOfVerbs))
                    cardsToPresent = CardSet(cards: selectedCards)
                }) {
                    Label(
                        "Start with \(numberOfVerbs) Random Verbs",
                        systemImage: "shuffle"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appGreen)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.vertical, 8)
            }
        }
        .groupBoxStyle(CatppuccinGroupBoxStyle())
    }

    private var tipSection: some View {
        GroupBox {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(Color.appYellow)
                    .padding(.top, 2)

                VStack(alignment: .leading) {
                    Text("Tip")
                        .font(.headline)
                        .foregroundColor(Color.appText)
                        .padding(.bottom, 2)

                    Text(
                        "You can select verbs for study from the Browse tab. Swipe left on a verb or tap the star in its detail view to add it to your study deck."
                    )
                    .font(.subheadline)
                    .foregroundColor(Color.appSubtitle)
                }
            }
            .padding(.vertical, 8)
        }
        .groupBoxStyle(CatppuccinGroupBoxStyle())
    }
}

struct FlashCardView: View {
    let verbs: [Verb]
    var mode: FlashCardDeckView.FlashCardMode = .romaji

    @State private var currentIndex = 0
    @State private var isShowingAnswer = false
    @State private var offset: CGSize = .zero
    @State private var cardsCompleted = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            // Progress indicator
            HStack {
                Text("Card \(currentIndex + 1) of \(verbs.count)")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                Spacer()

                Button(action: {
                    // Reset and exit
                    dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .foregroundColor(Color.appAccent)
                }
            }
            .padding()

            // Progress bar
            ProgressView(value: Double(cardsCompleted), total: Double(verbs.count))
                .padding(.horizontal)
                .accentColor(Color.appAccent)

            Spacer()

            // Flash card
            if currentIndex < verbs.count {
                ZStack {
                    // Card background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appSurface)
                        .shadow(color: Color.appText.opacity(0.2), radius: 8)

                    // Card content
                    VStack(spacing: 20) {
                        if !isShowingAnswer {
                            // Question side
                            Text(questionText(for: verbs[currentIndex]))
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(Color.appText)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else {
                            // Answer side
                            Text(answerText(for: verbs[currentIndex]))
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(Color.appText)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)

                            Divider()
                                .background(Color.appSurface2)

                            // Additional info
                            VStack(alignment: .leading, spacing: 12) {
                                Text(verbs[currentIndex].presentIndicativeMeaningPositive)
                                    .font(.headline)
                                    .foregroundColor(Color.appText)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Class: \(verbs[currentIndex].verbClass)")
                                    .font(.subheadline)
                                    .foregroundColor(Color.appSubtitle)
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
                                .background(isShowingAnswer ? Color.appSurface2 : Color.appAccent)
                                .foregroundColor(isShowingAnswer ? Color.appText : .white)
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
                        .foregroundColor(Color.appGreen)

                    Text("Well done!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.appText)

                    Text("You've completed all \(verbs.count) cards")
                        .font(.headline)
                        .foregroundColor(Color.appText)

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
                            .background(Color.appAccent)
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
                    .foregroundColor(Color.appSubtitle)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Flash Cards")
        .background(Color.appBackground)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
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

// Custom Group Box Style that uses Catppuccin colors
struct CatppuccinGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .padding(.bottom, 4)

            configuration.content
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
    }
}
