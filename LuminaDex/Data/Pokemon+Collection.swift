//
//  Pokemon+Collection.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//

import SwiftUI
import Foundation

// MARK: - Collection Properties Extension
extension Pokemon {
    
    // MARK: - Collection Status
    var collectionStatus: CollectionStatus {
        if isCaught {
            return .caught
        } else if isFavorite {
            return .favorite
        } else if progress > 0 {
            return .seen
        } else {
            return .undiscovered
        }
    }
    
    var discoveryProgress: Double {
        switch collectionStatus {
        case .undiscovered:
            return 0.0
        case .seen:
            return progress
        case .favorite:
            return max(progress, 0.5)
        case .caught:
            return 1.0
        }
    }
    
    // MARK: - Stats Helpers
    var totalStats: Int {
        stats.reduce(0) { $0 + $1.baseStat }
    }
    
    var averageStats: Double {
        guard !stats.isEmpty else { return 0 }
        return Double(totalStats) / Double(stats.count)
    }
    
    var statRating: StatRating {
        let total = totalStats
        switch total {
        case 0..<300:
            return .poor
        case 300..<400:
            return .below
        case 400..<500:
            return .average
        case 500..<600:
            return .good
        case 600..<700:
            return .excellent
        default:
            return .legendary
        }
    }
    
    // MARK: - Collection Lists
    var customLists: [String] {
        var lists: [String] = []
        
        if isFavorite {
            lists.append("Favorites")
        }
        
        if isCaught {
            lists.append("Caught")
        }
        
        // Add type-based collections
        if types.contains(where: { $0.type == .fire }) {
            lists.append("Fire Team")
        }
        
        if types.contains(where: { $0.type == .water }) {
            lists.append("Water Team")
        }
        
        if types.contains(where: { $0.type == .electric }) {
            lists.append("Electric Team")
        }
        
        // Add stat-based collections
        if statRating == .legendary || statRating == .excellent {
            lists.append("Powerhouse")
        }
        
        return lists
    }
    
    // MARK: - Search Properties
    var searchableText: String {
        let typeNames = types.map { $0.type.displayName }.joined(separator: " ")
        let abilityNames = abilities.map { $0.ability.displayName }.joined(separator: " ")
        
        return "\(displayName) \(typeNames) \(abilityNames) #\(id)".lowercased()
    }
    
    // MARK: - Achievement Progress
    var achievementContributions: [AchievementType: Double] {
        var contributions: [AchievementType: Double] = [:]
        
        // Collection achievements
        if isCaught {
            contributions[.collector] = 1.0
            contributions[.typeSpecialist] = 1.0
        }
        
        if isFavorite {
            contributions[.favorites] = 1.0
        }
        
        // Type-specific achievements
        for typeSlot in types {
            switch typeSlot.type {
            case .fire:
                contributions[.firemaster] = (contributions[.firemaster] ?? 0) + 1.0
            case .water:
                contributions[.watermaster] = (contributions[.watermaster] ?? 0) + 1.0
            case .electric:
                contributions[.electricmaster] = (contributions[.electricmaster] ?? 0) + 1.0
            case .grass:
                contributions[.grassmaster] = (contributions[.grassmaster] ?? 0) + 1.0
            case .dragon:
                contributions[.dragonmaster] = (contributions[.dragonmaster] ?? 0) + 1.0
            default:
                break
            }
        }
        
        // Stat-based achievements
        if statRating == .legendary {
            contributions[.powerhouse] = 1.0
        }
        
        return contributions
    }
    
    // MARK: - Convenience Properties for Collection View
    var sprite: String {
        // Use sprite URL if available, otherwise emoji
        return sprites.officialArtwork.isEmpty ? typeEmoji : sprites.officialArtwork
    }
    
    private var typeEmoji: String {
        switch primaryType {
        case .fire: return "🔥"
        case .water: return "💧"
        case .grass: return "🌿"
        case .electric: return "⚡"
        case .psychic: return "🔮"
        case .normal: return "⭐"
        case .dragon: return "🐉"
        case .flying: return "🌪️"
        case .fighting: return "👊"
        case .poison: return "☠️"
        case .ground: return "🌍"
        case .rock: return "🗿"
        case .bug: return "🐛"
        case .ghost: return "👻"
        case .steel: return "⚙️"
        case .fairy: return "🧚"
        case .dark: return "🌙"
        case .ice: return "❄️"
        default: return "⭐"
        }
    }
    
    var collectionStats: PokemonCollectionStats {
        let hp = stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 50
        let attack = stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 50
        let defense = stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 50
        let specialAttack = stats.first(where: { $0.stat.name == "special-attack" })?.baseStat ?? 50
        let specialDefense = stats.first(where: { $0.stat.name == "special-defense" })?.baseStat ?? 50
        let speed = stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 50
        
        return PokemonCollectionStats(
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: specialAttack,
            specialDefense: specialDefense,
            speed: speed
        )
    }
}

// MARK: - Collection Status Enum
enum CollectionStatus: String, CaseIterable {
    case undiscovered = "undiscovered"
    case seen = "seen"
    case favorite = "favorite"
    case caught = "caught"
    
    var displayName: String {
        switch self {
        case .undiscovered:
            return "Undiscovered"
        case .seen:
            return "Seen"
        case .favorite:
            return "Favorite"
        case .caught:
            return "Caught"
        }
    }
    
    var icon: String {
        switch self {
        case .undiscovered:
            return "questionmark.circle"
        case .seen:
            return "eye"
        case .favorite:
            return "heart.fill"
        case .caught:
            return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .undiscovered:
            return Color.gray
        case .seen:
            return ThemeManager.Colors.plasma
        case .favorite:
            return Color.pink
        case .caught:
            return ThemeManager.Colors.aurora
        }
    }
}

// MARK: - Stat Rating Enum
enum StatRating: String, CaseIterable {
    case poor = "poor"
    case below = "below"
    case average = "average"
    case good = "good"
    case excellent = "excellent"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .poor:
            return "Poor"
        case .below:
            return "Below Average"
        case .average:
            return "Average"
        case .good:
            return "Good"
        case .excellent:
            return "Excellent"
        case .legendary:
            return "Legendary"
        }
    }
    
    var color: Color {
        switch self {
        case .poor:
            return Color.red
        case .below:
            return Color.orange
        case .average:
            return Color.yellow
        case .good:
            return Color.blue
        case .excellent:
            return Color.purple
        case .legendary:
            return Color.gold
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Achievement Types
enum AchievementType: String, CaseIterable {
    case collector = "collector"
    case favorites = "favorites"
    case typeSpecialist = "type_specialist"
    case firemaster = "fire_master"
    case watermaster = "water_master"
    case electricmaster = "electric_master"
    case grassmaster = "grass_master"
    case dragonmaster = "dragon_master"
    case powerhouse = "powerhouse"
    
    var title: String {
        switch self {
        case .collector:
            return "Collector"
        case .favorites:
            return "Favorites Master"
        case .typeSpecialist:
            return "Type Specialist"
        case .firemaster:
            return "Fire Master"
        case .watermaster:
            return "Water Master"
        case .electricmaster:
            return "Electric Master"
        case .grassmaster:
            return "Grass Master"
        case .dragonmaster:
            return "Dragon Master"
        case .powerhouse:
            return "Powerhouse"
        }
    }
    
    var description: String {
        switch self {
        case .collector:
            return "Catch 50 Pokemon"
        case .favorites:
            return "Mark 25 Pokemon as favorites"
        case .typeSpecialist:
            return "Catch Pokemon of every type"
        case .firemaster:
            return "Catch 10 Fire-type Pokemon"
        case .watermaster:
            return "Catch 10 Water-type Pokemon"
        case .electricmaster:
            return "Catch 10 Electric-type Pokemon"
        case .grassmaster:
            return "Catch 10 Grass-type Pokemon"
        case .dragonmaster:
            return "Catch 5 Dragon-type Pokemon"
        case .powerhouse:
            return "Catch a Pokemon with 600+ total stats"
        }
    }
    
    var icon: String {
        switch self {
        case .collector:
            return "square.grid.3x3.fill"
        case .favorites:
            return "heart.fill"
        case .typeSpecialist:
            return "star.fill"
        case .firemaster:
            return "flame.fill"
        case .watermaster:
            return "drop.fill"
        case .electricmaster:
            return "bolt.fill"
        case .grassmaster:
            return "leaf.fill"
        case .dragonmaster:
            return "dragon.fill"
        case .powerhouse:
            return "crown.fill"
        }
    }
    
    var targetValue: Double {
        switch self {
        case .collector:
            return 50
        case .favorites:
            return 25
        case .typeSpecialist:
            return 18
        case .firemaster, .watermaster, .electricmaster, .grassmaster:
            return 10
        case .dragonmaster:
            return 5
        case .powerhouse:
            return 1
        }
    }
    
    var color: Color {
        switch self {
        case .collector:
            return ThemeManager.Colors.neural
        case .favorites:
            return Color.pink
        case .typeSpecialist:
            return Color.gold
        case .firemaster:
            return PokemonType.fire.color
        case .watermaster:
            return PokemonType.water.color
        case .electricmaster:
            return PokemonType.electric.color
        case .grassmaster:
            return PokemonType.grass.color
        case .dragonmaster:
            return PokemonType.dragon.color
        case .powerhouse:
            return Color.purple
        }
    }
}

// MARK: - Collection Sort Options
enum CollectionSortOption: String, CaseIterable {
    case number = "number"
    case name = "name"
    case type = "type"
    case stats = "stats"
    case favorites = "favorites"
    case caught = "caught"
    case progress = "progress"
    
    var displayName: String {
        switch self {
        case .number:
            return "Number"
        case .name:
            return "Name"
        case .type:
            return "Type"
        case .stats:
            return "Stats"
        case .favorites:
            return "Favorites"
        case .caught:
            return "Caught"
        case .progress:
            return "Progress"
        }
    }
    
    var icon: String {
        switch self {
        case .number:
            return "number"
        case .name:
            return "textformat.abc"
        case .type:
            return "tag.fill"
        case .stats:
            return "chart.bar.fill"
        case .favorites:
            return "heart.fill"
        case .caught:
            return "checkmark.circle.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Pokemon Collection Stats
struct PokemonCollectionStats {
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    var average: Double {
        Double(total) / 6.0
    }
}

