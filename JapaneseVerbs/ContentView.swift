//
//  ContentView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftUI
import TikimUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @EnvironmentObject var dataManager: VerbDataManager
    @EnvironmentObject private var themeManager: ThemeManager

    #if os(iOS)
        @ViewBuilder
        var iOSContentView: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        VerbListView(searchText: $searchText)
                            .navigationTitle("Japanese Verbs")
                            .navigationBarHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    ThemeButton()
                                }
                            }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(0)

                    NavigationView {
                        FlashCardDeckView()
                            .navigationTitle("Flash Cards")
                            .navigationBarHidden(true)
                            .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                    ThemeButton()
                                }
                            }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(1)

                    NavigationView {
                        SettingsView()
                            .navigationTitle("Settings")
                            .navigationBarHidden(true)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.bottom)

                CustomTabBar(
                    selectedTab: $selectedTab,
                    items: [
                        (icon: "list.bullet", title: "Browse"),
                        (icon: "rectangle.stack", title: "Flash Cards"),
                        (icon: "gear", title: "Settings"),
                    ]
                )
                .padding(.bottom, 8)
            }
        }
    #endif

    #if os(macOS)
        @ViewBuilder
        var macContentView: some View {
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
        }
    #endif

    var body: some View {
        Group {
            #if os(iOS)
                iOSContentView
            #endif
            #if os(macOS)
                macContentView
            #endif
        }
        .onAppear {
            dataManager.loadVerbs()
        }
        .background(Color.appBackground)
        .accentColor(Color.appAccent)
        .withTheming()
    }
}
