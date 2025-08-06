//
//  NatureData.swift
//  LuminaDex
//
//  Complete nature system with stat modifiers
//

import Foundation
import SwiftUI

// MARK: - Nature Model
struct Nature: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let name: String
    let increasedStat: NatureStatType?
    let decreasedStat: NatureStatType?
    let likesFlavor: BerryFlavor?
    let hatesFlavor: BerryFlavor?
    
    var displayName: String {
        name.capitalized
    }
    
    var statModifierDescription: String {
        guard let increased = increasedStat, let decreased = decreasedStat else {
            return "No stat changes"
        }
        return "+\(increased.abbreviation) -\(decreased.abbreviation)"
    }
    
    var color: Color {
        guard let increased = increasedStat else { return .gray }
        return increased.color
    }
    
    func calculateStat(base: Int, stat: NatureStatType, level: Int = 100, ev: Int = 0, iv: Int = 31) -> Int {
        let nature = getNatureMultiplier(for: stat)
        
        if stat == .hp {
            // HP has different calculation
            return ((2 * base + iv + (ev / 4)) * level / 100) + level + 10
        } else {
            // Other stats
            let baseStat = ((2 * base + iv + (ev / 4)) * level / 100) + 5
            return Int(Double(baseStat) * nature)
        }
    }
    
    func getNatureMultiplier(for stat: NatureStatType) -> Double {
        if stat == increasedStat {
            return 1.1
        } else if stat == decreasedStat {
            return 0.9
        } else {
            return 1.0
        }
    }
}

// MARK: - Nature Stat Type
enum NatureStatType: String, CaseIterable, Codable {
    case hp = "hp"
    case attack = "attack"
    case defense = "defense"
    case specialAttack = "special-attack"
    case specialDefense = "special-defense"
    case speed = "speed"
    
    var displayName: String {
        switch self {
        case .hp: return "HP"
        case .attack: return "Attack"
        case .defense: return "Defense"
        case .specialAttack: return "Sp. Attack"
        case .specialDefense: return "Sp. Defense"
        case .speed: return "Speed"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .hp: return "HP"
        case .attack: return "Atk"
        case .defense: return "Def"
        case .specialAttack: return "SpA"
        case .specialDefense: return "SpD"
        case .speed: return "Spe"
        }
    }
    
    var color: Color {
        switch self {
        case .hp: return .red
        case .attack: return .orange
        case .defense: return .blue
        case .specialAttack: return .purple
        case .specialDefense: return .green
        case .speed: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .hp: return "heart.fill"
        case .attack: return "bolt.fill"
        case .defense: return "shield.fill"
        case .specialAttack: return "sparkles"
        case .specialDefense: return "leaf.fill"
        case .speed: return "hare.fill"
        }
    }
}

// MARK: - Berry Flavor
enum BerryFlavor: String, CaseIterable, Codable {
    case spicy, dry, sweet, bitter, sour
    
    var color: Color {
        switch self {
        case .spicy: return .red
        case .dry: return .blue
        case .sweet: return .pink
        case .bitter: return .green
        case .sour: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .spicy: return "flame.fill"
        case .dry: return "drop.degreesign.slash.fill"
        case .sweet: return "heart.fill"
        case .bitter: return "leaf.fill"
        case .sour: return "bolt.fill"
        }
    }
}

// MARK: - Nature Chart
struct NatureChart {
    static let allNatures: [Nature] = [
        Nature(id: 1, name: "hardy", increasedStat: nil, decreasedStat: nil, likesFlavor: nil, hatesFlavor: nil),
        Nature(id: 2, name: "lonely", increasedStat: NatureStatType.attack, decreasedStat: NatureStatType.defense, likesFlavor: BerryFlavor.spicy, hatesFlavor: BerryFlavor.sour),
        Nature(id: 3, name: "brave", increasedStat: NatureStatType.attack, decreasedStat: NatureStatType.speed, likesFlavor: BerryFlavor.spicy, hatesFlavor: BerryFlavor.sweet),
        Nature(id: 4, name: "adamant", increasedStat: NatureStatType.attack, decreasedStat: NatureStatType.specialAttack, likesFlavor: BerryFlavor.spicy, hatesFlavor: BerryFlavor.dry),
        Nature(id: 5, name: "naughty", increasedStat: NatureStatType.attack, decreasedStat: NatureStatType.specialDefense, likesFlavor: BerryFlavor.spicy, hatesFlavor: BerryFlavor.bitter),
        Nature(id: 6, name: "bold", increasedStat: NatureStatType.defense, decreasedStat: NatureStatType.attack, likesFlavor: BerryFlavor.sour, hatesFlavor: BerryFlavor.spicy),
        Nature(id: 7, name: "docile", increasedStat: nil, decreasedStat: nil, likesFlavor: nil, hatesFlavor: nil),
        Nature(id: 8, name: "relaxed", increasedStat: NatureStatType.defense, decreasedStat: NatureStatType.speed, likesFlavor: BerryFlavor.sour, hatesFlavor: BerryFlavor.sweet),
        Nature(id: 9, name: "impish", increasedStat: NatureStatType.defense, decreasedStat: NatureStatType.specialAttack, likesFlavor: BerryFlavor.sour, hatesFlavor: BerryFlavor.dry),
        Nature(id: 10, name: "lax", increasedStat: NatureStatType.defense, decreasedStat: NatureStatType.specialDefense, likesFlavor: BerryFlavor.sour, hatesFlavor: BerryFlavor.bitter),
        Nature(id: 11, name: "timid", increasedStat: NatureStatType.speed, decreasedStat: NatureStatType.attack, likesFlavor: BerryFlavor.sweet, hatesFlavor: BerryFlavor.spicy),
        Nature(id: 12, name: "hasty", increasedStat: NatureStatType.speed, decreasedStat: NatureStatType.defense, likesFlavor: BerryFlavor.sweet, hatesFlavor: BerryFlavor.sour),
        Nature(id: 13, name: "serious", increasedStat: nil, decreasedStat: nil, likesFlavor: nil, hatesFlavor: nil),
        Nature(id: 14, name: "jolly", increasedStat: NatureStatType.speed, decreasedStat: NatureStatType.specialAttack, likesFlavor: BerryFlavor.sweet, hatesFlavor: BerryFlavor.dry),
        Nature(id: 15, name: "naive", increasedStat: NatureStatType.speed, decreasedStat: NatureStatType.specialDefense, likesFlavor: BerryFlavor.sweet, hatesFlavor: BerryFlavor.bitter),
        Nature(id: 16, name: "modest", increasedStat: NatureStatType.specialAttack, decreasedStat: NatureStatType.attack, likesFlavor: BerryFlavor.dry, hatesFlavor: BerryFlavor.spicy),
        Nature(id: 17, name: "mild", increasedStat: NatureStatType.specialAttack, decreasedStat: NatureStatType.defense, likesFlavor: BerryFlavor.dry, hatesFlavor: BerryFlavor.sour),
        Nature(id: 18, name: "quiet", increasedStat: NatureStatType.specialAttack, decreasedStat: NatureStatType.speed, likesFlavor: BerryFlavor.dry, hatesFlavor: BerryFlavor.sweet),
        Nature(id: 19, name: "bashful", increasedStat: nil, decreasedStat: nil, likesFlavor: nil, hatesFlavor: nil),
        Nature(id: 20, name: "rash", increasedStat: NatureStatType.specialAttack, decreasedStat: NatureStatType.specialDefense, likesFlavor: BerryFlavor.dry, hatesFlavor: BerryFlavor.bitter),
        Nature(id: 21, name: "calm", increasedStat: NatureStatType.specialDefense, decreasedStat: NatureStatType.attack, likesFlavor: BerryFlavor.bitter, hatesFlavor: BerryFlavor.spicy),
        Nature(id: 22, name: "gentle", increasedStat: NatureStatType.specialDefense, decreasedStat: NatureStatType.defense, likesFlavor: BerryFlavor.bitter, hatesFlavor: BerryFlavor.sour),
        Nature(id: 23, name: "sassy", increasedStat: NatureStatType.specialDefense, decreasedStat: NatureStatType.speed, likesFlavor: BerryFlavor.bitter, hatesFlavor: BerryFlavor.sweet),
        Nature(id: 24, name: "careful", increasedStat: NatureStatType.specialDefense, decreasedStat: NatureStatType.specialAttack, likesFlavor: BerryFlavor.bitter, hatesFlavor: BerryFlavor.dry),
        Nature(id: 25, name: "quirky", increasedStat: nil, decreasedStat: nil, likesFlavor: nil, hatesFlavor: nil)
    ]
    
    static func getNature(by name: String) -> Nature? {
        allNatures.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getNature(by id: Int) -> Nature? {
        allNatures.first { $0.id == id }
    }
    
    static func getOptimalNatures(for pokemon: Pokemon) -> [Nature] {
        // Get the two highest stats (excluding HP)
        let attack = pokemon.stats.first { $0.stat.name == "attack" }?.baseStat ?? 0
        let defense = pokemon.stats.first { $0.stat.name == "defense" }?.baseStat ?? 0
        let specialAttack = pokemon.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0
        let specialDefense = pokemon.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0
        let speed = pokemon.stats.first { $0.stat.name == "speed" }?.baseStat ?? 0
        
        let stats: [(NatureStatType, Int)] = [
            (NatureStatType.attack, attack),
            (NatureStatType.defense, defense),
            (NatureStatType.specialAttack, specialAttack),
            (NatureStatType.specialDefense, specialDefense),
            (NatureStatType.speed, speed)
        ].sorted { $0.1 > $1.1 }
        
        let highestStat = stats[0].0
        let lowestStat = stats.last!.0
        
        // Find natures that boost highest stat and reduce lowest
        return allNatures.filter { nature in
            nature.increasedStat == highestStat && nature.decreasedStat == lowestStat
        }
    }
}