//
//  PokeballData.swift
//  LuminaDex
//
//  Comprehensive Pokeball Database with Real Data
//

import SwiftUI

// MARK: - Pokeball Model
struct Pokeball: Identifiable {
    let id: Int
    let name: String
    let displayName: String
    let catchRateMultiplier: Double
    let effect: String
    let description: String
    let cost: Int
    let sellPrice: Int
    let category: PokeballCategory
    let spriteURL: String
    let introduction: String // Which game it was introduced
    let colorName: String // Store color name instead of Color
    let isSpecial: Bool
    let conditions: [String]
    
    // Computed property for the actual color
    var color: Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "gray": return .gray
        case "black": return .black
        case "white": return .white
        case "cyan": return .cyan
        case "mint": return .mint
        default: return .gray
        }
    }
    
    enum PokeballCategory: String, Codable, CaseIterable {
        case standard = "Standard"
        case special = "Special Condition"
        case apricorn = "Apricorn"
        case dream = "Dream World"
        case beast = "Ultra Space"
        case master = "Master Class"
        case unique = "Unique"
        
        var icon: String {
            switch self {
            case .standard: return "circle"
            case .special: return "moon"
            case .apricorn: return "leaf"
            case .dream: return "cloud"
            case .beast: return "sparkles"
            case .master: return "crown"
            case .unique: return "star"
            }
        }
        
        var color: Color {
            switch self {
            case .standard: return .red
            case .special: return .blue
            case .apricorn: return .green
            case .dream: return .purple
            case .beast: return .yellow
            case .master: return .purple
            case .unique: return .orange
            }
        }
    }
    
    // Computed properties
    var effectivenessDescription: String {
        switch catchRateMultiplier {
        case 0..<1: return "Below Average"
        case 1: return "Standard"
        case 1..<2: return "Good"
        case 2..<3: return "Great"
        case 3..<4: return "Excellent"
        case 4...: return "Exceptional"
        default: return "Special"
        }
    }
    
    var priceCategory: String {
        switch cost {
        case 0: return "Not Purchasable"
        case 1..<500: return "Cheap"
        case 500..<1000: return "Affordable"
        case 1000..<5000: return "Expensive"
        case 5000...: return "Premium"
        default: return "Special"
        }
    }
}

// MARK: - Pokeball Database
class PokeballDatabase {
    static let shared = PokeballDatabase()
    
    let allPokeballs: [Pokeball] = [
        // MARK: Standard Balls
        Pokeball(
            id: 1,
            name: "poke-ball",
            displayName: "Poké Ball",
            catchRateMultiplier: 1.0,
            effect: "A standard Poké Ball with no special effects",
            description: "A device for catching wild Pokémon. It's thrown like a ball at a Pokémon, comfortably encapsulating its target.",
            cost: 200,
            sellPrice: 100,
            category: .standard,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png",
            introduction: "Generation I",
            colorName: "red",
            isSpecial: false,
            conditions: []
        ),
        
        Pokeball(
            id: 2,
            name: "great-ball",
            displayName: "Great Ball",
            catchRateMultiplier: 1.5,
            effect: "Provides 1.5× catch rate",
            description: "A good, high-performance Poké Ball that provides a higher success rate for catching Pokémon than a standard Poké Ball.",
            cost: 600,
            sellPrice: 300,
            category: .standard,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/great-ball.png",
            introduction: "Generation I",
            colorName: "blue",
            isSpecial: false,
            conditions: []
        ),
        
        Pokeball(
            id: 3,
            name: "ultra-ball",
            displayName: "Ultra Ball",
            catchRateMultiplier: 2.0,
            effect: "Provides 2× catch rate",
            description: "An ultra-high-performance Poké Ball that provides a higher success rate for catching Pokémon than a Great Ball.",
            cost: 1200,
            sellPrice: 600,
            category: .standard,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/ultra-ball.png",
            introduction: "Generation I",
            colorName: "yellow",
            isSpecial: false,
            conditions: []
        ),
        
        Pokeball(
            id: 4,
            name: "master-ball",
            displayName: "Master Ball",
            catchRateMultiplier: 255.0,
            effect: "Catches any Pokémon without fail",
            description: "The best Poké Ball with the ultimate level of performance. With it, you will catch any wild Pokémon without fail.",
            cost: 0,
            sellPrice: 0,
            category: .master,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/master-ball.png",
            introduction: "Generation I",
            colorName: "purple",
            isSpecial: true,
            conditions: ["100% catch rate", "Cannot be purchased", "Usually one per game"]
        ),
        
        // MARK: Special Condition Balls
        Pokeball(
            id: 5,
            name: "net-ball",
            displayName: "Net Ball",
            catchRateMultiplier: 3.5,
            effect: "3.5× catch rate on Water and Bug-type Pokémon",
            description: "A somewhat different Poké Ball that is more effective when attempting to catch Water- or Bug-type Pokémon.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/net-ball.png",
            introduction: "Generation III",
            colorName: "cyan",
            isSpecial: false,
            conditions: ["Best for Water types", "Best for Bug types"]
        ),
        
        Pokeball(
            id: 6,
            name: "dive-ball",
            displayName: "Dive Ball",
            catchRateMultiplier: 3.5,
            effect: "3.5× catch rate when fishing or surfing",
            description: "A somewhat different Poké Ball that works especially well when catching Pokémon that live underwater.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/dive-ball.png",
            introduction: "Generation III",
            colorName: "blue",
            isSpecial: false,
            conditions: ["Underwater encounters", "While surfing", "While fishing"]
        ),
        
        Pokeball(
            id: 7,
            name: "nest-ball",
            displayName: "Nest Ball",
            catchRateMultiplier: 4.0,
            effect: "Better catch rate on lower-level Pokémon",
            description: "A somewhat different Poké Ball that becomes more effective the lower the level of the wild Pokémon.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/nest-ball.png",
            introduction: "Generation III",
            colorName: "green",
            isSpecial: false,
            conditions: ["Level 1-19: 4× rate", "Level 20-29: 3× rate", "Level 30+: 1× rate"]
        ),
        
        Pokeball(
            id: 8,
            name: "repeat-ball",
            displayName: "Repeat Ball",
            catchRateMultiplier: 3.5,
            effect: "3.5× catch rate on previously caught species",
            description: "A somewhat different Poké Ball that works especially well on a Pokémon species that has been caught before.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/repeat-ball.png",
            introduction: "Generation III",
            colorName: "orange",
            isSpecial: false,
            conditions: ["Already in Pokédex"]
        ),
        
        Pokeball(
            id: 9,
            name: "timer-ball",
            displayName: "Timer Ball",
            catchRateMultiplier: 4.0,
            effect: "Increases catch rate every turn (max 4×)",
            description: "A somewhat different Poké Ball that becomes progressively more effective the more turns that are taken in battle.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/timer-ball.png",
            introduction: "Generation III",
            colorName: "gray",
            isSpecial: false,
            conditions: ["Turn 1-10: 1× rate", "Turn 11-20: 2× rate", "Turn 21-30: 3× rate", "Turn 30+: 4× rate"]
        ),
        
        Pokeball(
            id: 10,
            name: "luxury-ball",
            displayName: "Luxury Ball",
            catchRateMultiplier: 1.0,
            effect: "Caught Pokémon gains friendship faster",
            description: "A particularly comfortable Poké Ball that makes a wild Pokémon quickly grow friendlier after being caught.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/luxury-ball.png",
            introduction: "Generation III",
            colorName: "black",
            isSpecial: false,
            conditions: ["2× friendship gain rate"]
        ),
        
        Pokeball(
            id: 11,
            name: "premier-ball",
            displayName: "Premier Ball",
            catchRateMultiplier: 1.0,
            effect: "Same as Poké Ball but looks cooler",
            description: "A somewhat rare Poké Ball that was made as a commemorative item used to celebrate an event of some sort.",
            cost: 200,
            sellPrice: 100,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/premier-ball.png",
            introduction: "Generation III",
            colorName: "white",
            isSpecial: false,
            conditions: ["Bonus ball when buying 10+ Poké Balls"]
        ),
        
        // MARK: Apricorn Balls
        Pokeball(
            id: 12,
            name: "fast-ball",
            displayName: "Fast Ball",
            catchRateMultiplier: 4.0,
            effect: "4× catch rate on Pokémon with 100+ base Speed",
            description: "A Poké Ball that makes it easier to catch Pokémon that are quick to run away.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/fast-ball.png",
            introduction: "Generation II",
            colorName: "yellow",
            isSpecial: true,
            conditions: ["Speed stat ≥ 100"]
        ),
        
        Pokeball(
            id: 13,
            name: "level-ball",
            displayName: "Level Ball",
            catchRateMultiplier: 8.0,
            effect: "Better catch rate based on level difference",
            description: "A Poké Ball that makes it easier to catch Pokémon that are at a lower level than your own Pokémon.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/level-ball.png",
            introduction: "Generation II",
            colorName: "orange",
            isSpecial: true,
            conditions: ["Your level 4× higher: 8× rate", "Your level 2× higher: 4× rate", "Your level higher: 2× rate"]
        ),
        
        Pokeball(
            id: 14,
            name: "lure-ball",
            displayName: "Lure Ball",
            catchRateMultiplier: 5.0,
            effect: "5× catch rate when fishing",
            description: "A Poké Ball that is good for catching Pokémon that you reel in with a fishing rod.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/lure-ball.png",
            introduction: "Generation II",
            colorName: "blue",
            isSpecial: true,
            conditions: ["Fishing encounters only"]
        ),
        
        Pokeball(
            id: 15,
            name: "heavy-ball",
            displayName: "Heavy Ball",
            catchRateMultiplier: 1.0,
            effect: "Better for heavier Pokémon",
            description: "A Poké Ball for catching very heavy Pokémon.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/heavy-ball.png",
            introduction: "Generation II",
            colorName: "gray",
            isSpecial: true,
            conditions: ["<100kg: -20 rate", "100-200kg: +0", "200-300kg: +20", "300kg+: +30"]
        ),
        
        Pokeball(
            id: 16,
            name: "love-ball",
            displayName: "Love Ball",
            catchRateMultiplier: 8.0,
            effect: "8× rate if same species and opposite gender",
            description: "A Poké Ball for catching Pokémon that are the opposite gender of your Pokémon.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/love-ball.png",
            introduction: "Generation II",
            colorName: "pink",
            isSpecial: true,
            conditions: ["Same species", "Opposite gender"]
        ),
        
        Pokeball(
            id: 17,
            name: "friend-ball",
            displayName: "Friend Ball",
            catchRateMultiplier: 1.0,
            effect: "Sets caught Pokémon's friendship to 200",
            description: "A strange Poké Ball that will make the wild Pokémon caught with it more friendly toward you immediately.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/friend-ball.png",
            introduction: "Generation II",
            colorName: "green",
            isSpecial: true,
            conditions: ["High initial friendship"]
        ),
        
        Pokeball(
            id: 18,
            name: "moon-ball",
            displayName: "Moon Ball",
            catchRateMultiplier: 4.0,
            effect: "4× rate on Pokémon that evolve with Moon Stone",
            description: "A Poké Ball that will make it easier to catch Pokémon that can evolve using a Moon Stone.",
            cost: 1000,
            sellPrice: 500,
            category: .apricorn,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/moon-ball.png",
            introduction: "Generation II",
            colorName: "yellow",
            isSpecial: true,
            conditions: ["Moon Stone evolutions", "Nidoran♀", "Nidoran♂", "Clefairy", "Jigglypuff", "Skitty", "Munna"]
        ),
        
        Pokeball(
            id: 19,
            name: "sport-ball",
            displayName: "Sport Ball",
            catchRateMultiplier: 1.5,
            effect: "Used in Bug-Catching Contest",
            description: "A special Poké Ball that is used during the Bug-Catching Contest.",
            cost: 0,
            sellPrice: 0,
            category: .unique,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/sport-ball.png",
            introduction: "Generation II",
            colorName: "red",
            isSpecial: true,
            conditions: ["Bug-Catching Contest only"]
        ),
        
        // MARK: Modern Balls
        Pokeball(
            id: 20,
            name: "dusk-ball",
            displayName: "Dusk Ball",
            catchRateMultiplier: 3.0,
            effect: "3× rate at night or in caves",
            description: "A somewhat different Poké Ball that makes it easier to catch wild Pokémon at night or in dark places like caves.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/dusk-ball.png",
            introduction: "Generation IV",
            colorName: "green",
            isSpecial: false,
            conditions: ["Nighttime", "Caves", "Dark places"]
        ),
        
        Pokeball(
            id: 21,
            name: "heal-ball",
            displayName: "Heal Ball",
            catchRateMultiplier: 1.0,
            effect: "Fully heals caught Pokémon",
            description: "A remedial Poké Ball that restores the HP and status of a Pokémon caught with it.",
            cost: 300,
            sellPrice: 150,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/heal-ball.png",
            introduction: "Generation IV",
            colorName: "pink",
            isSpecial: false,
            conditions: ["Full HP restore", "Status condition cure"]
        ),
        
        Pokeball(
            id: 22,
            name: "quick-ball",
            displayName: "Quick Ball",
            catchRateMultiplier: 5.0,
            effect: "5× rate on first turn",
            description: "A somewhat different Poké Ball that has a more successful catch rate if used at the start of a wild encounter.",
            cost: 1000,
            sellPrice: 500,
            category: .special,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/quick-ball.png",
            introduction: "Generation IV",
            colorName: "blue",
            isSpecial: false,
            conditions: ["First turn only"]
        ),
        
        Pokeball(
            id: 23,
            name: "cherish-ball",
            displayName: "Cherish Ball",
            catchRateMultiplier: 1.0,
            effect: "Event Pokémon come in these",
            description: "A quite rare Poké Ball that has been crafted in order to commemorate a special occasion of some sort.",
            cost: 0,
            sellPrice: 0,
            category: .unique,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/cherish-ball.png",
            introduction: "Generation IV",
            colorName: "red",
            isSpecial: true,
            conditions: ["Event exclusive", "Cannot be obtained normally"]
        ),
        
        Pokeball(
            id: 24,
            name: "dream-ball",
            displayName: "Dream Ball",
            catchRateMultiplier: 4.0,
            effect: "4× rate on sleeping Pokémon",
            description: "A special Poké Ball that appears in your Bag in the Entree Forest. It can catch any Pokémon.",
            cost: 0,
            sellPrice: 0,
            category: .dream,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/dream-ball.png",
            introduction: "Generation V",
            colorName: "pink",
            isSpecial: true,
            conditions: ["Sleeping Pokémon", "Dream World"]
        ),
        
        Pokeball(
            id: 25,
            name: "beast-ball",
            displayName: "Beast Ball",
            catchRateMultiplier: 5.0,
            effect: "5× rate on Ultra Beasts, 0.1× on others",
            description: "A special Poké Ball designed to catch Ultra Beasts. It has a low success rate for catching others.",
            cost: 0,
            sellPrice: 0,
            category: .beast,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/beast-ball.png",
            introduction: "Generation VII",
            colorName: "blue",
            isSpecial: true,
            conditions: ["Ultra Beasts: 5× rate", "Regular Pokémon: 0.1× rate"]
        )
    ]
    
    // MARK: - Helper Methods
    func getPokeball(by name: String) -> Pokeball? {
        allPokeballs.first { $0.name == name || $0.displayName == name }
    }
    
    func getPokeballs(by category: Pokeball.PokeballCategory) -> [Pokeball] {
        allPokeballs.filter { $0.category == category }
    }
    
    func getSpecialPokeballs() -> [Pokeball] {
        allPokeballs.filter { $0.isSpecial }
    }
    
    func searchPokeballs(query: String) -> [Pokeball] {
        let lowercasedQuery = query.lowercased()
        return allPokeballs.filter {
            $0.displayName.lowercased().contains(lowercasedQuery) ||
            $0.effect.lowercased().contains(lowercasedQuery) ||
            $0.description.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getBestPokeballFor(scenario: CatchScenario) -> Pokeball {
        // Logic to recommend best Pokeball based on scenario
        switch scenario {
        case .water:
            return getPokeball(by: "net-ball") ?? allPokeballs[0]
        case .cave:
            return getPokeball(by: "dusk-ball") ?? allPokeballs[0]
        case .night:
            return getPokeball(by: "dusk-ball") ?? allPokeballs[0]
        case .firstTurn:
            return getPokeball(by: "quick-ball") ?? allPokeballs[0]
        case .legendary:
            return getPokeball(by: "master-ball") ?? allPokeballs[0]
        case .ultraBeast:
            return getPokeball(by: "beast-ball") ?? allPokeballs[0]
        case .heavy:
            return getPokeball(by: "heavy-ball") ?? allPokeballs[0]
        case .fast:
            return getPokeball(by: "fast-ball") ?? allPokeballs[0]
        case .sleeping:
            return getPokeball(by: "dream-ball") ?? allPokeballs[0]
        default:
            return allPokeballs[2] // Ultra Ball as default
        }
    }
    
    enum CatchScenario {
        case water, cave, night, firstTurn, legendary
        case ultraBeast, heavy, fast, sleeping, standard
    }
}

// MARK: - Pokeball Extensions
extension Pokeball {
    var successRate: String {
        let baseRate = 30.0 // Average catch rate
        let modifiedRate = min(100, baseRate * catchRateMultiplier)
        return String(format: "%.1f%%", modifiedRate)
    }
    
    var rarityLevel: String {
        if isSpecial {
            return "⭐️ Special"
        } else if cost > 1000 {
            return "💎 Premium"
        } else if cost > 500 {
            return "🥈 Uncommon"
        } else {
            return "🥉 Common"
        }
    }
}