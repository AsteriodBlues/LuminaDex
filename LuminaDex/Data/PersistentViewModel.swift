//
//  PersistentViewModel.swift
//  LuminaDex
//
//  Day 24: ViewModel with persistent storage
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PersistentViewModel: ObservableObject {
    static let shared = PersistentViewModel()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Published Properties with Persistence
    @Published var viewMode: ViewMode {
        didSet {
            defaults.viewMode = viewMode
        }
    }
    
    @Published var sortOption: SortOption {
        didSet {
            defaults.sortOption = sortOption
        }
    }
    
    @Published var caughtPokemonIds: Set<Int> {
        didSet {
            defaults.caughtPokemonIds = caughtPokemonIds
            defaults.set(caughtPokemonIds.count, forKey: DefaultsKeys.totalCaughtCount)
        }
    }
    
    @Published var favoritePokemonIds: Set<Int> {
        didSet {
            defaults.favoritePokemonIds = favoritePokemonIds
        }
    }
    
    @Published var recentSearches: [String] {
        didSet {
            // Keep only the last N searches
            let limit = defaults.searchHistoryLimit
            if recentSearches.count > limit {
                recentSearches = Array(recentSearches.prefix(limit))
            }
            defaults.recentSearches = recentSearches
        }
    }
    
    @Published var selectedCompanionId: Int? {
        didSet {
            defaults.selectedCompanionId = selectedCompanionId
        }
    }
    
    @Published var companionNickname: String? {
        didSet {
            defaults.companionNickname = companionNickname
        }
    }
    
    @Published var unlockedAchievements: Set<Int> {
        didSet {
            defaults.unlockedAchievements = unlockedAchievements
        }
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let keychainManager = KeychainManager.shared
    
    // MARK: - Initialization
    private init() {
        // Load from UserDefaults
        self.viewMode = defaults.viewMode
        self.sortOption = defaults.sortOption
        self.caughtPokemonIds = defaults.caughtPokemonIds
        self.favoritePokemonIds = defaults.favoritePokemonIds
        self.recentSearches = defaults.recentSearches
        self.selectedCompanionId = defaults.selectedCompanionId
        self.companionNickname = defaults.companionNickname
        self.unlockedAchievements = defaults.unlockedAchievements
        
        // Track app launches
        incrementAppLaunchCount()
        
        // Setup observers
        setupObservers()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Auto-save filter criteria when it changes
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.saveCurrentState()
            }
            .store(in: &cancellables)
        
        // Sync data when app becomes active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.syncDataIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Pokemon Management
    func toggleCaught(pokemonId: Int) {
        if caughtPokemonIds.contains(pokemonId) {
            caughtPokemonIds.remove(pokemonId)
        } else {
            caughtPokemonIds.insert(pokemonId)
            
            // Check achievements
            checkCaughtAchievements()
        }
    }
    
    func toggleFavorite(pokemonId: Int) {
        if favoritePokemonIds.contains(pokemonId) {
            favoritePokemonIds.remove(pokemonId)
        } else {
            favoritePokemonIds.insert(pokemonId)
        }
    }
    
    func isCaught(pokemonId: Int) -> Bool {
        caughtPokemonIds.contains(pokemonId)
    }
    
    func isFavorite(pokemonId: Int) -> Bool {
        favoritePokemonIds.contains(pokemonId)
    }
    
    // MARK: - Search History
    func addSearchTerm(_ term: String) {
        // Remove if already exists (to move to front)
        recentSearches.removeAll { $0 == term }
        
        // Add to front
        recentSearches.insert(term, at: 0)
        
        // Increment search count
        defaults.totalSearches += 1
    }
    
    func clearSearchHistory() {
        recentSearches.removeAll()
    }
    
    // MARK: - Companion System
    func selectCompanion(pokemonId: Int, nickname: String? = nil) {
        selectedCompanionId = pokemonId
        companionNickname = nickname
        defaults.companionLevel = 1
        defaults.companionExperience = 0
    }
    
    func updateCompanionExperience(_ exp: Int) {
        let currentExp = defaults.companionExperience
        let newExp = currentExp + exp
        defaults.companionExperience = newExp
        
        // Check for level up
        let currentLevel = defaults.companionLevel
        let expForNextLevel = currentLevel * 100
        
        if newExp >= expForNextLevel {
            defaults.companionLevel = currentLevel + 1
            defaults.companionExperience = newExp - expForNextLevel
            
            // Show level up notification
            showLevelUpNotification(level: currentLevel + 1)
        }
    }
    
    // MARK: - Achievements
    func checkCaughtAchievements() {
        let caughtCount = caughtPokemonIds.count
        
        // Check milestones
        let milestones = [10, 25, 50, 100, 151, 250, 500, 1000]
        for milestone in milestones {
            if caughtCount >= milestone {
                unlockAchievement(id: milestone)
            }
        }
    }
    
    func unlockAchievement(id: Int) {
        if !unlockedAchievements.contains(id) {
            unlockedAchievements.insert(id)
            
            // Show achievement notification
            showAchievementNotification(id: id)
        }
    }
    
    func getAchievementProgress(id: Int) -> Int {
        return defaults.achievementProgress[id] ?? 0
    }
    
    func updateAchievementProgress(id: Int, progress: Int) {
        var currentProgress = defaults.achievementProgress
        currentProgress[id] = progress
        defaults.achievementProgress = currentProgress
    }
    
    // MARK: - Statistics
    private func incrementAppLaunchCount() {
        defaults.totalAppLaunches += 1
        
        if defaults.firstLaunchDate == nil {
            defaults.firstLaunchDate = Date()
        }
    }
    
    func incrementComparisonCount() {
        defaults.totalComparisons += 1
    }
    
    // MARK: - Data Sync
    func syncDataIfNeeded() async {
        guard let lastSync = defaults.object(forKey: DefaultsKeys.lastSyncDate) as? Date else {
            // First sync
            await performSync()
            return
        }
        
        // Sync if more than 24 hours have passed
        let hoursSinceLastSync = Date().timeIntervalSince(lastSync) / 3600
        if hoursSinceLastSync > 24 {
            await performSync()
        }
    }
    
    private func performSync() async {
        // Check if cloud sync is enabled
        do {
            let cloudSyncEnabled = try keychainManager.isCloudSyncEnabled()
            guard cloudSyncEnabled else { return }
            
            // Perform sync operations here
            // This would typically involve:
            // 1. Uploading local changes
            // 2. Downloading remote changes
            // 3. Merging conflicts
            
            defaults.set(Date(), forKey: DefaultsKeys.lastSyncDate)
        } catch {
            print("Sync error: \(error)")
        }
    }
    
    // MARK: - Backup & Restore
    func createBackup() throws {
        let backupData = BackupData(
            caughtPokemonIds: Array(caughtPokemonIds),
            favoritePokemonIds: Array(favoritePokemonIds),
            unlockedAchievements: Array(unlockedAchievements),
            companionId: selectedCompanionId,
            companionNickname: companionNickname,
            backupDate: Date()
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(backupData)
        try keychainManager.saveBackupData(data)
    }
    
    func restoreFromBackup() throws {
        guard let data = try keychainManager.getBackupData() else {
            throw BackupError.noBackupFound
        }
        
        let decoder = JSONDecoder()
        let backupData = try decoder.decode(BackupData.self, from: data)
        
        // Restore data
        caughtPokemonIds = Set(backupData.caughtPokemonIds)
        favoritePokemonIds = Set(backupData.favoritePokemonIds)
        unlockedAchievements = Set(backupData.unlockedAchievements)
        selectedCompanionId = backupData.companionId
        companionNickname = backupData.companionNickname
    }
    
    // MARK: - State Management
    private func saveCurrentState() {
        // This is called when app goes to background
        // Most properties auto-save via didSet, but we can do additional cleanup here
        do {
            try createBackup()
        } catch {
            print("Failed to create backup: \(error)")
        }
    }
    
    func resetAllData() {
        caughtPokemonIds.removeAll()
        favoritePokemonIds.removeAll()
        recentSearches.removeAll()
        selectedCompanionId = nil
        companionNickname = nil
        unlockedAchievements.removeAll()
        
        // Reset defaults
        let keysToReset = [
            DefaultsKeys.caughtPokemonIds,
            DefaultsKeys.favoritePokemonIds,
            DefaultsKeys.recentSearches,
            DefaultsKeys.selectedCompanionId,
            DefaultsKeys.companionNickname,
            DefaultsKeys.unlockedAchievements
        ]
        
        for key in keysToReset {
            defaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - Notifications
    private func showAchievementNotification(id: Int) {
        // Implementation would show in-app notification
        print("Achievement unlocked: \(id)")
    }
    
    private func showLevelUpNotification(level: Int) {
        // Implementation would show in-app notification
        print("Companion leveled up to: \(level)")
    }
}

// MARK: - Supporting Types
struct BackupData: Codable {
    let caughtPokemonIds: [Int]
    let favoritePokemonIds: [Int]
    let unlockedAchievements: [Int]
    let companionId: Int?
    let companionNickname: String?
    let backupDate: Date
}

enum BackupError: LocalizedError {
    case noBackupFound
    case corruptedBackup
    
    var errorDescription: String? {
        switch self {
        case .noBackupFound:
            return "No backup data found"
        case .corruptedBackup:
            return "Backup data is corrupted"
        }
    }
}