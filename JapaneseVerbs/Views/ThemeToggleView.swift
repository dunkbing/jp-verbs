//
//  ThemeToggleView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct ThemeToggleView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isExpanded = false

    var body: some View {
        HStack {
            if isExpanded {
                ForEach(AppTheme.allCases) { theme in
                    Button(action: {
                        withAnimation {
                            themeManager.theme = theme
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: theme.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(
                                themeManager.theme == theme ? Color.appAccent : Color.appText
                            )
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.appSurface)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }

            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: themeManager.theme.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.appText)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.appSurface)
                            .shadow(color: Color.appText.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                    .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
            }
        }
        .padding(8)
    }
}

// More compact theme button for navigation bar
struct ThemeButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingThemeSheet = false

    var body: some View {
        Button(action: {
            showingThemeSheet = true
        }) {
            Image(systemName: themeManager.theme.icon)
                .foregroundColor(Color.appText)
        }
        .sheet(isPresented: $showingThemeSheet) {
            ThemeSelectionView()
                .withTheming()
        }
    }
}

// Sheet view for theme selection
struct ThemeSelectionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(AppTheme.allCases) { theme in
                    HStack {
                        Image(systemName: theme.icon)
                            .font(.title2)
                            .foregroundColor(
                                theme == .light
                                    ? .yellow
                                    : theme == .dark ? Color.appSecondaryAccent : Color.appAccent)

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
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Theme Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color.appBackground)
        }
        #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct ThemeToggleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ThemeToggleView()
            ThemeButton()
            ThemeSelectionView()
        }
        .padding()
        .withTheming()
    }
}
