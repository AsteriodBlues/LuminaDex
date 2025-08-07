//
//  AchievementSystem.swift
//  LuminaDex
//
//  Comprehensive achievement system with polished badges
//

import SwiftUI

// MARK: - Achievement Category
enum LuminaAchievementCategory: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case collector = "Collector"
    case explorer = "Explorer"
    case researcher = "Researcher"
    case master = "Master"
    case legendary = "Legendary"
    case social = "Social"
    case battle = "Battle"
    case breeding = "Breeding"
    case trading = "Trading"
    case shiny = "Shiny Hunter"
    case completionist = "Completionist"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .collector: return .blue
        case .explorer: return .orange
        case .researcher: return .purple
        case .master: return .red
        case .legendary: return .yellow
        case .social: return .pink
        case .battle: return .indigo
        case .breeding: return .teal
        case .trading: return .cyan
        case .shiny: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .completionist: return Color(red: 0.9, green: 0.2, blue: 0.9)
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .collector: return "square.stack.3d.up.fill"
        case .explorer: return "map.fill"
        case .researcher: return "magnifyingglass.circle.fill"
        case .master: return "crown.fill"
        case .legendary: return "sparkles"
        case .social: return "person.3.fill"
        case .battle: return "bolt.shield.fill"
        case .breeding: return "heart.circle.fill"
        case .trading: return "arrow.left.arrow.right.circle.fill"
        case .shiny: return "star.circle.fill"
        case .completionist: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Achievement Tier
enum LuminaAchievementTier: Int, CaseIterable, Codable {
    case bronze = 1
    case silver = 2
    case gold = 3
    case platinum = 4
    case diamond = 5
    
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.95)
        case .diamond: return Color(red: 0.73, green: 0.88, blue: 1.0)
        }
    }
    
    var label: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .platinum: return "Platinum"
        case .diamond: return "Diamond"
        }
    }
}

// MARK: - Achievement Model
struct LuminaAchievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let category: LuminaAchievementCategory
    let tier: LuminaAchievementTier
    let requirement: Int
    var progress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    let rewards: [String]
    let isSecret: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        category: LuminaAchievementCategory,
        tier: LuminaAchievementTier,
        requirement: Int,
        progress: Int = 0,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        rewards: [String],
        isSecret: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.tier = tier
        self.requirement = requirement
        self.progress = progress
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.rewards = rewards
        self.isSecret = isSecret
    }
    
    var progressPercentage: Double {
        min(Double(progress) / Double(requirement), 1.0)
    }
}

// MARK: - Achievement Manager
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [LuminaAchievement] = []
    @Published var recentUnlocks: [LuminaAchievement] = []
    @Published var totalPoints: Int = 0
    
    init() {
        loadAllAchievements()
    }
    
    private func loadAllAchievements() {
        achievements = [
            // MARK: - Beginner Achievements
            LuminaAchievement(
                title: "First Steps",
                description: "Catch your first Pokémon",
                icon: "figure.walk",
                category: LuminaAchievementCategory.beginner,
                tier: LuminaAchievementTier.bronze,
                requirement: 1,
                rewards: ["10 XP", "Starter Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Pokédex Initiate",
                description: "Register 10 Pokémon in your Pokédex",
                icon: "book.fill",
                category: LuminaAchievementCategory.beginner,
                tier: LuminaAchievementTier.bronze,
                requirement: 10,
                rewards: ["25 XP", "Scholar Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Type Novice",
                description: "Catch Pokémon of 5 different types",
                icon: "circle.hexagongrid.fill",
                category: LuminaAchievementCategory.beginner,
                tier: LuminaAchievementTier.silver,
                requirement: 5,
                rewards: ["50 XP", "Type Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Early Bird",
                description: "Open the app before 6 AM",
                icon: "sunrise.fill",
                category: LuminaAchievementCategory.beginner,
                tier: LuminaAchievementTier.bronze,
                requirement: 1,
                rewards: ["15 XP", "Early Bird Badge"],
                isSecret: true
            ),
            
            // MARK: - Collector Achievements
            LuminaAchievement(
                title: "Gotta Catch 'Em All",
                description: "Catch 151 original Pokémon",
                icon: "circle.grid.3x3.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.gold,
                requirement: 151,
                rewards: ["500 XP", "Kanto Master Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Generation Master",
                description: "Complete any generation's Pokédex",
                icon: "star.square.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.platinum,
                requirement: 1,
                rewards: ["1000 XP", "Generation Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Living Dex",
                description: "Have one of every Pokémon in storage",
                icon: "square.stack.3d.up.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.diamond,
                requirement: 1025,
                rewards: ["5000 XP", "Living Dex Badge", "Special Frame"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Type Specialist",
                description: "Collect 50 Pokémon of the same type",
                icon: "star.circle.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.silver,
                requirement: 50,
                rewards: ["100 XP", "Type Specialist Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Legendary Hunter",
                description: "Catch 10 Legendary Pokémon",
                icon: "bolt.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.gold,
                requirement: 10,
                rewards: ["250 XP", "Legendary Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Mythical Seeker",
                description: "Catch 5 Mythical Pokémon",
                icon: "sparkles.rectangle.stack.fill",
                category: LuminaAchievementCategory.collector,
                tier: LuminaAchievementTier.platinum,
                requirement: 5,
                rewards: ["500 XP", "Mythical Badge"],
                isSecret: false
            ),
            
            // MARK: - Explorer Achievements
            LuminaAchievement(
                title: "Regional Explorer",
                description: "Visit all regions in the game",
                icon: "map.fill",
                category: LuminaAchievementCategory.explorer,
                tier: LuminaAchievementTier.gold,
                requirement: 9,
                rewards: ["300 XP", "World Traveler Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Route Master",
                description: "Explore 100 different routes",
                icon: "location.fill",
                category: LuminaAchievementCategory.explorer,
                tier: LuminaAchievementTier.silver,
                requirement: 100,
                rewards: ["150 XP", "Pathfinder Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Cave Dweller",
                description: "Explore 20 caves",
                icon: "mountain.2.fill",
                category: LuminaAchievementCategory.explorer,
                tier: LuminaAchievementTier.bronze,
                requirement: 20,
                rewards: ["75 XP", "Spelunker Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Ocean Explorer",
                description: "Catch 30 Water-type Pokémon while surfing",
                icon: "water.waves",
                category: LuminaAchievementCategory.explorer,
                tier: LuminaAchievementTier.silver,
                requirement: 30,
                rewards: ["100 XP", "Surf Badge"],
                isSecret: false
            ),
            
            // MARK: - Researcher Achievements
            LuminaAchievement(
                title: "DNA Analyst",
                description: "Analyze DNA of 50 different Pokémon",
                icon: "waveform.path.ecg",
                category: LuminaAchievementCategory.researcher,
                tier: LuminaAchievementTier.gold,
                requirement: 50,
                rewards: ["200 XP", "Geneticist Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Stat Scholar",
                description: "View detailed stats of 100 Pokémon",
                icon: "chart.bar.fill",
                category: LuminaAchievementCategory.researcher,
                tier: LuminaAchievementTier.silver,
                requirement: 100,
                rewards: ["125 XP", "Analyst Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Evolution Expert",
                description: "Witness 50 evolutions",
                icon: "arrow.triangle.branch",
                category: LuminaAchievementCategory.researcher,
                tier: LuminaAchievementTier.gold,
                requirement: 50,
                rewards: ["175 XP", "Evolution Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Type Effectiveness Pro",
                description: "Master all type matchups",
                icon: "circle.hexagongrid.circle.fill",
                category: LuminaAchievementCategory.researcher,
                tier: LuminaAchievementTier.platinum,
                requirement: 1,
                rewards: ["300 XP", "Type Master Badge"],
                isSecret: false
            ),
            
            // MARK: - Master Achievements
            LuminaAchievement(
                title: "Champion",
                description: "Defeat all Elite Four and Champions",
                icon: "crown.fill",
                category: LuminaAchievementCategory.master,
                tier: LuminaAchievementTier.platinum,
                requirement: 1,
                rewards: ["1000 XP", "Champion Badge", "Champion Crown"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Gym Leader",
                description: "Defeat 50 Gym Leaders",
                icon: "shield.fill",
                category: LuminaAchievementCategory.master,
                tier: LuminaAchievementTier.gold,
                requirement: 50,
                rewards: ["400 XP", "Gym Leader Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Battle Tower Master",
                description: "Win 100 consecutive battles",
                icon: "building.2.fill",
                category: LuminaAchievementCategory.master,
                tier: LuminaAchievementTier.diamond,
                requirement: 100,
                rewards: ["2000 XP", "Tower Master Badge"],
                isSecret: false
            ),
            
            // MARK: - Shiny Hunter Achievements
            LuminaAchievement(
                title: "First Sparkle",
                description: "Encounter your first shiny Pokémon",
                icon: "star.fill",
                category: LuminaAchievementCategory.shiny,
                tier: LuminaAchievementTier.silver,
                requirement: 1,
                rewards: ["100 XP", "Shiny Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Shiny Collection",
                description: "Catch 10 shiny Pokémon",
                icon: "star.square.fill",
                category: LuminaAchievementCategory.shiny,
                tier: LuminaAchievementTier.gold,
                requirement: 10,
                rewards: ["500 XP", "Shiny Hunter Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Rainbow Team",
                description: "Have a full team of shiny Pokémon",
                icon: "star.circle.fill",
                category: LuminaAchievementCategory.shiny,
                tier: LuminaAchievementTier.platinum,
                requirement: 6,
                rewards: ["750 XP", "Rainbow Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Shiny Legendary",
                description: "Catch a shiny legendary Pokémon",
                icon: "star.bubble.fill",
                category: LuminaAchievementCategory.shiny,
                tier: LuminaAchievementTier.diamond,
                requirement: 1,
                rewards: ["1500 XP", "Legendary Shiny Badge"],
                isSecret: true
            ),
            
            // MARK: - Social Achievements
            LuminaAchievement(
                title: "Friendly Trader",
                description: "Complete 10 trades",
                icon: "arrow.left.arrow.right",
                category: LuminaAchievementCategory.social,
                tier: LuminaAchievementTier.bronze,
                requirement: 10,
                rewards: ["50 XP", "Trader Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Battle Buddy",
                description: "Battle 50 different trainers",
                icon: "person.2.fill",
                category: LuminaAchievementCategory.social,
                tier: LuminaAchievementTier.silver,
                requirement: 50,
                rewards: ["150 XP", "Rival Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Gift Giver",
                description: "Send 25 gifts to friends",
                icon: "gift.fill",
                category: LuminaAchievementCategory.social,
                tier: LuminaAchievementTier.bronze,
                requirement: 25,
                rewards: ["75 XP", "Generous Badge"],
                isSecret: false
            ),
            
            // MARK: - Breeding Achievements
            LuminaAchievement(
                title: "First Egg",
                description: "Hatch your first Pokémon egg",
                icon: "oval.fill",
                category: LuminaAchievementCategory.breeding,
                tier: LuminaAchievementTier.bronze,
                requirement: 1,
                rewards: ["25 XP", "Breeder Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Egg Marathon",
                description: "Hatch 100 eggs",
                icon: "oval.portrait.fill",
                category: LuminaAchievementCategory.breeding,
                tier: LuminaAchievementTier.gold,
                requirement: 100,
                rewards: ["300 XP", "Hatcher Badge"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Perfect Breeder",
                description: "Breed a Pokémon with perfect IVs",
                icon: "star.square.on.square.fill",
                category: LuminaAchievementCategory.breeding,
                tier: LuminaAchievementTier.platinum,
                requirement: 1,
                rewards: ["500 XP", "Perfect Badge"],
                isSecret: false
            ),
            
            // MARK: - Secret/Easter Egg Achievements
            LuminaAchievement(
                title: "MissingNo.",
                description: "???",
                icon: "questionmark.square.dashed",
                category: LuminaAchievementCategory.legendary,
                tier: LuminaAchievementTier.diamond,
                requirement: 1,
                rewards: ["??? XP", "Glitch Badge"],
                isSecret: true
            ),
            LuminaAchievement(
                title: "Mew Under the Truck",
                description: "Discover the secret",
                icon: "car.fill",
                category: LuminaAchievementCategory.legendary,
                tier: LuminaAchievementTier.platinum,
                requirement: 1,
                rewards: ["1000 XP", "Secret Badge"],
                isSecret: true
            ),
            LuminaAchievement(
                title: "Speed Demon",
                description: "Complete Pokédex in under 24 hours",
                icon: "hare.fill",
                category: LuminaAchievementCategory.completionist,
                tier: LuminaAchievementTier.diamond,
                requirement: 1,
                rewards: ["5000 XP", "Speedrun Badge"],
                isSecret: true
            ),
            LuminaAchievement(
                title: "Night Owl",
                description: "Play at 3 AM",
                icon: "moon.stars.fill",
                category: LuminaAchievementCategory.beginner,
                tier: LuminaAchievementTier.bronze,
                requirement: 1,
                rewards: ["20 XP", "Night Owl Badge"],
                isSecret: true
            ),
            LuminaAchievement(
                title: "Anniversary",
                description: "Play on Pokémon Day (Feb 27)",
                icon: "calendar.badge.plus",
                category: LuminaAchievementCategory.social,
                tier: LuminaAchievementTier.silver,
                requirement: 1,
                rewards: ["100 XP", "Anniversary Badge"],
                isSecret: true
            ),
            
            // MARK: - Completionist Achievements
            LuminaAchievement(
                title: "100% Complete",
                description: "Unlock all other achievements",
                icon: "checkmark.seal.fill",
                category: LuminaAchievementCategory.completionist,
                tier: LuminaAchievementTier.diamond,
                requirement: 1,
                rewards: ["10000 XP", "Completionist Badge", "Special Title"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Badge Collector",
                description: "Collect all gym badges",
                icon: "shield.lefthalf.filled",
                category: LuminaAchievementCategory.completionist,
                tier: LuminaAchievementTier.gold,
                requirement: 48,
                rewards: ["600 XP", "Badge Master"],
                isSecret: false
            ),
            LuminaAchievement(
                title: "Berry Master",
                description: "Collect all berry types",
                icon: "leaf.circle.fill",
                category: LuminaAchievementCategory.completionist,
                tier: LuminaAchievementTier.silver,
                requirement: 64,
                rewards: ["200 XP", "Berry Badge"],
                isSecret: false
            )
        ]
    }
    
    func checkAchievement(_ achievementTitle: String, progress: Int) {
        if let index = achievements.firstIndex(where: { $0.title == achievementTitle }) {
            achievements[index].progress = min(progress, achievements[index].requirement)
            
            if achievements[index].progress >= achievements[index].requirement && !achievements[index].isUnlocked {
                unlockAchievement(at: index)
            }
        }
    }
    
    private func unlockAchievement(at index: Int) {
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        recentUnlocks.append(achievements[index])
        
        // Calculate points based on tier
        totalPoints += achievements[index].tier.rawValue * 100
        
        // Keep only last 5 recent unlocks
        if recentUnlocks.count > 5 {
            recentUnlocks.removeFirst()
        }
    }
}