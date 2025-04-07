//
//  SettingsView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct SettingsView: View {
    @State private var resetConfirmationShown = false
    @EnvironmentObject var dataManager: VerbDataManager
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Appearance Section
                AppearanceSetting()

                // Flash Cards Section
                SettingsSection(title: "Flash Cards", icon: "rectangle.stack") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Selected Verbs")
                                .foregroundColor(Color.appText)
                            Spacer()
                            Text("\(dataManager.selectedVerbs.count)")
                                .foregroundColor(Color.appSubtitle)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.appSurface2.opacity(0.5))
                                .cornerRadius(8)
                        }

                        if !dataManager.selectedVerbs.isEmpty {
                            Button(action: {
                                resetConfirmationShown = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset Selected Verbs")
                                }
                                .foregroundColor(Color.appRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.appRed.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(BouncyButtonStyle())
                            .alert(isPresented: $resetConfirmationShown) {
                                Alert(
                                    title: Text("Reset Selection"),
                                    message: Text(
                                        "Are you sure you want to clear all selected verbs?"),
                                    primaryButton: .destructive(Text("Reset")) {
                                        resetSelectedVerbs()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                    .padding()
                }

                // About Section
                SettingsSection(title: "About", icon: "info.circle") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Version")
                                .foregroundColor(Color.appText)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Color.appSubtitle)
                        }

                        Link(destination: URL(string: "https://github.com/dunkbing/jp-verbs")!) {
                            HStack {
                                Text("GitHub Repository")
                                    .foregroundColor(Color.appAccent)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(Color.appAccent)
                            }
                        }

                        AboutFeatures()
                    }
                    .padding()
                }

                Spacer(minLength: 80)
            }
            .padding()
        }
        .background(Color.appBackground)
    }

    private func resetSelectedVerbs() {
        // Deselect all verbs
        for verb in dataManager.verbs where verb.isSelected {
            dataManager.toggleVerbSelection(verb)
        }
    }
}

struct AboutFeatures: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Features")
                .font(.headline)
                .foregroundColor(Color.appText)
                .padding(.top, 8)

            FeatureRow(icon: "magnifyingglass", text: "Search Japanese verbs by meaning or romaji")
            FeatureRow(icon: "book", text: "Detailed verb conjugations with Japanese and romaji")
            FeatureRow(icon: "rectangle.stack.fill", text: "Customizable flashcards for practicing")
            FeatureRow(icon: "paintpalette", text: "Beautiful Catppuccin color themes")
            FeatureRow(icon: "iphone", text: "Works on iOS 17+ and macOS 14+")
        }
        .padding(.top, 8)
    }
}
