//
//  ThemeInfoView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct ThemeInfoView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme Settings")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.appText)

                    Text("Customize your app appearance")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                }

                Divider()
                    .background(Color.appSurface2)

                // Current theme
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Theme")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    HStack(spacing: 12) {
                        Image(systemName: themeManager.theme.icon)
                            .font(.system(size: 30))
                            .foregroundColor(themeManager.theme.primaryColor)
                            .frame(width: 48, height: 48)
                            .background(Color.appSurface2.opacity(0.5))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(themeManager.theme.rawValue)
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color.appText)

                            Text(themeManager.theme.description)
                                .font(.subheadline)
                                .foregroundColor(Color.appSubtitle)
                        }
                    }
                    .padding()
                    .background(Color.appSurface)
                    .cornerRadius(12)
                }

                // Theme options
                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Themes")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    ForEach(AppTheme.allCases) { theme in
                        Button(action: {
                            themeManager.theme = theme
                        }) {
                            HStack {
                                Image(systemName: theme.icon)
                                    .font(.title3)
                                    .foregroundColor(theme.primaryColor)
                                    .frame(width: 36, height: 36)
                                    .background(Color.appSurface2.opacity(0.5))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(theme.rawValue)
                                        .font(.headline)
                                        .foregroundColor(Color.appText)

                                    Text(theme.description)
                                        .font(.caption)
                                        .foregroundColor(Color.appSubtitle)
                                }

                                Spacer()

                                if themeManager.theme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.appGreen)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                themeManager.theme == theme
                                                    ? Color.appAccent : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // About the theme
                VStack(alignment: .leading, spacing: 10) {
                    Text("About Catppuccin")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    Text(
                        "This app uses the Catppuccin color palette, a soothing pastel theme designed to be warm and soft. The light theme uses the 'Latte' variant, while the dark theme uses 'Macchiato'."
                    )
                    .font(.body)
                    .foregroundColor(Color.appText)
                    .padding()
                    .background(Color.appSurface)
                    .cornerRadius(12)

                    Link(destination: URL(string: "https://github.com/catppuccin/catppuccin")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(Color.appAccent)

                            Text("Learn more about Catppuccin")
                                .foregroundColor(Color.appAccent)

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(Color.appAccent)
                        }
                        .padding()
                        .background(Color.appSurface)
                        .cornerRadius(12)
                    }
                }

                // Done button
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
    }
}

struct ThemeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeInfoView()
            .withTheming()
    }
}
