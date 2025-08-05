//
//  PokemonType.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//
import Foundation
import SwiftUI

// MARK: - Pokemon Type
enum PokemonType: String, CaseIterable, Codable, Hashable {
    case normal = "normal"
    case fire = "fire"
    case water = "water"
    case electric = "electric"
    case grass = "grass"
    case ice = "ice"
    case fighting = "fighting"
    case poison = "poison"
    case ground = "ground"
    case flying = "flying"
    case psychic = "psychic"
    case bug = "bug"
    case rock = "rock"
    case ghost = "ghost"
    case dragon = "dragon"
    case dark = "dark"
    case steel = "steel"
    case fairy = "fairy"
    case unknown = "unknown"
    
    // Display name
    var displayName: String {
        rawValue.capitalized
    }
    
    // Type colors for luxury UI
    var color: Color {
        switch self {
        case .normal:
            return Color(hex: "A8A878")
        case .fire:
            return Color(hex: "F08030")
        case .water:
            return Color(hex: "6890F0")
        case .electric:
            return Color(hex: "F8D030")
        case .grass:
            return Color(hex: "78C850")
        case .ice:
            return Color(hex: "98D8D8")
        case .fighting:
            return Color(hex: "C03028")
        case .poison:
            return Color(hex: "A040A0")
        case .ground:
            return Color(hex: "E0C068")
        case .flying:
            return Color(hex: "A890F0")
        case .psychic:
            return Color(hex: "F85888")
        case .bug:
            return Color(hex: "A8B820")
        case .rock:
            return Color(hex: "B8A038")
        case .ghost:
            return Color(hex: "705898")
        case .dragon:
            return Color(hex: "7038F8")
        case .dark:
            return Color(hex: "705848")
        case .steel:
            return Color(hex: "B8B8D0")
        case .fairy:
            return Color(hex: "EE99AC")
        case .unknown:
            return Color(hex: "68A090")
        }
    }
    
    // Gradient colors for premium effects
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Dark mode color variant
    var darkColor: Color {
        color.opacity(0.8)
    }
    
    // Type effectiveness (for battle calculations)
    var weakTo: [PokemonType] {
        switch self {
        case .normal:
            return [.fighting]
        case .fire:
            return [.water, .ground, .rock]
        case .water:
            return [.electric, .grass]
        case .electric:
            return [.ground]
        case .grass:
            return [.fire, .ice, .poison, .flying, .bug]
        case .ice:
            return [.fire, .fighting, .rock, .steel]
        case .fighting:
            return [.flying, .psychic, .fairy]
        case .poison:
            return [.ground, .psychic]
        case .ground:
            return [.water, .grass, .ice]
        case .flying:
            return [.electric, .ice, .rock]
        case .psychic:
            return [.bug, .ghost, .dark]
        case .bug:
            return [.fire, .flying, .rock]
        case .rock:
            return [.water, .grass, .fighting, .ground, .steel]
        case .ghost:
            return [.ghost, .dark]
        case .dragon:
            return [.ice, .dragon, .fairy]
        case .dark:
            return [.fighting, .bug, .fairy]
        case .steel:
            return [.fire, .fighting, .ground]
        case .fairy:
            return [.poison, .steel]
        case .unknown:
            return []
        }
    }
    
    var strongAgainst: [PokemonType] {
        switch self {
        case .normal:
            return []
        case .fire:
            return [.grass, .ice, .bug, .steel]
        case .water:
            return [.fire, .ground, .rock]
        case .electric:
            return [.water, .flying]
        case .grass:
            return [.water, .ground, .rock]
        case .ice:
            return [.grass, .ground, .flying, .dragon]
        case .fighting:
            return [.normal, .ice, .rock, .dark, .steel]
        case .poison:
            return [.grass, .fairy]
        case .ground:
            return [.fire, .electric, .poison, .rock, .steel]
        case .flying:
            return [.grass, .fighting, .bug]
        case .psychic:
            return [.fighting, .poison]
        case .bug:
            return [.grass, .psychic, .dark]
        case .rock:
            return [.fire, .ice, .flying, .bug]
        case .ghost:
            return [.psychic, .ghost]
        case .dragon:
            return [.dragon]
        case .dark:
            return [.psychic, .ghost]
        case .steel:
            return [.ice, .rock, .fairy]
        case .fairy:
            return [.fighting, .dragon, .dark]
        case .unknown:
            return []
        }
    }
    
    // Icon for UI
    var icon: String {
        switch self {
        case .normal:
            return "circle.fill"
        case .fire:
            return "flame.fill"
        case .water:
            return "drop.fill"
        case .electric:
            return "bolt.fill"
        case .grass:
            return "leaf.fill"
        case .ice:
            return "snowflake"
        case .fighting:
            return "fist.raised.fill"
        case .poison:
            return "drop.triangle.fill"
        case .ground:
            return "mountain.2.fill"
        case .flying:
            return "wind"
        case .psychic:
            return "brain.head.profile"
        case .bug:
            return "ant.fill"
        case .rock:
            return "diamond.fill"
        case .ghost:
            return "eyes"
        case .dragon:
            return "dragon.fill"
        case .dark:
            return "moon.fill"
        case .steel:
            return "shield.fill"
        case .fairy:
            return "star.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    // Emoji for collection UI
    var emoji: String {
        switch self {
        case .normal:
            return "⭐"
        case .fire:
            return "🔥"
        case .water:
            return "💧"
        case .electric:
            return "⚡"
        case .grass:
            return "🌿"
        case .ice:
            return "❄️"
        case .fighting:
            return "👊"
        case .poison:
            return "☠️"
        case .ground:
            return "🌍"
        case .flying:
            return "🌪️"
        case .psychic:
            return "🔮"
        case .bug:
            return "🐛"
        case .rock:
            return "🗿"
        case .ghost:
            return "👻"
        case .dragon:
            return "🐉"
        case .dark:
            return "🌙"
        case .steel:
            return "⚙️"
        case .fairy:
            return "🧚"
        case .unknown:
            return "❓"
        }
    }
    
    // MARK: - Shimmer Colors
    
    // Base shimmer color for skeleton loading
    var shimmerBaseColor: Color {
        switch self {
        case .normal:
            return Color(hex: "E5E5DC")
        case .fire:
            return Color(hex: "FFE4E1")
        case .water:
            return Color(hex: "E0F6FF")
        case .electric:
            return Color(hex: "FFFACD")
        case .grass:
            return Color(hex: "F0FFF0")
        case .ice:
            return Color(hex: "F0F8FF")
        case .fighting:
            return Color(hex: "FFE4E1")
        case .poison:
            return Color(hex: "E6E6FA")
        case .ground:
            return Color(hex: "F5DEB3")
        case .flying:
            return Color(hex: "E6E6FA")
        case .psychic:
            return Color(hex: "FFE4E6")
        case .bug:
            return Color(hex: "F5FFFA")
        case .rock:
            return Color(hex: "F5DEB3")
        case .ghost:
            return Color(hex: "E6E6FA")
        case .dragon:
            return Color(hex: "E6E6FA")
        case .dark:
            return Color(hex: "F5F5DC")
        case .steel:
            return Color(hex: "F8F8FF")
        case .fairy:
            return Color(hex: "FFF0F5")
        case .unknown:
            return Color(hex: "F0F8FF")
        }
    }
    
    // Shimmer highlight color
    var shimmerHighlightColor: Color {
        color.opacity(0.3)
    }
    
    // Shimmer gradient for animated effects
    var shimmerGradient: Gradient {
        Gradient(colors: [
            shimmerBaseColor,
            shimmerHighlightColor,
            color.opacity(0.1),
            shimmerHighlightColor,
            shimmerBaseColor
        ])
    }
    
    // Alternative shimmer gradient with more contrast
    var vibrantShimmerGradient: Gradient {
        Gradient(colors: [
            color.opacity(0.1),
            color.opacity(0.3),
            color.opacity(0.6),
            color.opacity(0.3),
            color.opacity(0.1)
        ])
    }
    
    // Subtle shimmer gradient for backgrounds
    var subtleShimmerGradient: Gradient {
        Gradient(colors: [
            Color.clear,
            shimmerBaseColor.opacity(0.5),
            Color.clear
        ])
    }
    
    // Pulsing shimmer colors
    var pulseColors: [Color] {
        [
            color.opacity(0.2),
            color.opacity(0.4),
            color.opacity(0.6),
            color.opacity(0.4),
            color.opacity(0.2)
        ]
    }
}

// MARK: - Type Effectiveness Calculator
struct TypeEffectiveness {
    static func effectiveness(attackingType: PokemonType, defendingTypes: [PokemonType]) -> Double {
        var multiplier = 1.0
        
        for defendingType in defendingTypes {
            if attackingType.strongAgainst.contains(defendingType) {
                multiplier *= 2.0
            } else if attackingType.weakTo.contains(defendingType) {
                multiplier *= 0.5
            }
        }
        
        return multiplier
    }
    
    static func effectivenessText(multiplier: Double) -> String {
        switch multiplier {
        case 0:
            return "No Effect"
        case 0.25:
            return "Not Very Effective"
        case 0.5:
            return "Not Very Effective"
        case 1.0:
            return "Normal Damage"
        case 2.0:
            return "Super Effective"
        case 4.0:
            return "Super Effective"
        default:
            return "Normal Damage"
        }
    }
}
