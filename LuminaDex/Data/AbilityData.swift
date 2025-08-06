//
//  AbilityData.swift
//  LuminaDex
//
//  Complete ability system with effects
//

import Foundation
import SwiftUI

// MARK: - Ability Model
struct Ability: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let effect: String
    let shortEffect: String
    let generation: Int
    let isMainSeries: Bool
    
    var displayName: String {
        name.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var generationText: String {
        "Gen \(generation)"
    }
}

// MARK: - Pokemon Ability Data
struct PokemonAbilityData: Codable, Hashable {
    let ability: AbilityReference
    let isHidden: Bool
    let slot: Int
    
    struct AbilityReference: Codable, Hashable {
        let name: String
        let url: String
    }
}

// MARK: - Ability Category
enum AbilityCategory: String, CaseIterable {
    case damageBoost = "Damage Boost"
    case defensive = "Defensive"
    case speedControl = "Speed Control"
    case weather = "Weather"
    case terrain = "Terrain"
    case statusImmunity = "Status Immunity"
    case healing = "Healing"
    case utility = "Utility"
    
    var color: Color {
        switch self {
        case .damageBoost: return .red
        case .defensive: return .blue
        case .speedControl: return .yellow
        case .weather: return .cyan
        case .terrain: return .green
        case .statusImmunity: return .purple
        case .healing: return .pink
        case .utility: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .damageBoost: return "bolt.fill"
        case .defensive: return "shield.fill"
        case .speedControl: return "hare.fill"
        case .weather: return "cloud.fill"
        case .terrain: return "leaf.fill"
        case .statusImmunity: return "cross.circle.fill"
        case .healing: return "heart.fill"
        case .utility: return "wrench.fill"
        }
    }
    
    static func categorize(_ ability: Ability) -> AbilityCategory {
        let effect = ability.effect.lowercased()
        
        if effect.contains("damage") || effect.contains("power") || effect.contains("attack") {
            return .damageBoost
        } else if effect.contains("defense") || effect.contains("protect") || effect.contains("guard") {
            return .defensive
        } else if effect.contains("speed") || effect.contains("priority") {
            return .speedControl
        } else if effect.contains("weather") || effect.contains("rain") || effect.contains("sun") || effect.contains("sand") || effect.contains("hail") {
            return .weather
        } else if effect.contains("terrain") {
            return .terrain
        } else if effect.contains("immune") || effect.contains("cannot be") || effect.contains("prevents") {
            return .statusImmunity
        } else if effect.contains("heal") || effect.contains("restore") || effect.contains("recover") {
            return .healing
        }
        
        return .utility
    }
}

// MARK: - Competitive Ability Ranking
struct CompetitiveAbilityRanking {
    let ability: Ability
    let tier: Tier
    let usageRate: Double
    
    enum Tier: String, CaseIterable {
        case s = "S"
        case a = "A"
        case b = "B"  
        case c = "C"
        case d = "D"
        
        var color: Color {
            switch self {
            case .s: return .red
            case .a: return .orange
            case .b: return .yellow
            case .c: return .green
            case .d: return .gray
            }
        }
        
        var description: String {
            switch self {
            case .s: return "Meta Defining"
            case .a: return "Excellent"
            case .b: return "Good"
            case .c: return "Situational"
            case .d: return "Rarely Used"
            }
        }
    }
}