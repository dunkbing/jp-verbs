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

                // Contact Section
                SettingsSection(title: "Contact", icon: "envelope") {
                    VStack(alignment: .leading, spacing: 16) {
                        ContactRow(
                            icon: "mail",
                            title: "Email",
                            value: "bing@db99.dev"
                        )

                        ContactRow(
                            icon: "paperplane",
                            title: "Telegram",
                            value: "@dunkbing"
                        )
                    }
                    .padding()
                }

                // Other Apps Section
                SettingsSection(title: "My Apps", icon: "apps.iphone") {
                    VStack(alignment: .leading, spacing: 16) {
                        AppLink(
                            name: "Tikim",
                            description: "Simple and intuitive expense tracker",
                            icon: "dollarsign",
                            link: "https://apps.apple.com/vn/app/tikim-expense-tracker/id6727017255"
                        )
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
                            Text(appVersion)
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

                        // Rate App Button
                        //                        Button(action: {
                        //                            if let writeReviewURL = URL(string: "https://apps.apple.com/app/doushi-japanese-verbs/id6744300188?action=write-review") {
                        //                                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        //                            }
                        //                        }) {
                        //                            HStack {
                        //                                Image(systemName: "star.fill")
                        //                                    .foregroundColor(Color.appYellow)
                        //
                        //                                Text("Rate Doushi")
                        //                                    .foregroundColor(Color.appAccent)
                        //
                        //                                Spacer()
                        //
                        //                                Image(systemName: "chevron.right")
                        //                                    .foregroundColor(Color.appSubtitle)
                        //                            }
                        //                        }
                    }
                    .padding()
                }

                Spacer(minLength: 100)
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

    private var appVersion: String {
        let bundle = Bundle.main
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(version) (Build \(build))"
    }
}

struct ContactRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.appAccent)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color.appSubtitle)

                Text(value)
                    .font(.body)
                    .foregroundColor(Color.appText)
            }

            Spacer()
        }
    }
}

struct AppLink: View {
    let name: String
    let description: String
    let icon: String
    let link: String

    var body: some View {
        Link(destination: URL(string: link)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color.appAccent)
                    .frame(width: 30, height: 30)
                    .background(Color.appSurface2.opacity(0.3))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Color.appSubtitle)
            }
        }
    }
}
