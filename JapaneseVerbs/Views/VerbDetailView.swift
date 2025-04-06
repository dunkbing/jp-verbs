//
//  VerbDetailView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI

struct VerbDetailView: View {
    let verb: Verb
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var selectedSection = 0

    private let sections = ["Basic", "Present", "Past", "Progressive", "Conditional"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(verb.romaji)
                            .font(.system(.title, design: .rounded))
                            .bold()

                        Spacer()

                        Button(action: {
                            dataManager.toggleVerbSelection(verb)
                        }) {
                            Image(systemName: verb.isSelected ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(verb.isSelected ? .yellow : .gray)
                        }
                    }

                    Text("Class: \(verb.verbClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(verb.presentIndicativeMeaningPositive)
                        .font(.headline)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Section selector
                Picker("Section", selection: $selectedSection) {
                    ForEach(0..<sections.count, id: \.self) { index in
                        Text(sections[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Content sections
                switch selectedSection {
                case 0:
                    basicInfoSection
                case 1:
                    presentIndicativeSection
                case 2:
                    pastIndicativeSection
                case 3:
                    progressiveSection
                case 4:
                    conditionalSection
                default:
                    EmptyView()
                }
            }
            .padding()
        }
        .navigationTitle("Verb Details")
    }

    // Basic info section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConjugationCard(
                title: "Dictionary Form",
                content: [
                    ConjugationRow(label: "Romaji", values: [verb.romaji]),
                    ConjugationRow(
                        label: "Japanese",
                        values: !verb.presentIndicativePlainPositive.isEmpty
                            ? [verb.presentIndicativePlainPositive[1]] : []),
                ])

            ConjugationCard(
                title: "Stem & Infinitive",
                content: [
                    ConjugationRow(label: "Stem", values: [verb.stem]),
                    ConjugationRow(label: "Infinitive", values: [verb.infinitive]),
                    ConjugationRow(label: "Te Form", values: [verb.teForm]),
                ])

            ConjugationCard(
                title: "Meaning",
                content: [
                    ConjugationRow(
                        label: "Positive", values: [verb.presentIndicativeMeaningPositive]),
                    ConjugationRow(
                        label: "Negative", values: [verb.presentIndicativeMeaningNegative]),
                ])
        }
    }

    // Present indicative section
    private var presentIndicativeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConjugationCard(
                title: "Plain Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.presentIndicativePlainPositive),
                    ConjugationRow(label: "Negative", values: verb.presentIndicativePlainNegative),
                ])

            ConjugationCard(
                title: "Polite Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.presentIndicativePolitePositive),
                    ConjugationRow(label: "Negative", values: verb.presentIndicativePoliteNegative),
                ])
        }
    }

    // Past indicative section
    private var pastIndicativeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ConjugationCard(
                title: "Plain Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.pastIndicativePlainPositive),
                    ConjugationRow(label: "Negative", values: verb.pastIndicativePlainNegative),
                ])

            ConjugationCard(
                title: "Polite Form",
                content: [
                    ConjugationRow(label: "Positive", values: verb.pastIndicativePolitePositive),
                    ConjugationRow(label: "Negative", values: verb.pastIndicativePoliteNegative),
                ])
        }
    }

    // Progressive section
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

    // Conditional section - placeholder for now
    private var conditionalSection: some View {
        Text("Conditional forms would go here")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

struct ConjugationCard: View {
    let title: String
    let content: [ConjugationRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(content) { row in
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.label)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(row.values, id: \.self) { value in
                        Text(value)
                            .padding(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
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
                .foregroundColor(.secondary)

            ForEach(values, id: \.self) { value in
                Text(value)
                    .padding(4)
            }
        }
    }
}
