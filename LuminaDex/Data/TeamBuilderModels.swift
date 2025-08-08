//
//  TeamBuilderModels.swift
//  LuminaDex
//
//  Team Builder data models and structures
//

import Foundation
import SwiftUI

// MARK: - Extended Pokemon Record for Team Builder
struct ExtendedPokemonRecord: Identifiable, Codable {
    let id: Int
    let name: String
    let types: [String]
    let stats: [String: Int]
    let spriteUrl: String?
    
    var totalStats: Int {
        stats.values.reduce(0, +)
    }
}

// MARK: - Team Models
struct PokemonTeam: Identifiable, Codable {
    let id = UUID()
    var name: String
    var members: [TeamMember]
    var createdDate: Date
    var lastModified: Date
    var format: BattleFormat
    var tags: [String]
    var notes: String
    var isTemplate: Bool
    
    init(name: String = "New Team", format: BattleFormat = .singles6v6) {
        self.name = name
        self.members = []
        self.createdDate = Date()
        self.lastModified = Date()
        self.format = format
        self.tags = []
        self.notes = ""
        self.isTemplate = false
    }
    
    var typeEffectiveness: TypeCoverage {
        TypeCoverage(team: self)
    }
    
    var speedTiers: [SpeedTier] {
        members.compactMap { member in
            guard let pokemon = member.pokemon else { return nil }
            return SpeedTier(
                pokemon: pokemon,
                speed: member.evs["speed"] ?? 0,
                nature: member.nature,
                item: member.item
            )
        }.sorted { $0.effectiveSpeed > $1.effectiveSpeed }
    }
}

struct TeamMember: Identifiable, Codable {
    let id: UUID
    var pokemonId: Int?
    var pokemon: Pokemon?
    var nickname: String?
    var level: Int
    var nature: TeamNature
    var ability: String?
    var item: String?
    var moves: [String]
    var evs: [String: Int]
    var ivs: [String: Int]
    var teraType: PokemonType?
    
    init() {
        self.id = UUID()
        self.level = 50
        self.nature = .hardy
        self.moves = []
        self.evs = ["hp": 0, "attack": 0, "defense": 0, "spAtk": 0, "spDef": 0, "speed": 0]
        self.ivs = ["hp": 31, "attack": 31, "defense": 31, "spAtk": 31, "spDef": 31, "speed": 31]
        self.pokemonId = nil
        self.pokemon = nil
        self.nickname = nil
        self.ability = nil
        self.item = nil
        self.teraType = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, pokemonId, nickname, level, nature, ability, item, moves, evs, ivs, teraType
    }
    
    var role: TeamRole {
        guard let pokemon = pokemon else { return .support }
        
        // Get base stats from the Pokemon's stat array
        let hpStat = pokemon.stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 0
        let attackStat = pokemon.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0
        let defenseStat = pokemon.stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 0
        let spAtkStat = pokemon.stats.first(where: { $0.stat.name == "special-attack" })?.baseStat ?? 0
        let spDefStat = pokemon.stats.first(where: { $0.stat.name == "special-defense" })?.baseStat ?? 0
        let speedStat = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
        
        let attack = attackStat + (evs["attack"] ?? 0) / 4
        let spAtk = spAtkStat + (evs["spAtk"] ?? 0) / 4
        let defense = defenseStat + (evs["defense"] ?? 0) / 4
        let spDef = spDefStat + (evs["spDef"] ?? 0) / 4
        let speed = speedStat + (evs["speed"] ?? 0) / 4
        
        if attack > spAtk && speed > 100 {
            return .physicalSweeper
        } else if spAtk > attack && speed > 100 {
            return .specialSweeper
        } else if defense > 100 && spDef > 100 {
            return .wall
        } else if defense > 100 || spDef > 100 {
            return .tank
        } else if ability?.lowercased().contains("pivot") ?? false {
            return .pivot
        } else {
            return .support
        }
    }
}

// MARK: - Team Analysis Models
struct TypeCoverage {
    let team: PokemonTeam
    
    var offensiveCoverage: [PokemonType: CoverageLevel] {
        var coverage: [PokemonType: CoverageLevel] = [:]
        
        for type in PokemonType.allCases {
            var effectiveness: Float = 0
            
            for member in team.members {
                guard let pokemon = member.pokemon else { continue }
                
                // Check STAB moves
                for typeSlot in pokemon.types {
                    // Simplified effectiveness calculation
                    effectiveness += getTypeEffectiveness(from: typeSlot.pokemonType, to: type)
                }
                
                // Check coverage moves
                for move in member.moves {
                    // This would check move types from move data
                    effectiveness += 1.0
                }
            }
            
            if effectiveness >= 4 {
                coverage[type] = .excellent
            } else if effectiveness >= 2 {
                coverage[type] = .good
            } else if effectiveness >= 1 {
                coverage[type] = .neutral
            } else {
                coverage[type] = .poor
            }
        }
        
        return coverage
    }
    
    var defensiveCoverage: [PokemonType: CoverageLevel] {
        var coverage: [PokemonType: CoverageLevel] = [:]
        
        for type in PokemonType.allCases {
            var resistCount = 0
            var weakCount = 0
            
            for member in team.members {
                guard let pokemon = member.pokemon else { continue }
                
                let effectiveness = getDefensiveEffectiveness(attackingType: type, defendingTypes: pokemon.types)
                if effectiveness < 1.0 {
                    resistCount += 1
                } else if effectiveness > 1.0 {
                    weakCount += 1
                }
            }
            
            if resistCount >= 3 {
                coverage[type] = .excellent
            } else if resistCount >= 2 && weakCount == 0 {
                coverage[type] = .good
            } else if weakCount >= 3 {
                coverage[type] = .poor
            } else {
                coverage[type] = .neutral
            }
        }
        
        return coverage
    }
    
    var synergyScore: Float {
        var score: Float = 0
        
        // Type synergy
        let uniqueTypes = Set(team.members.compactMap { $0.pokemon?.types }.flatMap { $0 })
        score += Float(uniqueTypes.count) * 10
        
        // Role distribution
        let roles = team.members.map { $0.role }
        let uniqueRoles = Set(roles)
        score += Float(uniqueRoles.count) * 15
        
        // Speed tiers
        let speedTiers = team.speedTiers
        if speedTiers.count >= 2 {
            let speedVariance = speedTiers.map { Float($0.effectiveSpeed) }.reduce(0, +) / Float(speedTiers.count)
            score += speedVariance / 10
        }
        
        // Coverage completeness
        let goodCoverage = offensiveCoverage.values.filter { $0 == .good || $0 == .excellent }.count
        score += Float(goodCoverage) * 5
        
        return min(score, 100)
    }
}

struct SpeedTier: Identifiable {
    let id = UUID()
    let pokemon: Pokemon
    let speed: Int
    let nature: TeamNature
    let item: String?
    
    var effectiveSpeed: Int {
        let speedStat = pokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
        var base = speedStat + speed / 4
        
        // Nature modifier
        if nature.boostedStat == "Speed" {
            base = Int(Float(base) * 1.1)
        } else if nature.loweredStat == "Speed" {
            base = Int(Float(base) * 0.9)
        }
        
        // Item modifiers
        if item == "Choice Scarf" {
            base = Int(Float(base) * 1.5)
        }
        
        return base
    }
}

// MARK: - Type Effectiveness Helpers
private func getTypeEffectiveness(from: PokemonType, to: PokemonType) -> Float {
    // Simplified type effectiveness chart
    // This would ideally use a complete type chart
    return 1.0
}

private func getDefensiveEffectiveness(attackingType: PokemonType, defendingTypes: [PokemonTypeSlot]) -> Float {
    var totalEffectiveness: Float = 1.0
    for typeSlot in defendingTypes {
        // Simplified calculation
        totalEffectiveness *= 1.0
    }
    return totalEffectiveness
}

// MARK: - Enums
enum BattleFormat: String, CaseIterable, Codable {
    case singles6v6 = "Singles 6v6"
    case singles3v3 = "Singles 3v3"
    case doubles4v4 = "Doubles 4v4"
    case doubles6v6 = "Doubles 6v6"
    case vgc = "VGC"
    case littleCup = "Little Cup"
    case monotype = "Monotype"
}

enum TeamRole: String, CaseIterable {
    case physicalSweeper = "Physical Sweeper"
    case specialSweeper = "Special Sweeper"
    case wall = "Wall"
    case tank = "Tank"
    case pivot = "Pivot"
    case support = "Support"
    case lead = "Lead"
    case revenge = "Revenge Killer"
    
    var icon: String {
        switch self {
        case .physicalSweeper: return "bolt.fill"
        case .specialSweeper: return "sparkles"
        case .wall: return "shield.fill"
        case .tank: return "cube.fill"
        case .pivot: return "arrow.triangle.2.circlepath"
        case .support: return "heart.fill"
        case .lead: return "flag.fill"
        case .revenge: return "hare.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .physicalSweeper: return .red
        case .specialSweeper: return .purple
        case .wall: return .gray
        case .tank: return .brown
        case .pivot: return .green
        case .support: return .pink
        case .lead: return .yellow
        case .revenge: return .orange
        }
    }
}

enum CoverageLevel: String {
    case excellent = "Excellent"
    case good = "Good"
    case neutral = "Neutral"
    case poor = "Poor"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .neutral: return .gray
        case .poor: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "checkmark.shield.fill"
        case .good: return "checkmark.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .poor: return "xmark.shield.fill"
        }
    }
}

enum TeamNature: String, CaseIterable, Codable {
    case hardy = "Hardy"
    case lonely = "Lonely"
    case brave = "Brave"
    case adamant = "Adamant"
    case naughty = "Naughty"
    case bold = "Bold"
    case docile = "Docile"
    case relaxed = "Relaxed"
    case impish = "Impish"
    case lax = "Lax"
    case timid = "Timid"
    case hasty = "Hasty"
    case serious = "Serious"
    case jolly = "Jolly"
    case naive = "Naive"
    case modest = "Modest"
    case mild = "Mild"
    case quiet = "Quiet"
    case bashful = "Bashful"
    case rash = "Rash"
    case calm = "Calm"
    case gentle = "Gentle"
    case sassy = "Sassy"
    case careful = "Careful"
    case quirky = "Quirky"
    
    var boostedStat: String? {
        switch self {
        case .lonely, .brave, .adamant, .naughty: return "Attack"
        case .bold, .relaxed, .impish, .lax: return "Defense"
        case .timid, .hasty, .jolly, .naive: return "Speed"
        case .modest, .mild, .quiet, .rash: return "Sp. Attack"
        case .calm, .gentle, .sassy, .careful: return "Sp. Defense"
        default: return nil
        }
    }
    
    var loweredStat: String? {
        switch self {
        case .lonely, .hasty, .mild, .gentle: return "Defense"
        case .brave, .relaxed, .quiet, .sassy: return "Speed"
        case .adamant, .impish, .jolly, .careful: return "Sp. Attack"
        case .naughty, .lax, .naive, .rash: return "Sp. Defense"
        case .bold, .timid, .modest, .calm: return "Attack"
        default: return nil
        }
    }
}

// MARK: - Team Templates
struct TeamTemplate {
    static let templates: [PokemonTeam] = [
        createBalancedTeam(),
        createHyperOffenseTeam(),
        createStallTeam(),
        createWeatherTeam(),
        createTrickRoomTeam()
    ]
    
    static func createBalancedTeam() -> PokemonTeam {
        var team = PokemonTeam(name: "Balanced Core", format: .singles6v6)
        team.isTemplate = true
        team.tags = ["Balanced", "Beginner-Friendly"]
        return team
    }
    
    static func createHyperOffenseTeam() -> PokemonTeam {
        var team = PokemonTeam(name: "Hyper Offense", format: .singles6v6)
        team.isTemplate = true
        team.tags = ["Offensive", "Fast-Paced"]
        return team
    }
    
    static func createStallTeam() -> PokemonTeam {
        var team = PokemonTeam(name: "Defensive Stall", format: .singles6v6)
        team.isTemplate = true
        team.tags = ["Defensive", "Slow-Paced"]
        return team
    }
    
    static func createWeatherTeam() -> PokemonTeam {
        var team = PokemonTeam(name: "Sun Team", format: .doubles4v4)
        team.isTemplate = true
        team.tags = ["Weather", "Synergy"]
        return team
    }
    
    static func createTrickRoomTeam() -> PokemonTeam {
        var team = PokemonTeam(name: "Trick Room", format: .doubles4v4)
        team.isTemplate = true
        team.tags = ["Trick Room", "Slow"]
        return team
    }
}