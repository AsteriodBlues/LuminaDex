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
    
    init() {
        // Database initialization happens automatically in DatabaseManager
        print("✅ LuminaDex app initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(database)
                .environmentObject(dataFetcher)
                .environmentObject(imageManager)
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
}
