//
//  VerbDetailView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct VerbDetailView: View {
    let verb: Verb
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var selectedSection = "Basic"
    @Environment(\.presentationMode) var presentationMode

    // Define sections for the tab picker
    private let sections = ["Basic", "Present", "Past", "Progressive", "Conditional"]

    var body: some View {
        #if os(iOS)
            iOSLayout
        #else
            macOSLayout
        #endif
    }

    #if os(iOS)
        private var iOSLayout: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        BackButton(label: "Back to Verbs")

                        Spacer()

                        Button(action: {
                            dataManager.toggleVerbSelection(verb)
                        }) {
                            Image(systemName: verb.isSelected ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(
                                    verb.isSelected ? Color.appYellow : Color.appSubtitle
                                )
                                .padding(.trailing, 10)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Header section with verb information
                    verbHeaderSection

                    // Tab picker for iOS
                    TabPickerView(
                        selection: $selectedSection,
                        options: sections.map { (value: $0, title: $0) }
                    )
                    .padding(.horizontal)

                    // Display the selected section
                    Group {
                        switch selectedSection {
                        case "Basic":
                            basicInfoSection
                        case "Present":
                            presentIndicativeSection
                        case "Past":
                            pastIndicativeSection
                        case "Progressive":
                            progressiveSection
                        case "Conditional":
                            conditionalSection
                        default:
                            basicInfoSection
                        }
                    }
                }
                .padding()
                Spacer(minLength: 150)
            }
            .navigationBarHidden(true)
            .background(Color.appBackground)
        }
    #endif

    #if os(macOS)
        private var macOSLayout: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()

                        Button(action: {
                            dataManager.toggleVerbSelection(verb)
                        }) {
                            Image(systemName: verb.isSelected ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(
                                    verb.isSelected ? Color.appYellow : Color.appSubtitle
                                )
                                .padding(.trailing, 10)
                        }
                    }

                    // Header section
                    verbHeaderSection

                    // Basic section
                    macOSSectionHeader("Basic Information")
                    macOSBasicInfoSection

                    // Present Indicative section
                    macOSSectionHeader("Present Indicative")
                    macOSPresentIndicativeSection

                    // Past Indicative section
                    macOSSectionHeader("Past Indicative")
                    macOSPastIndicativeSection

                    // Progressive section
                    macOSSectionHeader("Progressive Forms")
                    macOSProgressiveSection

                    // Conditional section
                    macOSSectionHeader("Conditional Forms")
                    macOSConditionalSection
                }
                .padding()
            }
            .background(Color.appBackground)
        }
    #endif

    // Section header for macOS
    private func macOSSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color.appText)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.appSurface2)
            .cornerRadius(8)
    }

    // Header section with verb name and basic info
    private var verbHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verb.romaji)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(Color.appText)

                Spacer()
            }

            Text("Class: \(verb.verbClass)")
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)

            Text(verb.presentIndicativeMeaningPositive)
                .font(.headline)
                .foregroundColor(Color.appText)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
    }

    // Basic info section - only used for iOS
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ConjugationCard(
                    title: "Dictionary Form",
                    content: [
                        ConjugationRow(label: "Romaji", values: [verb.romaji]),
                        ConjugationRow(
                            label: "Japanese",
                            values: verb.presentIndicativePlainPositive.count > 1
                                ? [verb.presentIndicativePlainPositive[1]] : []),
                    ])

                Spacer()

                ConjugationCard(
                    title: "Stem & Infinitive",
                    content: [
                        ConjugationRow(label: "Stem", values: [verb.stem]),
                        ConjugationRow(label: "Infinitive", values: [verb.infinitive]),
                        ConjugationRow(label: "Te Form", values: [verb.teForm]),
                    ])
            }

            ConjugationCard(
                title: "Meaning",
                content: [
                    ConjugationRow(
                        label: "Positive", values: [verb.presentIndicativeMeaningPositive]),
                    ConjugationRow(
                        label: "Negative", values: [verb.presentIndicativeMeaningNegative]),
                ])
        }
        .padding(.horizontal, 16)
    }

    // Present indicative section - only used for iOS
    private var presentIndicativeSection: some View {
        HStack {
            ConjugationCard(
                title: "Plain Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.presentIndicativePlainPositive),
                    ConjugationRow(label: "Negative", values: verb.presentIndicativePlainNegative),
                ])

            Spacer()

            ConjugationCard(
                title: "Polite Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.presentIndicativePolitePositive),
                    ConjugationRow(label: "Negative", values: verb.presentIndicativePoliteNegative),
                ])
        }
        .padding(.horizontal, 20)
    }

    // Past indicative section - only used for iOS
    private var pastIndicativeSection: some View {
        HStack {
            ConjugationCard(
                title: "Plain Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.pastIndicativePlainPositive),
                    ConjugationRow(label: "Negative", values: verb.pastIndicativePlainNegative),
                ])

            Spacer()

            ConjugationCard(
                title: "Polite Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.pastIndicativePolitePositive),
                    ConjugationRow(label: "Negative", values: verb.pastIndicativePoliteNegative),
                ])
        }.padding(.horizontal, 16)
    }

    // Progressive section - only used for iOS
    private var progressiveSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConjugationCard(
                title: "Present Progressive",
                content: [
                    ConjugationRow(
                        label: "Plain Positive", values: verb.presentProgressivePlainPositive),
                    ConjugationRow(
                        label: "Polite Positive", values: verb.presentProgressivePolitePositive),
                    ConjugationRow(
                        label: "Polite Negative", values: verb.presentProgressivePoliteNegative),
                ])
        }
    }

    // Conditional section - only used for iOS
    private var conditionalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Provisional Conditional (eba form)
            ConjugationCard(
                title: "Provisional Conditional (eba form)",
                content: [
                    ConjugationRow(
                        label: "Positive", values: verb.provisionalConditionalPlainPositive),
                    ConjugationRow(
                        label: "Negative", values: verb.provisionalConditionalPlainNegative),
                ])

            // Conditional Tara form
            HStack {
                ConjugationCard(
                    title: "Tara Form - Plain",
                    content: [
                        ConjugationRow(
                            label: "Positive", values: verb.conditionalTaraPlainPositive),
                        ConjugationRow(
                            label: "Negative", values: verb.conditionalTaraPlainNegative),
                    ])

                Spacer()

                ConjugationCard(
                    title: "Tara Form - Polite",
                    content: [
                        ConjugationRow(
                            label: "Positive", values: verb.conditionalTaraPolitePositive),
                        ConjugationRow(
                            label: "Negative", values: verb.conditionalTaraPoliteNegative),
                    ])
            }
        }
        .padding(.horizontal, 16)
    }

    // macOS Basic Info row
    private var macOSBasicInfoSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Dictionary Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Dictionary Form")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Romaji")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.romaji)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                if verb.presentIndicativePlainPositive.count > 1 {
                    VStack(alignment: .leading) {
                        Text("Japanese")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                        Text(verb.presentIndicativePlainPositive[1])
                            .foregroundColor(Color.appText)
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)

            // Stem & Infinitive
            VStack(alignment: .leading, spacing: 8) {
                Text("Stem & Infinitive")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Stem")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.stem)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Infinitive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.infinitive)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Te Form")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.teForm)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            // Meaning
            VStack(alignment: .leading, spacing: 8) {
                Text("Meaning")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.presentIndicativeMeaningPositive)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                    Text(verb.presentIndicativeMeaningNegative)
                        .foregroundColor(Color.appText)
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // macOS Present Indicative row
    private var macOSPresentIndicativeSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Plain Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Plain Form")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentIndicativePlainPositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentIndicativePlainNegative, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            // Polite Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Polite Form")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentIndicativePolitePositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentIndicativePoliteNegative, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            // Spacer to balance the layout
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // macOS Past Indicative row
    private var macOSPastIndicativeSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Plain Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Plain Form")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.pastIndicativePlainPositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.pastIndicativePlainNegative, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            // Polite Form
            VStack(alignment: .leading, spacing: 8) {
                Text("Polite Form")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.pastIndicativePolitePositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text("Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.pastIndicativePoliteNegative, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            // Spacer to balance the layout
            Spacer()
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // macOS Progressive section
    private var macOSProgressiveSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Present Progressive
            VStack(alignment: .leading, spacing: 8) {
                Text("Present Progressive")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                VStack(alignment: .leading) {
                    Text("Plain Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentProgressivePlainPositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text(" ")
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .opacity(0)

                VStack(alignment: .leading) {
                    Text("Polite Positive")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentProgressivePolitePositive, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text(" ")
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .opacity(0)

                VStack(alignment: .leading) {
                    Text("Polite Negative")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(verb.presentProgressivePoliteNegative, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
                .padding(8)
                .background(Color.appSurface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    private var macOSConditionalSection: some View {
        VStack(spacing: 20) {
            // Provisional Conditional (eba form)
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Provisional Conditional (eba form)")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    VStack(alignment: .leading) {
                        Text("Positive")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.provisionalConditionalPlainPositive, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text("Negative")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.provisionalConditionalPlainNegative, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)

                // Spacers to balance layout
                Spacer()
                    .frame(maxWidth: .infinity)

                Spacer()
                    .frame(maxWidth: .infinity)
            }

            // Conditional Tara form
            HStack(alignment: .top, spacing: 16) {
                // Plain Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tara Form - Plain")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    VStack(alignment: .leading) {
                        Text("Positive")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.conditionalTaraPlainPositive, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text("Negative")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.conditionalTaraPlainNegative, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)

                // Polite Form
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tara Form - Polite")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    VStack(alignment: .leading) {
                        Text("Positive")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.conditionalTaraPolitePositive, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text("Negative")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)

                        ForEach(verb.conditionalTaraPoliteNegative, id: \.self) { value in
                            Text(value)
                                .foregroundColor(Color.appText)
                                .padding(4)
                        }
                    }
                    .padding(8)
                    .background(Color.appSurface)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)

                // Spacer to balance the layout
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ConjugationCard: View {
    let title: String
    let content: [ConjugationRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.appText)
                .padding(.bottom, 4)

            ForEach(content) { row in
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.label)
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    ForEach(row.values, id: \.self) { value in
                        Text(value)
                            .foregroundColor(Color.appText)
                            .padding(4)
                    }
                }
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
    }
}

struct ConjugationRow: Identifiable {
    let id = UUID()
    let label: String
    let values: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)

            ForEach(values, id: \.self) { value in
                Text(value)
                    .foregroundColor(Color.appText)
                    .padding(4)
            }
        }
    }
}
