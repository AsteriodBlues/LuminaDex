//
//  AchievementTracker.swift
//  LuminaDex
//
//  Service to automatically track and update achievement progress
//

import SwiftUI
import Combine

class AchievementTracker: ObservableObject {
    static let shared = AchievementTracker()
    
    private let manager = AchievementManager.shared
    @Published var showNotification = false
    @Published var currentUnlock: LuminaAchievement?
    @Published var queuedUnlocks: [LuminaAchievement] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupTracking()
    }
    
    private func setupTracking() {
        // Track collection changes
        NotificationCenter.default.publisher(for: Notification.Name("PokemonCaught"))
            .sink { [weak self] notification in
                if let pokemon = notification.object as? Pokemon {
                    self?.onPokemonCaught(pokemon)
                }
            }
            .store(in: &cancellables)
        
        // Track DNA analysis
        NotificationCenter.default.publisher(for: Notification.Name("DNAAnalyzed"))
            .sink { [weak self] notification in
                if let pokemon = notification.object as? Pokemon {
                    self?.onDNAAnalyzed(pokemon)
                }
            }
            .store(in: &cancellables)
        
        // Track battles
        NotificationCenter.default.publisher(for: Notification.Name("BattleWon"))
            .sink { [weak self] _ in
                self?.onBattleWon()
            }
            .store(in: &cancellables)
        
        // Track app usage
        trackAppUsageTime()
    }
    
    // MARK: - Pokemon Collection Tracking
    func onPokemonCaught(_ pokemon: Pokemon) {
        // First Steps
        updateAchievement("First Steps", progress: 1)
        
        // Pokédex Initiate
        let caughtCount = UserDefaults.standard.integer(forKey: "totalPokemonCaught") + 1
        UserDefaults.standard.set(caughtCount, forKey: "totalPokemonCaught")
        updateAchievement("Pokédex Initiate", progress: min(caughtCount, 10))
        
        // Gotta Catch 'Em All (Kanto)
        if pokemon.id <= 151 {
            let kantoCount = UserDefaults.standard.integer(forKey: "kantoPokemonCaught") + 1
            UserDefaults.standard.set(kantoCount, forKey: "kantoPokemonCaught")
            updateAchievement("Gotta Catch 'Em All", progress: kantoCount)
        }
        
        // Type Specialist
        trackTypeCollection(pokemon)
        
        // Legendary Hunter
        if isLegendary(pokemon) {
            let legendaryCount = UserDefaults.standard.integer(forKey: "legendaryPokemonCaught") + 1
            UserDefaults.standard.set(legendaryCount, forKey: "legendaryPokemonCaught")
            updateAchievement("Legendary Hunter", progress: legendaryCount)
        }
        
        // Shiny tracking - check if sprite URL contains "shiny"
        if let spriteURL = pokemon.sprites.frontShiny, !spriteURL.isEmpty {
            // Has shiny sprite, could be a shiny variant
            // This would need actual game logic to determine if caught as shiny
        }
    }
    
    private func trackTypeCollection(_ pokemon: Pokemon) {
        let typeKey = "type_\(pokemon.primaryType.rawValue)_count"
        let typeCount = UserDefaults.standard.integer(forKey: typeKey) + 1
        UserDefaults.standard.set(typeCount, forKey: typeKey)
        
        // Type Novice - collect 5 different types
        var uniqueTypes = Set<String>()
        for type in PokemonType.allCases {
            let key = "type_\(type.rawValue)_count"
            if UserDefaults.standard.integer(forKey: key) > 0 {
                uniqueTypes.insert(type.rawValue)
            }
        }
        updateAchievement("Type Novice", progress: uniqueTypes.count)
        
        // Type Specialist - 50 of same type
        if typeCount >= 50 {
            updateAchievement("Type Specialist", progress: 50)
        }
    }
    
    // MARK: - DNA Analysis Tracking
    func onDNAAnalyzed(_ pokemon: Pokemon) {
        let dnaCount = UserDefaults.standard.integer(forKey: "dnaAnalyzedCount") + 1
        UserDefaults.standard.set(dnaCount, forKey: "dnaAnalyzedCount")
        updateAchievement("DNA Analyst", progress: min(dnaCount, 50))
    }
    
    // MARK: - Battle Tracking
    func onBattleWon() {
        let battleCount = UserDefaults.standard.integer(forKey: "battlesWon") + 1
        UserDefaults.standard.set(battleCount, forKey: "battlesWon")
        
        // Track consecutive wins
        let consecutiveWins = UserDefaults.standard.integer(forKey: "consecutiveWins") + 1
        UserDefaults.standard.set(consecutiveWins, forKey: "consecutiveWins")
        updateAchievement("Battle Tower Master", progress: consecutiveWins)
    }
    
    func onBattleLost() {
        UserDefaults.standard.set(0, forKey: "consecutiveWins")
    }
    
    // MARK: - Shiny Tracking
    private func onShinyCaught(_ pokemon: Pokemon) {
        let shinyCount = UserDefaults.standard.integer(forKey: "shinyCaught") + 1
        UserDefaults.standard.set(shinyCount, forKey: "shinyCaught")
        
        updateAchievement("First Sparkle", progress: 1)
        updateAchievement("Shiny Collection", progress: min(shinyCount, 10))
        
        if isLegendary(pokemon) {
            updateAchievement("Shiny Legendary", progress: 1)
        }
    }
    
    // MARK: - Trading Tracking
    func onTradeCompleted() {
        let tradeCount = UserDefaults.standard.integer(forKey: "tradesCompleted") + 1
        UserDefaults.standard.set(tradeCount, forKey: "tradesCompleted")
        updateAchievement("Friendly Trader", progress: min(tradeCount, 10))
    }
    
    // MARK: - Breeding Tracking
    func onEggHatched() {
        let eggCount = UserDefaults.standard.integer(forKey: "eggsHatched") + 1
        UserDefaults.standard.set(eggCount, forKey: "eggsHatched")
        
        updateAchievement("First Egg", progress: 1)
        updateAchievement("Egg Marathon", progress: min(eggCount, 100))
    }
    
    // MARK: - Time-based Achievements
    private func trackAppUsageTime() {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        
        // Early Bird - before 6 AM
        if hour < 6 {
            updateAchievement("Early Bird", progress: 1)
        }
        
        // Night Owl - at 3 AM
        if hour == 3 {
            updateAchievement("Night Owl", progress: 1)
        }
        
        // Anniversary - February 27
        let components = Calendar.current.dateComponents([.month, .day], from: now)
        if components.month == 2 && components.day == 27 {
            updateAchievement("Anniversary", progress: 1)
        }
    }
    
    // MARK: - Stats Tracking
    func onPokemonViewed(_ pokemon: Pokemon) {
        let viewCount = UserDefaults.standard.integer(forKey: "pokemonViewed") + 1
        UserDefaults.standard.set(viewCount, forKey: "pokemonViewed")
        updateAchievement("Stat Scholar", progress: min(viewCount, 100))
    }
    
    func onEvolutionWitnessed() {
        let evoCount = UserDefaults.standard.integer(forKey: "evolutionsWitnessed") + 1
        UserDefaults.standard.set(evoCount, forKey: "evolutionsWitnessed")
        updateAchievement("Evolution Expert", progress: min(evoCount, 50))
    }
    
    // MARK: - Achievement Update
    private func updateAchievement(_ title: String, progress: Int) {
        if let index = manager.achievements.firstIndex(where: { $0.title == title }) {
            let achievement = manager.achievements[index]
            
            // Only update if not already unlocked
            if !achievement.isUnlocked {
                manager.achievements[index].progress = progress
                
                // Check if newly unlocked
                if progress >= achievement.requirement {
                    unlockAchievement(at: index)
                }
            }
        }
    }
    
    private func unlockAchievement(at index: Int) {
        manager.achievements[index].isUnlocked = true
        manager.achievements[index].unlockedDate = Date()
        
        let unlockedAchievement = manager.achievements[index]
        
        // Add to queue
        queuedUnlocks.append(unlockedAchievement)
        
        // Show notification
        if !showNotification {
            showNextUnlock()
        }
        
        // Save to UserDefaults
        saveAchievementProgress()
        
        // Post notification for other parts of app
        NotificationCenter.default.post(
            name: Notification.Name("AchievementUnlocked"),
            object: unlockedAchievement
        )
        
        // Check for completionist achievement
        checkCompletionistAchievement()
    }
    
    private func showNextUnlock() {
        guard !queuedUnlocks.isEmpty else { return }
        
        currentUnlock = queuedUnlocks.removeFirst()
        showNotification = true
        
        // Schedule next unlock notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.showNotification = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showNextUnlock()
            }
        }
    }
    
    private func checkCompletionistAchievement() {
        let totalAchievements = manager.achievements.count - 1 // Exclude completionist itself
        let unlockedCount = manager.achievements.filter { $0.isUnlocked && $0.title != "100% Complete" }.count
        
        if unlockedCount >= totalAchievements {
            updateAchievement("100% Complete", progress: 1)
        }
    }
    
    // MARK: - Helper Methods
    private func isLegendary(_ pokemon: Pokemon) -> Bool {
        let legendaryIds = [144, 145, 146, 150, 151, 243, 244, 245, 249, 250, 251] // Add more
        return legendaryIds.contains(pokemon.id)
    }
    
    private func isMythical(_ pokemon: Pokemon) -> Bool {
        let mythicalIds = [151, 251, 385, 386, 489, 490, 491, 492, 493] // Add more
        return mythicalIds.contains(pokemon.id)
    }
    
    // MARK: - Persistence
    private func saveAchievementProgress() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(manager.achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    func loadAchievementProgress() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let achievements = try? JSONDecoder().decode([LuminaAchievement].self, from: data) {
            manager.achievements = achievements
        }
    }
}

// MARK: - Extension for posting notifications
extension Notification.Name {
    static let pokemonCaught = Notification.Name("PokemonCaught")
    static let dnaAnalyzed = Notification.Name("DNAAnalyzed")
    static let battleWon = Notification.Name("BattleWon")
    static let achievementUnlocked = Notification.Name("AchievementUnlocked")
}