//
//  ContentView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct ContentView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var searchText = ""
    @State private var selectedTab = 0
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                VerbListView(searchText: $searchText)
                    .navigationTitle("Japanese Verbs")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            ThemeButton()
                        }
                    }
            }
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            .tag(0)

            NavigationView {
                FlashCardDeckView()
                    .navigationTitle("Flash Cards")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            ThemeButton()
                        }
                    }
            }
            .tabItem {
                Label("Flash Cards", systemImage: "rectangle.stack")
            }
            .tag(1)

            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .onAppear {
            dataManager.loadVerbs()
        }
        .background(Color.appBackground)
        .accentColor(Color.appAccent)
        .withTheming()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VerbDataManager())
            .withTheming()
    }
}
