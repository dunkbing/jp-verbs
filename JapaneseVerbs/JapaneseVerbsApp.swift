//
//  JapaneseVerbsApp.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 6/4/25.
//

import SwiftData
import SwiftUI

@main
struct JapaneseVerbsApp: App {
    var body: some Scene {
        WindowGroup {
            AppContentView()
        }
        #if os(macOS)
            .windowStyle(.titleBar)
            .windowToolbarStyle(.unified)
        #endif
    }
}

struct AppContentView: View {
    @StateObject private var dataManager = VerbDataManager()

    var body: some View {
        if isCompatibleWithSwiftData {
            // iOS 17+ and macOS 14+
            ContentWithSwiftData(dataManager: dataManager)
        } else {
            // iOS 15/16 and macOS 12/13
            ContentView()
                .environmentObject(dataManager)
        }
    }
}

struct ContentWithSwiftData: View {
    var dataManager: VerbDataManager
    @State private var modelContainer: ModelContainer?
    @State private var error: String?

    init(dataManager: VerbDataManager) {
        self.dataManager = dataManager
    }

    var body: some View {
        ZStack {
            if let container = modelContainer {
                ContentView()
                    .environmentObject(dataManager)
                    .modelContainer(container)
            } else if let error = error {
                ErrorView(message: "Failed to initialize database: \(error)") {
                    Task {
                        await setupModelContainer()
                    }
                }
            } else {
                ProgressView("Initializing...")
                    .onAppear {
                        Task {
                            await setupModelContainer()
                        }
                    }
            }
        }
    }

    @MainActor
    private func setupModelContainer() async {
        do {
            let container = try await PersistenceManager.shared.modelContainer()
            self.modelContainer = container
        } catch {
            self.error = error.localizedDescription
        }
    }
}
