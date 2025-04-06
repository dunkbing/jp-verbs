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
struct JapaneseVerbsApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isLoading = true
    @State private var modelContainer: ModelContainer?
    @State private var error: String?
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Apply the background color to the entire window
                Color.appBackground
                    .edgesIgnoringSafeArea(.all)

                // Main content based on loading state
                if showSplash {
                    SplashScreenView {
                        withAnimation {
                            self.showSplash = false
                        }
                    }
                } else if isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else if let error = error {
                    ErrorView(message: "Failed to initialize app: \(error)") {
                        Task {
                            await setupModelContainer()
                        }
                    }
                    .transition(.opacity)
                } else if let container = modelContainer {
                    if isCompatibleWithSwiftData {
                        ContentView()
                            .environmentObject(createDataManager() as! VerbDataManager)
                            .modelContainer(container)
                            .transition(.opacity)
                    } else {
                        ContentView()
                            .environmentObject(createDataManager() as! LegacyVerbDataManager)
                            .transition(.opacity)
                    }
                } else {
                    if isCompatibleWithSwiftData {
                        ContentView()
                            .environmentObject(createDataManager() as! VerbDataManager)
                            .transition(.opacity)
                    } else {
                        ContentView()
                            .environmentObject(createDataManager() as! LegacyVerbDataManager)
                            .transition(.opacity)
                    }
                }
            }
            .accentColor(Color.appAccent)
            .withTheming()
            .onAppear {
                // Start loading in the background while splash is showing
                Task {
                    await setupModelContainer()
                }
            }
        }
        #if os(macOS)
            .windowStyle(.titleBar)
            .windowToolbarStyle(.unified)
        #endif
    }

    @MainActor
    private func setupModelContainer() async {
        // Add a slight delay to ensure splash screen shows properly
        try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second

        if isCompatibleWithSwiftData {
            do {
                let container = try await PersistenceManager.shared.modelContainer()
                self.modelContainer = container
                withAnimation {
                    self.isLoading = false
                }
            } catch {
                withAnimation {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        } else {
            // For older systems without SwiftData
            withAnimation {
                self.isLoading = false
            }
        }
    }

    @MainActor
    private func createDataManager() -> Any {
        if isCompatibleWithSwiftData {
            return VerbDataManager()
        } else {
            return LegacyVerbDataManager()
        }
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

            Text("Loading Japanese Verbs")
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
