//
//  JapaneseVerbsApp.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftData
import SwiftUI
import TikimUI

@main
struct DoushiApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = VerbDataManager()
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Apply the background color to the entire window
                Color.appBackground
                    .edgesIgnoringSafeArea(.all)

                // Main content based on loading state
                if isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .modelContainer(try! PersistenceManager.shared.modelContainer())
                        .environmentObject(dataManager)
                        .transition(.opacity)
                }
            }
            .accentColor(Color.appAccent)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .withTheming()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isLoading = false
                    }
                    dataManager.loadVerbs()
                }
            }
        }
        #if os(macOS)
            .windowStyle(.titleBar)
            .windowToolbarStyle(.unified)
        #endif
    }
}

struct LoadingView: View {
    @State private var isRotating = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.appAccent)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false),
                    value: isRotating
                )
                .onAppear {
                    self.isRotating = true
                }

            Text("doushi")
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundColor(Color.appText)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
                .padding(.top)
        }
        .padding()
        .background(Color.appSurface.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: Color.appText.opacity(0.1), radius: 10)
    }
}
