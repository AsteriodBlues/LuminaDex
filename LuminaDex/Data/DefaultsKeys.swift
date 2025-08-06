//
//  DefaultsKeys.swift
//  LuminaDex
//
//  Day 24: UserDefaults keys for data persistence
//

import Foundation

enum DefaultsKeys {
    // User Preferences
    static let viewMode = "viewMode"
    static let sortOption = "sortOption"
    static let selectedTheme = "selectedTheme"
    static let enableHaptics = "enableHaptics"
    static let enableSounds = "enableSounds"
    static let enableAnimations = "enableAnimations"
    
    // Collection State
    static let caughtPokemonIds = "caughtPokemonIds"
    static let favoritePokemonIds = "favoritePokemonIds"
    static let lastSyncDate = "lastSyncDate"
    static let totalCaughtCount = "totalCaughtCount"
    
    // Search History
    static let recentSearches = "recentSearches"
    static let searchHistoryLimit = "searchHistoryLimit"
    
    // Filter Preferences
    static let savedFilterCriteria = "savedFilterCriteria"
    static let quickFilterOptions = "quickFilterOptions"
    
    // Achievements
    static let unlockedAchievements = "unlockedAchievements"
    static let achievementProgress = "achievementProgress"
    
    // Companion System
    static let selectedCompanionId = "selectedCompanionId"
    static let companionNickname = "companionNickname"
    static let companionLevel = "companionLevel"
    static let companionExperience = "companionExperience"
    
    // Statistics
    static let totalAppLaunches = "totalAppLaunches"
    static let firstLaunchDate = "firstLaunchDate"
    static let totalSearches = "totalSearches"
    static let totalComparisons = "totalComparisons"
    
    // Onboarding
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasSeenTutorial = "hasSeenTutorial"
    static let tutorialProgress = "tutorialProgress"
}

// MARK: - Theme Option
enum ThemeOption: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case neural = "Neural"
}

// MARK: - UserDefaults Extension for Easy Access
extension UserDefaults {
    
    // MARK: - ViewMode
    var viewMode: ViewMode {
        get {
            guard let rawValue = string(forKey: DefaultsKeys.viewMode),
                  let mode = ViewMode(rawValue: rawValue) else {
                return .grid
            }
            return mode
        }
        set {
            set(newValue.rawValue, forKey: DefaultsKeys.viewMode)
        }
    }
    
    // MARK: - SortOption
    var sortOption: SortOption {
        get {
            guard let rawValue = string(forKey: DefaultsKeys.sortOption),
                  let option = SortOption(rawValue: rawValue) else {
                return .number
            }
            return option
        }
        set {
            set(newValue.rawValue, forKey: DefaultsKeys.sortOption)
        }
    }
    
    // MARK: - Theme
    var selectedTheme: ThemeOption {
        get {
            guard let rawValue = string(forKey: DefaultsKeys.selectedTheme),
                  let theme = ThemeOption(rawValue: rawValue) else {
                return .system
            }
            return theme
        }
        set {
            set(newValue.rawValue, forKey: DefaultsKeys.selectedTheme)
        }
    }
    
    // MARK: - Boolean Preferences
    var enableHaptics: Bool {
        get { bool(forKey: DefaultsKeys.enableHaptics) }
        set { set(newValue, forKey: DefaultsKeys.enableHaptics) }
    }
    
    var enableSounds: Bool {
        get { bool(forKey: DefaultsKeys.enableSounds) }
        set { set(newValue, forKey: DefaultsKeys.enableSounds) }
    }
    
    var enableAnimations: Bool {
        get { bool(forKey: DefaultsKeys.enableAnimations) }
        set { set(newValue, forKey: DefaultsKeys.enableAnimations) }
    }
    
    // MARK: - Collection State
    var caughtPokemonIds: Set<Int> {
        get {
            guard let array = array(forKey: DefaultsKeys.caughtPokemonIds) as? [Int] else {
                return []
            }
            return Set(array)
        }
        set {
            set(Array(newValue), forKey: DefaultsKeys.caughtPokemonIds)
        }
    }
    
    var favoritePokemonIds: Set<Int> {
        get {
            guard let array = array(forKey: DefaultsKeys.favoritePokemonIds) as? [Int] else {
                return []
            }
            return Set(array)
        }
        set {
            set(Array(newValue), forKey: DefaultsKeys.favoritePokemonIds)
        }
    }
    
    // MARK: - Search History
    var recentSearches: [String] {
        get { array(forKey: DefaultsKeys.recentSearches) as? [String] ?? [] }
        set { set(newValue, forKey: DefaultsKeys.recentSearches) }
    }
    
    var searchHistoryLimit: Int {
        get {
            let limit = integer(forKey: DefaultsKeys.searchHistoryLimit)
            return limit > 0 ? limit : 10
        }
        set { set(newValue, forKey: DefaultsKeys.searchHistoryLimit) }
    }
    
    // MARK: - Achievements
    var unlockedAchievements: Set<Int> {
        get {
            guard let array = array(forKey: DefaultsKeys.unlockedAchievements) as? [Int] else {
                return []
            }
            return Set(array)
        }
        set {
            set(Array(newValue), forKey: DefaultsKeys.unlockedAchievements)
        }
    }
    
    var achievementProgress: [Int: Int] {
        get { dictionary(forKey: DefaultsKeys.achievementProgress) as? [Int: Int] ?? [:] }
        set { set(newValue, forKey: DefaultsKeys.achievementProgress) }
    }
    
    // MARK: - Companion
    var selectedCompanionId: Int? {
        get {
            let id = integer(forKey: DefaultsKeys.selectedCompanionId)
            return id > 0 ? id : nil
        }
        set { set(newValue ?? 0, forKey: DefaultsKeys.selectedCompanionId) }
    }
    
    var companionNickname: String? {
        get { string(forKey: DefaultsKeys.companionNickname) }
        set { set(newValue, forKey: DefaultsKeys.companionNickname) }
    }
    
    var companionLevel: Int {
        get {
            let level = integer(forKey: DefaultsKeys.companionLevel)
            return level > 0 ? level : 1
        }
        set { set(newValue, forKey: DefaultsKeys.companionLevel) }
    }
    
    var companionExperience: Int {
        get { integer(forKey: DefaultsKeys.companionExperience) }
        set { set(newValue, forKey: DefaultsKeys.companionExperience) }
    }
    
    // MARK: - Statistics
    var totalAppLaunches: Int {
        get { integer(forKey: DefaultsKeys.totalAppLaunches) }
        set { set(newValue, forKey: DefaultsKeys.totalAppLaunches) }
    }
    
    var firstLaunchDate: Date? {
        get { object(forKey: DefaultsKeys.firstLaunchDate) as? Date }
        set { set(newValue, forKey: DefaultsKeys.firstLaunchDate) }
    }
    
    var totalSearches: Int {
        get { integer(forKey: DefaultsKeys.totalSearches) }
        set { set(newValue, forKey: DefaultsKeys.totalSearches) }
    }
    
    var totalComparisons: Int {
        get { integer(forKey: DefaultsKeys.totalComparisons) }
        set { set(newValue, forKey: DefaultsKeys.totalComparisons) }
    }
    
    // MARK: - Onboarding
    var hasCompletedOnboarding: Bool {
        get { bool(forKey: DefaultsKeys.hasCompletedOnboarding) }
        set { set(newValue, forKey: DefaultsKeys.hasCompletedOnboarding) }
    }
    
    var hasSeenTutorial: Bool {
        get { bool(forKey: DefaultsKeys.hasSeenTutorial) }
        set { set(newValue, forKey: DefaultsKeys.hasSeenTutorial) }
    }
    
    var tutorialProgress: Int {
        get { integer(forKey: DefaultsKeys.tutorialProgress) }
        set { set(newValue, forKey: DefaultsKeys.tutorialProgress) }
    }
}