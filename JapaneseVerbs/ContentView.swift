//
//  ContentView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: VerbDataManager
    @State private var searchText = ""
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                VerbListView(searchText: $searchText)
                    .navigationTitle("Japanese Verbs")
            }
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }
            .tag(0)

            NavigationView {
                FlashCardDeckView()
                    .navigationTitle("Flash Cards")
            }
            .tabItem {
                Label("Flash Cards", systemImage: "rectangle.stack")
            }
            .tag(1)
        }
        .onAppear {
            dataManager.loadVerbs()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VerbDataManager())
    }
}
