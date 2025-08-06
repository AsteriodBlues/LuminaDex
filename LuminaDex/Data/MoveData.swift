//
//  MoveData.swift
//  LuminaDex
//
//  Complete Move System Data Models
//

import Foundation
import SwiftUI

// MARK: - Move Model
struct Move: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let type: PokemonType
    let category: MoveCategory
    let power: Int?
    let accuracy: Int?
    let pp: Int
    let priority: Int
    let generation: Int
    let damageClass: DamageClass
    let effect: String?
    let effectChance: Int?
    let target: MoveTarget
    let critRate: Int
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var effectivePower: Double {
        Double(power ?? 0) * Double(accuracy ?? 100) / 100.0
    }
}

// MARK: - Move Category
enum MoveCategory: String, Codable, CaseIterable {
    case physical = "Physical"
    case special = "Special"
    case status = "Status"
    
    var color: Color {
        switch self {
        case .physical: return .orange
        case .special: return .blue
        case .status: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .physical: return "flame.fill"
        case .special: return "sparkles"
        case .status: return "shield.fill"
        }
    }
}

// MARK: - Damage Class
enum DamageClass: String, Codable, CaseIterable {
    case physical
    case special
    case status
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Move Target
enum MoveTarget: String, Codable, CaseIterable {
    case specificMove = "specific-move"
    case selectedPokemonMeFirst = "selected-pokemon-me-first"
    case ally = "ally"
    case usersField = "users-field"
    case userOrAlly = "user-or-ally"
    case opponentsField = "opponents-field"
    case user = "user"
    case randomOpponent = "random-opponent"
    case allOtherPokemon = "all-other-pokemon"
    case selectedPokemon = "selected-pokemon"
    case allOpponents = "all-opponents"
    case entireField = "entire-field"
    case userAndAllies = "user-and-allies"
    case allPokemon = "all-pokemon"
    case allAllies = "all-allies"
    case fainting = "fainting"
    
    var displayName: String {
        switch self {
        case .specificMove: return "Specific Move"
        case .selectedPokemonMeFirst: return "Selected (Me First)"
        case .ally: return "Ally"
        case .usersField: return "User's Field"
        case .userOrAlly: return "User or Ally"
        case .opponentsField: return "Opponent's Field"
        case .user: return "User"
        case .randomOpponent: return "Random Opponent"
        case .allOtherPokemon: return "All Other Pokémon"
        case .selectedPokemon: return "Selected Pokémon"
        case .allOpponents: return "All Opponents"
        case .entireField: return "Entire Field"
        case .userAndAllies: return "User and Allies"
        case .allPokemon: return "All Pokémon"
        case .allAllies: return "All Allies"
        case .fainting: return "Fainting"
        }
    }
}

// MARK: - Move Learn Method
struct MoveLearnMethod: Codable, Hashable {
    let method: LearnMethodType
    let levelLearnedAt: Int?
    let tmNumber: Int?
    let moveId: Int
    let pokemonId: Int
}

enum LearnMethodType: String, Codable, CaseIterable {
    case levelUp = "level-up"
    case machine = "machine"
    case egg = "egg"
    case tutor = "tutor"
    case stadium = "stadium-surfing-pikachu"
    case lightBall = "light-ball-egg"
    case form = "form-change"
    
    var displayName: String {
        switch self {
        case .levelUp: return "Level Up"
        case .machine: return "TM/HM"
        case .egg: return "Egg Move"
        case .tutor: return "Move Tutor"
        case .stadium: return "Stadium"
        case .lightBall: return "Light Ball"
        case .form: return "Form Change"
        }
    }
    
    var icon: String {
        switch self {
        case .levelUp: return "arrow.up.circle.fill"
        case .machine: return "disc.fill"
        case .egg: return "circle.hexagongrid.fill"
        case .tutor: return "person.fill"
        case .stadium: return "tv.fill"
        case .lightBall: return "bolt.fill"
        case .form: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .levelUp: return .blue
        case .machine: return .purple
        case .egg: return .green
        case .tutor: return .orange
        case .stadium: return .pink
        case .lightBall: return .yellow
        case .form: return .teal
        }
    }
}

// MARK: - Damage Calculation
struct DamageCalculation {
    let attacker: Pokemon
    let defender: Pokemon
    let move: Move
    let weather: Weather?
    let terrain: Terrain?
    let isStab: Bool
    let isCritical: Bool
    let typeEffectiveness: Double
    
    var minDamage: Int {
        calculateDamage(withRandomMultiplier: 0.85)
    }
    
    var maxDamage: Int {
        calculateDamage(withRandomMultiplier: 1.0)
    }
    
    var averageDamage: Int {
        (minDamage + maxDamage) / 2
    }
    
    private func calculateDamage(withRandomMultiplier random: Double) -> Int {
        guard let power = move.power, power > 0 else { return 0 }
        
        let level = 50.0 // Standard battle level
        let attack = move.category == .physical ? 
            Double(attacker.stats.first { $0.stat.name == "attack" }?.baseStat ?? 100) :
            Double(attacker.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 100)
        let defense = move.category == .physical ?
            Double(defender.stats.first { $0.stat.name == "defense" }?.baseStat ?? 100) :
            Double(defender.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 100)
        
        // Base damage formula
        var damage = ((2.0 * level + 10.0) / 250.0) * (attack / defense) * Double(power) + 2.0
        
        // Apply modifiers
        if isStab { damage *= 1.5 }
        damage *= typeEffectiveness
        if isCritical { damage *= 1.5 }
        damage *= random
        
        // Weather modifier
        if let weather = weather {
            damage *= weather.getDamageMultiplier(for: move.type)
        }
        
        return Int(damage)
    }
}

// MARK: - Weather
enum Weather: String, CaseIterable {
    case none = "None"
    case sun = "Harsh Sunlight"
    case rain = "Rain"
    case sandstorm = "Sandstorm"
    case hail = "Hail"
    case fog = "Fog"
    
    func getDamageMultiplier(for type: PokemonType) -> Double {
        switch self {
        case .sun:
            return type == .fire ? 1.5 : (type == .water ? 0.5 : 1.0)
        case .rain:
            return type == .water ? 1.5 : (type == .fire ? 0.5 : 1.0)
        default:
            return 1.0
        }
    }
}

// MARK: - Terrain
enum Terrain: String, CaseIterable {
    case none = "None"
    case electric = "Electric Terrain"
    case grassy = "Grassy Terrain"
    case misty = "Misty Terrain"
    case psychic = "Psychic Terrain"
    
    func getDamageMultiplier(for type: PokemonType) -> Double {
        switch self {
        case .electric:
            return type == .electric ? 1.3 : 1.0
        case .grassy:
            return type == .grass ? 1.3 : 1.0
        case .psychic:
            return type == .psychic ? 1.3 : 1.0
        default:
            return 1.0
        }
    }
}

// MARK: - Move Statistics
struct MoveStatistics {
    let totalMoves: Int
    let byType: [PokemonType: Int]
    let byCategory: [MoveCategory: Int]
    let byGeneration: [Int: Int]
    let averagePower: Double
    let averageAccuracy: Double
    let averagePP: Double
    
    static func calculate(from moves: [Move]) -> MoveStatistics {
        var byType: [PokemonType: Int] = [:]
        var byCategory: [MoveCategory: Int] = [:]
        var byGeneration: [Int: Int] = [:]
        
        var totalPower = 0
        var powerCount = 0
        var totalAccuracy = 0
        var accuracyCount = 0
        var totalPP = 0
        
        for move in moves {
            // Type distribution
            byType[move.type, default: 0] += 1
            
            // Category distribution
            byCategory[move.category, default: 0] += 1
            
            // Generation distribution
            byGeneration[move.generation, default: 0] += 1
            
            // Power stats
            if let power = move.power {
                totalPower += power
                powerCount += 1
            }
            
            // Accuracy stats
            if let accuracy = move.accuracy {
                totalAccuracy += accuracy
                accuracyCount += 1
            }
            
            // PP stats
            totalPP += move.pp
        }
        
        return MoveStatistics(
            totalMoves: moves.count,
            byType: byType,
            byCategory: byCategory,
            byGeneration: byGeneration,
            averagePower: powerCount > 0 ? Double(totalPower) / Double(powerCount) : 0,
            averageAccuracy: accuracyCount > 0 ? Double(totalAccuracy) / Double(accuracyCount) : 0,
            averagePP: moves.isEmpty ? 0 : Double(totalPP) / Double(moves.count)
        )
    }
}