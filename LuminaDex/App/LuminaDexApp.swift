//
//  LuminaDexApp.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//

import SwiftUI
import GRDB

@main
struct LuminaDexApp: App {
    @StateObject private var database = DatabaseManager.shared
    @StateObject private var dataFetcher = PokemonDataFetcher.shared
    @StateObject private var imageManager = ImageManager.shared
    @StateObject private var achievementTracker = AchievementTracker.shared
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var showSplashScreen = true
    
    init() {
        // Database initialization happens automatically in DatabaseManager
        print("✅ LuminaDex app initialized")
        
        // Load saved achievement progress
        AchievementTracker.shared.loadAchievementProgress()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreenView(isActive: $showSplashScreen)
                        .transition(.opacity)
                } else {
                    ZStack {
                        ContentView()
                            .environmentObject(database)
                            .environmentObject(dataFetcher)
                            .environmentObject(imageManager)
                            .environmentObject(achievementTracker)
                            .environmentObject(achievementManager)
                        
                        // Achievement Notification Overlay  
                        AchievementNotificationOverlay()
                            .environmentObject(achievementTracker)
                    }
                    .transition(.opacity)
                    .onAppear {
                        Task {
                            // Check if we need to fetch data
                            let info = try? await database.getDatabaseInfo()
                            if info?.pokemonCount == 0 {
                                print("🚀 Starting initial data fetch...")
                                await dataFetcher.fetchAllPokemonData()
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplashScreen)
        }
    }
}
