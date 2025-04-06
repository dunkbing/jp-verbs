//
//  SettingsView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct SettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var resetConfirmationShown = false
    @EnvironmentObject var dataManager: VerbDataManager

    var body: some View {
        List {
            Section(header: Text("Appearance")) {
                // Theme Options
                ForEach(AppTheme.allCases) { theme in
                    HStack {
                        Image(systemName: theme.icon)
                            .font(.title2)
                            .foregroundColor(
                                theme == .light
                                    ? .yellow
                                    : theme == .dark ? Color.appSecondaryAccent : Color.appAccent
                            )
                            .frame(width: 30, height: 30)

                        Text(theme.rawValue)
                            .font(.headline)

                        Spacer()

                        if themeManager.theme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.appAccent)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        themeManager.theme = theme
                    }
                    .padding(.vertical, 4)
                }
            }

            Section(header: Text("Flash Cards")) {
                HStack {
                    Text("Selected Verbs")
                    Spacer()
                    Text("\(dataManager.selectedVerbs.count)")
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    resetConfirmationShown = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(Color.appRed)
                        Text("Reset Selected Verbs")
                            .foregroundColor(Color.appRed)
                    }
                }
                .alert(isPresented: $resetConfirmationShown) {
                    Alert(
                        title: Text("Reset Selection"),
                        message: Text("Are you sure you want to clear all selected verbs?"),
                        primaryButton: .destructive(Text("Reset")) {
                            resetSelectedVerbs()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                Link(destination: URL(string: "https://github.com/dunkbing/jp-verbs")!) {
                    HStack {
                        Image(systemName: "globe")
                        Text("GitHub Repository")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
            }
        }
        #if os(iOS)
            .listStyle(InsetGroupedListStyle())
        #endif
        .background(Color.appBackground)
    }

    private func resetSelectedVerbs() {
        // Deselect all verbs
        for verb in dataManager.verbs where verb.isSelected {
            dataManager.toggleVerbSelection(verb)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(VerbDataManager())
        }
        .withTheming()
    }
}
