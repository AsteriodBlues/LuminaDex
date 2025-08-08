//
//  RibbonData.swift
//  LuminaDex
//
//  Comprehensive Ribbon collection system
//

import Foundation
import SwiftUI

// MARK: - Ribbon Model
struct Ribbon: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: RibbonCategory
    let description: String
    let requirements: String
    let rarity: RibbonRarity
    let generation: Int
    let imageUrl: String?
    let region: String?
    let contest: ContestType?
    let specialEvent: String?
    
    // Display properties
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var imageURL: URL? {
        // Return nil to use the custom rosette design instead
        // The external image URLs aren't loading reliably
        return nil
    }
    
    // SF Symbol representation for each ribbon
    var symbolName: String {
        switch category {
        case .contest:
            return "star.circle.fill"
        case .battle:
            return "bolt.shield.fill"
        case .special:
            return "sparkles.rectangle.stack.fill"
        case .commemorative:
            return "calendar.badge.clock"
        case .achievement:
            return "trophy.fill"
        case .effort:
            return "figure.run.circle.fill"
        case .memorial:
            return "heart.circle.fill"
        case .league:
            return "medal.fill"
        }
    }
}

// MARK: - Ribbon Category
enum RibbonCategory: String, CaseIterable, Codable {
    case contest = "Contest"
    case battle = "Battle"
    case special = "Special"
    case commemorative = "Commemorative"
    case achievement = "Achievement"
    case effort = "Effort"
    case memorial = "Memorial"
    case league = "League"
    
    var color: Color {
        switch self {
        case .contest: return .pink
        case .battle: return .red
        case .special: return .purple
        case .commemorative: return .yellow
        case .achievement: return .blue
        case .effort: return .green
        case .memorial: return .indigo
        case .league: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .contest: return "star.circle.fill"
        case .battle: return "bolt.shield.fill"
        case .special: return "sparkles"
        case .commemorative: return "calendar.badge.clock"
        case .achievement: return "trophy.fill"
        case .effort: return "figure.run"
        case .memorial: return "heart.circle.fill"
        case .league: return "medal.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .contest:
            return LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .battle:
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .special:
            return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .commemorative:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .achievement:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .effort:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .memorial:
            return LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .league:
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Ribbon Rarity
enum RibbonRarity: Int, CaseIterable, Codable {
    case common = 1
    case uncommon = 2
    case rare = 3
    case epic = 4
    case legendary = 5
    
    var title: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .epic: return "Epic"
        case .legendary: return "Legendary"
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var sparkleCount: Int {
        switch self {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }
}

// MARK: - Contest Type
enum ContestType: String, CaseIterable, Codable {
    case cool = "Cool"
    case beauty = "Beauty"
    case cute = "Cute"
    case smart = "Smart"
    case tough = "Tough"
    
    var color: Color {
        switch self {
        case .cool: return .blue
        case .beauty: return .pink
        case .cute: return .orange
        case .smart: return .green
        case .tough: return .yellow
        }
    }
}

// MARK: - Ribbon Collection
struct RibbonCollection {
    static let allRibbons: [Ribbon] = [
        // Contest Ribbons - Generation 3 (Hoenn)
        Ribbon(id: "1", name: "Cool Ribbon", category: .contest, description: "Awarded for winning the Cool Contest", requirements: "Win Normal Rank Cool Contest", rarity: .common, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cool, specialEvent: nil),
        Ribbon(id: "2", name: "Cool Ribbon Super", category: .contest, description: "Awarded for winning the Super Rank Cool Contest", requirements: "Win Super Rank Cool Contest", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cool, specialEvent: nil),
        Ribbon(id: "3", name: "Cool Ribbon Hyper", category: .contest, description: "Awarded for winning the Hyper Rank Cool Contest", requirements: "Win Hyper Rank Cool Contest", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cool, specialEvent: nil),
        Ribbon(id: "4", name: "Cool Ribbon Master", category: .contest, description: "Awarded for winning the Master Rank Cool Contest", requirements: "Win Master Rank Cool Contest", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cool, specialEvent: nil),
        
        Ribbon(id: "5", name: "Beauty Ribbon", category: .contest, description: "Awarded for winning the Beauty Contest", requirements: "Win Normal Rank Beauty Contest", rarity: .common, generation: 3, imageUrl: nil, region: "Hoenn", contest: .beauty, specialEvent: nil),
        Ribbon(id: "6", name: "Beauty Ribbon Super", category: .contest, description: "Awarded for winning the Super Rank Beauty Contest", requirements: "Win Super Rank Beauty Contest", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: .beauty, specialEvent: nil),
        Ribbon(id: "7", name: "Beauty Ribbon Hyper", category: .contest, description: "Awarded for winning the Hyper Rank Beauty Contest", requirements: "Win Hyper Rank Beauty Contest", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: .beauty, specialEvent: nil),
        Ribbon(id: "8", name: "Beauty Ribbon Master", category: .contest, description: "Awarded for winning the Master Rank Beauty Contest", requirements: "Win Master Rank Beauty Contest", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: .beauty, specialEvent: nil),
        
        Ribbon(id: "9", name: "Cute Ribbon", category: .contest, description: "Awarded for winning the Cute Contest", requirements: "Win Normal Rank Cute Contest", rarity: .common, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cute, specialEvent: nil),
        Ribbon(id: "10", name: "Cute Ribbon Super", category: .contest, description: "Awarded for winning the Super Rank Cute Contest", requirements: "Win Super Rank Cute Contest", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cute, specialEvent: nil),
        Ribbon(id: "11", name: "Cute Ribbon Hyper", category: .contest, description: "Awarded for winning the Hyper Rank Cute Contest", requirements: "Win Hyper Rank Cute Contest", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cute, specialEvent: nil),
        Ribbon(id: "12", name: "Cute Ribbon Master", category: .contest, description: "Awarded for winning the Master Rank Cute Contest", requirements: "Win Master Rank Cute Contest", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: .cute, specialEvent: nil),
        
        Ribbon(id: "13", name: "Smart Ribbon", category: .contest, description: "Awarded for winning the Smart Contest", requirements: "Win Normal Rank Smart Contest", rarity: .common, generation: 3, imageUrl: nil, region: "Hoenn", contest: .smart, specialEvent: nil),
        Ribbon(id: "14", name: "Smart Ribbon Super", category: .contest, description: "Awarded for winning the Super Rank Smart Contest", requirements: "Win Super Rank Smart Contest", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: .smart, specialEvent: nil),
        Ribbon(id: "15", name: "Smart Ribbon Hyper", category: .contest, description: "Awarded for winning the Hyper Rank Smart Contest", requirements: "Win Hyper Rank Smart Contest", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: .smart, specialEvent: nil),
        Ribbon(id: "16", name: "Smart Ribbon Master", category: .contest, description: "Awarded for winning the Master Rank Smart Contest", requirements: "Win Master Rank Smart Contest", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: .smart, specialEvent: nil),
        
        Ribbon(id: "17", name: "Tough Ribbon", category: .contest, description: "Awarded for winning the Tough Contest", requirements: "Win Normal Rank Tough Contest", rarity: .common, generation: 3, imageUrl: nil, region: "Hoenn", contest: .tough, specialEvent: nil),
        Ribbon(id: "18", name: "Tough Ribbon Super", category: .contest, description: "Awarded for winning the Super Rank Tough Contest", requirements: "Win Super Rank Tough Contest", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: .tough, specialEvent: nil),
        Ribbon(id: "19", name: "Tough Ribbon Hyper", category: .contest, description: "Awarded for winning the Hyper Rank Tough Contest", requirements: "Win Hyper Rank Tough Contest", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: .tough, specialEvent: nil),
        Ribbon(id: "20", name: "Tough Ribbon Master", category: .contest, description: "Awarded for winning the Master Rank Tough Contest", requirements: "Win Master Rank Tough Contest", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: .tough, specialEvent: nil),
        
        // Battle Ribbons
        Ribbon(id: "21", name: "Champion Ribbon", category: .battle, description: "Ribbon awarded for defeating the Champion", requirements: "Defeat the Champion and enter the Hall of Fame", rarity: .epic, generation: 3, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "22", name: "Winning Ribbon", category: .battle, description: "Ribbon awarded for winning at the Battle Tower", requirements: "Win Level 50 Battle Tower challenge", rarity: .rare, generation: 3, imageUrl: nil, region: "Hoenn", contest: nil, specialEvent: nil),
        Ribbon(id: "23", name: "Victory Ribbon", category: .battle, description: "Ribbon awarded for winning at the Battle Tower", requirements: "Win Level 100 Battle Tower challenge", rarity: .epic, generation: 3, imageUrl: nil, region: "Hoenn", contest: nil, specialEvent: nil),
        Ribbon(id: "24", name: "Ability Ribbon", category: .battle, description: "Ribbon awarded at the Battle Tower", requirements: "Complete Battle Tower Ability challenge", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "25", name: "Great Ability Ribbon", category: .battle, description: "Ribbon awarded for exceptional performance", requirements: "Complete advanced Battle Tower challenge", rarity: .epic, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "26", name: "Double Ability Ribbon", category: .battle, description: "Ribbon for Double Battle excellence", requirements: "Win Double Battle Tower challenge", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "27", name: "Multi Ability Ribbon", category: .battle, description: "Ribbon for Multi Battle excellence", requirements: "Win Multi Battle Tower challenge", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "28", name: "Pair Ability Ribbon", category: .battle, description: "Ribbon for Pair Battle excellence", requirements: "Win Pair Battle Tower challenge", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "29", name: "World Ability Ribbon", category: .battle, description: "Ribbon for world-class battling", requirements: "Win World Tournament", rarity: .legendary, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        
        // Special Ribbons
        Ribbon(id: "30", name: "Artist Ribbon", category: .special, description: "Ribbon awarded for being chosen as a sketch model", requirements: "Have Pokemon sketched by an artist", rarity: .uncommon, generation: 3, imageUrl: nil, region: "Hoenn", contest: nil, specialEvent: nil),
        Ribbon(id: "31", name: "Effort Ribbon", category: .effort, description: "Ribbon awarded for being a hard worker", requirements: "Max out all EVs (510 total)", rarity: .uncommon, generation: 3, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "32", name: "Alert Ribbon", category: .achievement, description: "Ribbon for Pokemon with excellent reactions", requirements: "Complete special reaction training", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "33", name: "Shock Ribbon", category: .achievement, description: "Ribbon for Pokemon that overcome paralysis", requirements: "Win battle while paralyzed", rarity: .uncommon, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "34", name: "Downcast Ribbon", category: .achievement, description: "Ribbon for Pokemon that overcome sadness", requirements: "Win battle with low happiness", rarity: .uncommon, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "35", name: "Careless Ribbon", category: .achievement, description: "Ribbon for carefree Pokemon", requirements: "Win battle with confusion", rarity: .uncommon, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "36", name: "Relax Ribbon", category: .achievement, description: "Ribbon for relaxed Pokemon", requirements: "Win battle while asleep", rarity: .uncommon, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "37", name: "Snooze Ribbon", category: .achievement, description: "Ribbon for sleepy Pokemon", requirements: "Use Rest move successfully", rarity: .common, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "38", name: "Smile Ribbon", category: .achievement, description: "Ribbon for happy Pokemon", requirements: "Max happiness", rarity: .common, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "39", name: "Gorgeous Ribbon", category: .special, description: "An extraordinarily gorgeous ribbon", requirements: "Special event participation", rarity: .epic, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "Pokemon Day"),
        Ribbon(id: "40", name: "Royal Ribbon", category: .special, description: "An incredibly regal ribbon", requirements: "Special royal event", rarity: .legendary, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "Royal Event"),
        
        // Commemorative Ribbons
        Ribbon(id: "41", name: "Gorgeous Royal Ribbon", category: .commemorative, description: "An absolutely gorgeous royal ribbon", requirements: "Special commemorative event", rarity: .legendary, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "Anniversary Event"),
        Ribbon(id: "42", name: "Footprint Ribbon", category: .commemorative, description: "Ribbon with a footprint-like mark", requirements: "Complete footprint collection", rarity: .rare, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "43", name: "Record Ribbon", category: .commemorative, description: "Ribbon commemorating a record", requirements: "Set a battle record", rarity: .rare, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "44", name: "Event Ribbon", category: .commemorative, description: "Ribbon obtained at a special event", requirements: "Participate in special event", rarity: .epic, generation: 3, imageUrl: nil, region: nil, contest: nil, specialEvent: "Pokemon Event"),
        Ribbon(id: "45", name: "Legend Ribbon", category: .commemorative, description: "Ribbon for legendary achievements", requirements: "Complete legendary quest", rarity: .legendary, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "46", name: "Birthday Ribbon", category: .commemorative, description: "Birthday celebration ribbon", requirements: "Receive on Pokemon's birthday", rarity: .epic, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: "Birthday"),
        Ribbon(id: "47", name: "Special Ribbon", category: .commemorative, description: "Special commemorative ribbon", requirements: "Special distribution event", rarity: .epic, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: "Distribution"),
        Ribbon(id: "48", name: "Souvenir Ribbon", category: .commemorative, description: "Souvenir from a special place", requirements: "Visit special location", rarity: .uncommon, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "49", name: "Wishing Ribbon", category: .commemorative, description: "Ribbon imbued with wishes", requirements: "Make a wish at special location", rarity: .rare, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "50", name: "Battle Champion Ribbon", category: .commemorative, description: "Championship battle ribbon", requirements: "Win regional championship", rarity: .legendary, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: "Championship"),
        
        // Memorial Ribbons
        Ribbon(id: "51", name: "Premier Ribbon", category: .memorial, description: "Ribbon commemorating a special premier", requirements: "Attend special premier event", rarity: .epic, generation: 5, imageUrl: nil, region: nil, contest: nil, specialEvent: "Premier"),
        Ribbon(id: "52", name: "Classic Ribbon", category: .memorial, description: "Classic commemorative ribbon", requirements: "Complete classic challenge", rarity: .rare, generation: 6, imageUrl: nil, region: "Kalos", contest: nil, specialEvent: nil),
        
        // Generation 6+ Ribbons
        Ribbon(id: "53", name: "Contest Star Ribbon", category: .contest, description: "Ribbon for Contest Star Pokemon", requirements: "Win all contest categories", rarity: .legendary, generation: 6, imageUrl: nil, region: "Hoenn", contest: nil, specialEvent: nil),
        Ribbon(id: "54", name: "Coolness Master Ribbon", category: .contest, description: "Master of Cool Contests", requirements: "Win Master Rank Cool Contest Spectacular", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: .cool, specialEvent: nil),
        Ribbon(id: "55", name: "Beauty Master Ribbon", category: .contest, description: "Master of Beauty Contests", requirements: "Win Master Rank Beauty Contest Spectacular", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: .beauty, specialEvent: nil),
        Ribbon(id: "56", name: "Cuteness Master Ribbon", category: .contest, description: "Master of Cute Contests", requirements: "Win Master Rank Cute Contest Spectacular", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: .cute, specialEvent: nil),
        Ribbon(id: "57", name: "Cleverness Master Ribbon", category: .contest, description: "Master of Clever Contests", requirements: "Win Master Rank Clever Contest Spectacular", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: .smart, specialEvent: nil),
        Ribbon(id: "58", name: "Toughness Master Ribbon", category: .contest, description: "Master of Tough Contests", requirements: "Win Master Rank Tough Contest Spectacular", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: .tough, specialEvent: nil),
        
        // League Ribbons
        Ribbon(id: "59", name: "Kalos Champion Ribbon", category: .league, description: "Champion of the Kalos region", requirements: "Defeat Kalos Elite Four and Champion", rarity: .epic, generation: 6, imageUrl: nil, region: "Kalos", contest: nil, specialEvent: nil),
        Ribbon(id: "60", name: "Hoenn Champion Ribbon", category: .league, description: "Champion of the Hoenn region", requirements: "Defeat Hoenn Elite Four and Champion", rarity: .epic, generation: 6, imageUrl: nil, region: "Hoenn", contest: nil, specialEvent: nil),
        Ribbon(id: "61", name: "Sinnoh Champion Ribbon", category: .league, description: "Champion of the Sinnoh region", requirements: "Defeat Sinnoh Elite Four and Champion", rarity: .epic, generation: 4, imageUrl: nil, region: "Sinnoh", contest: nil, specialEvent: nil),
        Ribbon(id: "62", name: "Unova Champion Ribbon", category: .league, description: "Champion of the Unova region", requirements: "Defeat Unova Elite Four and Champion", rarity: .epic, generation: 5, imageUrl: nil, region: "Unova", contest: nil, specialEvent: nil),
        Ribbon(id: "63", name: "Alola Champion Ribbon", category: .league, description: "Champion of the Alola region", requirements: "Defeat Alola Elite Four and become Champion", rarity: .epic, generation: 7, imageUrl: nil, region: "Alola", contest: nil, specialEvent: nil),
        Ribbon(id: "64", name: "Galar Champion Ribbon", category: .league, description: "Champion of the Galar region", requirements: "Win the Champion Cup in Galar", rarity: .epic, generation: 8, imageUrl: nil, region: "Galar", contest: nil, specialEvent: nil),
        Ribbon(id: "65", name: "Best Friends Ribbon", category: .effort, description: "Ribbon showing best friendship", requirements: "Max friendship with trainer", rarity: .uncommon, generation: 6, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "66", name: "Training Ribbon", category: .effort, description: "Ribbon for well-trained Pokemon", requirements: "Complete Super Training regimen", rarity: .common, generation: 6, imageUrl: nil, region: "Kalos", contest: nil, specialEvent: nil),
        Ribbon(id: "67", name: "Skillful Battler Ribbon", category: .battle, description: "Ribbon for skillful battlers", requirements: "Win 20 consecutive battles", rarity: .rare, generation: 7, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "68", name: "Expert Battler Ribbon", category: .battle, description: "Ribbon for expert battlers", requirements: "Win 50 consecutive battles", rarity: .epic, generation: 7, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "69", name: "Tree Master Ribbon", category: .battle, description: "Master of the Battle Tree", requirements: "Reach Battle Tree rank 50", rarity: .epic, generation: 7, imageUrl: nil, region: "Alola", contest: nil, specialEvent: nil),
        Ribbon(id: "70", name: "Tower Master Ribbon", category: .battle, description: "Master of the Battle Tower", requirements: "Reach Master Ball Tier in Battle Tower", rarity: .legendary, generation: 8, imageUrl: nil, region: "Galar", contest: nil, specialEvent: nil),
        
        // Paldea Ribbons (Gen 9)
        Ribbon(id: "71", name: "Paldea Champion Ribbon", category: .league, description: "Champion of the Paldea region", requirements: "Complete Victory Road and become Champion", rarity: .epic, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "72", name: "Once-in-a-Lifetime Ribbon", category: .special, description: "A once-in-a-lifetime commemorative ribbon", requirements: "Participate in special one-time event", rarity: .legendary, generation: 9, imageUrl: nil, region: nil, contest: nil, specialEvent: "Once-in-a-Lifetime"),
        Ribbon(id: "73", name: "Partner Ribbon", category: .special, description: "Ribbon showing partnership", requirements: "Complete partner challenge", rarity: .rare, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "74", name: "Gourmand Ribbon", category: .achievement, description: "Ribbon for food-loving Pokemon", requirements: "Eat sandwich with Pokemon", rarity: .common, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "75", name: "Itemfinder Ribbon", category: .achievement, description: "Ribbon for Pokemon that find items", requirements: "Find 100 items in the wild", rarity: .uncommon, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "76", name: "Master Rank Ribbon", category: .battle, description: "Ribbon for reaching Master Rank", requirements: "Reach Master Rank in Ranked Battles", rarity: .legendary, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "77", name: "Jumbo Mark Ribbon", category: .special, description: "Ribbon for jumbo-sized Pokemon", requirements: "Have an XXL sized Pokemon", rarity: .rare, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "78", name: "Mini Mark Ribbon", category: .special, description: "Ribbon for mini-sized Pokemon", requirements: "Have an XXS sized Pokemon", rarity: .rare, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "79", name: "Titan Mark Ribbon", category: .achievement, description: "Ribbon for defeating Titan Pokemon", requirements: "Defeat all Titan Pokemon", rarity: .epic, generation: 9, imageUrl: nil, region: "Paldea", contest: nil, specialEvent: nil),
        Ribbon(id: "80", name: "Hisui Ribbon", category: .commemorative, description: "Ribbon from the Hisui region", requirements: "Transfer from Pokemon Legends: Arceus", rarity: .epic, generation: 9, imageUrl: nil, region: "Hisui", contest: nil, specialEvent: nil),
        
        // Additional Missing Ribbons
        Ribbon(id: "81", name: "Country Ribbon", category: .commemorative, description: "Ribbon from a Pokémon Journey", requirements: "Obtain from Pokémon distribution", rarity: .rare, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "Country Event"),
        Ribbon(id: "82", name: "National Ribbon", category: .commemorative, description: "National commemorative ribbon", requirements: "National event participation", rarity: .rare, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "National Event"),
        Ribbon(id: "83", name: "Earth Ribbon", category: .commemorative, description: "Earth commemorative ribbon", requirements: "Earth Day event", rarity: .epic, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "Earth Day"),
        Ribbon(id: "84", name: "World Ribbon", category: .commemorative, description: "World commemorative ribbon", requirements: "World Championship participation", rarity: .legendary, generation: 4, imageUrl: nil, region: nil, contest: nil, specialEvent: "World Championship"),
        
        // Mark Ribbons (Gen 8+)
        Ribbon(id: "85", name: "Rare Mark", category: .special, description: "A rare mark", requirements: "Found on wild Pokémon (1/1000 chance)", rarity: .rare, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "86", name: "Uncommon Mark", category: .special, description: "An uncommon mark", requirements: "Found on wild Pokémon (1/50 chance)", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "87", name: "Rowdy Mark", category: .special, description: "Mark of a rowdy Pokémon", requirements: "Found on wild Pokémon with high attack", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "88", name: "Absent-Minded Mark", category: .special, description: "Mark of an absent-minded Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "89", name: "Jittery Mark", category: .special, description: "Mark of a jittery Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "90", name: "Excited Mark", category: .special, description: "Mark of an excited Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "91", name: "Charismatic Mark", category: .special, description: "Mark of a charismatic Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "92", name: "Calmness Mark", category: .special, description: "Mark of a calm Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "93", name: "Intense Mark", category: .special, description: "Mark of an intense Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "94", name: "Zoned-Out Mark", category: .special, description: "Mark of a zoned-out Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "95", name: "Joyful Mark", category: .special, description: "Mark of a joyful Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "96", name: "Angry Mark", category: .special, description: "Mark of an angry Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "97", name: "Smiley Mark", category: .special, description: "Mark of a smiley Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "98", name: "Teary Mark", category: .special, description: "Mark of a teary Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "99", name: "Upbeat Mark", category: .special, description: "Mark of an upbeat Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "100", name: "Peeved Mark", category: .special, description: "Mark of a peeved Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "101", name: "Intellectual Mark", category: .special, description: "Mark of an intellectual Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "102", name: "Ferocious Mark", category: .special, description: "Mark of a ferocious Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "103", name: "Crafty Mark", category: .special, description: "Mark of a crafty Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "104", name: "Scowling Mark", category: .special, description: "Mark of a scowling Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "105", name: "Kindly Mark", category: .special, description: "Mark of a kindly Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "106", name: "Flustered Mark", category: .special, description: "Mark of a flustered Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "107", name: "Pumped-Up Mark", category: .special, description: "Mark of a pumped-up Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "108", name: "Zero Energy Mark", category: .special, description: "Mark of a zero energy Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "109", name: "Prideful Mark", category: .special, description: "Mark of a prideful Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "110", name: "Unsure Mark", category: .special, description: "Mark of an unsure Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "111", name: "Humble Mark", category: .special, description: "Mark of a humble Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "112", name: "Thorny Mark", category: .special, description: "Mark of a thorny Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "113", name: "Vigor Mark", category: .special, description: "Mark of a vigorous Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "114", name: "Slump Mark", category: .special, description: "Mark of a slumped Pokémon", requirements: "Found on wild Pokémon", rarity: .uncommon, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil),
        Ribbon(id: "115", name: "Destiny Mark", category: .special, description: "Mark of destiny", requirements: "Encounter shiny Pokémon with mark", rarity: .legendary, generation: 8, imageUrl: nil, region: nil, contest: nil, specialEvent: nil)
    ]
    
    // Helper methods
    static func ribbons(for category: RibbonCategory) -> [Ribbon] {
        allRibbons.filter { $0.category == category }
    }
    
    static func ribbons(for rarity: RibbonRarity) -> [Ribbon] {
        allRibbons.filter { $0.rarity == rarity }
    }
    
    static func ribbons(for generation: Int) -> [Ribbon] {
        allRibbons.filter { $0.generation == generation }
    }
    
    static func contestRibbons() -> [Ribbon] {
        allRibbons.filter { $0.contest != nil }
    }
    
    static func eventRibbons() -> [Ribbon] {
        allRibbons.filter { $0.specialEvent != nil }
    }
}