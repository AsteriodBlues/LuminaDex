//
//  RegionNode.swift
//  LuminaDex
//
//  Created by Ritwik on 8/2/25.
//

import SwiftUI

struct RegionNode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let generation: Int
    let position: CGPoint
    let baseSize: CGFloat
    let primaryColor: Color
    let secondaryColor: Color
    let phaseOffset: CGFloat
    let pokemonCount: Int
    let dominantTypes: [PokemonType]
    let legendaryPokemon: [String]
    let climate: RegionClimate
    
    enum RegionClimate {
        case temperate, tropical, arctic, desert, volcanic, mystical
        
        var environmentalEffects: [String] {
            switch self {
            case .temperate: return ["gentle_breeze", "seasonal_changes"]
            case .tropical: return ["humidity", "frequent_rain", "lush_growth"]
            case .arctic: return ["snow_particles", "aurora_lights", "ice_crystals"]
            case .desert: return ["sandstorms", "heat_waves", "mirages"]
            case .volcanic: return ["lava_flows", "ash_particles", "thermal_vents"]
            case .mystical: return ["magic_sparkles", "dimensional_rifts", "energy_wisps"]
            }
        }
    }
    
    static func createNetworkLayout() -> [RegionNode] {
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        let baseRadius: CGFloat = 200
        
        return [
            // Kanto - Central hub
            RegionNode(
                name: "Kanto",
                generation: 1,
                position: screenCenter,
                baseSize: 60,
                primaryColor: Color(hex: "FF6B6B"),
                secondaryColor: Color(hex: "FFE66D"),
                phaseOffset: 0,
                pokemonCount: 151,
                dominantTypes: [.normal, .fire, .water, .grass],
                legendaryPokemon: ["Mew", "Mewtwo", "Articuno"],
                climate: .temperate
            ),
            
            // Johto - Connected to Kanto
            RegionNode(
                name: "Johto",
                generation: 2,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * cos(0),
                    y: screenCenter.y + baseRadius * sin(0)
                ),
                baseSize: 55,
                primaryColor: Color(hex: "4ECDC4"),
                secondaryColor: Color(hex: "95E1D3"),
                phaseOffset: .pi / 3,
                pokemonCount: 100,
                dominantTypes: [.flying, .psychic, .dark, .steel],
                legendaryPokemon: ["Lugia", "Ho-Oh", "Celebi"],
                climate: .temperate
            ),
            
            // Hoenn - Tropical region
            RegionNode(
                name: "Hoenn",
                generation: 3,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * cos(.pi / 3),
                    y: screenCenter.y + baseRadius * sin(.pi / 3)
                ),
                baseSize: 58,
                primaryColor: Color(hex: "00D4FF"),
                secondaryColor: Color(hex: "00FF88"),
                phaseOffset: 2 * .pi / 3,
                pokemonCount: 135,
                dominantTypes: [.water, .grass, .ground, .rock],
                legendaryPokemon: ["Kyogre", "Groudon", "Rayquaza"],
                climate: .tropical
            ),
            
            // Sinnoh - Mystical region
            RegionNode(
                name: "Sinnoh",
                generation: 4,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * cos(2 * .pi / 3),
                    y: screenCenter.y + baseRadius * sin(2 * .pi / 3)
                ),
                baseSize: 52,
                primaryColor: Color(hex: "6B5FFF"),
                secondaryColor: Color(hex: "A8E6CF"),
                phaseOffset: .pi,
                pokemonCount: 107,
                dominantTypes: [.psychic, .dragon, .ghost, .steel],
                legendaryPokemon: ["Dialga", "Palkia", "Giratina"],
                climate: .mystical
            ),
            
            // Unova - Modern region
            RegionNode(
                name: "Unova",
                generation: 5,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * cos(.pi),
                    y: screenCenter.y + baseRadius * sin(.pi)
                ),
                baseSize: 54,
                primaryColor: Color(hex: "FFD93D"),
                secondaryColor: Color(hex: "FF8B94"),
                phaseOffset: 4 * .pi / 3,
                pokemonCount: 156,
                dominantTypes: [.electric, .fire, .fighting, .dark],
                legendaryPokemon: ["Reshiram", "Zekrom", "Kyurem"],
                climate: .temperate
            ),
            
            // Kalos - Elegant region
            RegionNode(
                name: "Kalos",
                generation: 6,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * cos(4 * .pi / 3),
                    y: screenCenter.y + baseRadius * sin(4 * .pi / 3)
                ),
                baseSize: 50,
                primaryColor: Color(hex: "FF9FF3"),
                secondaryColor: Color(hex: "F54A9B"),
                phaseOffset: 5 * .pi / 3,
                pokemonCount: 72,
                dominantTypes: [.fairy, .flying, .psychic, .grass],
                legendaryPokemon: ["Xerneas", "Yveltal", "Zygarde"],
                climate: .temperate
            ),
            
            // Alola - Tropical paradise
            RegionNode(
                name: "Alola",
                generation: 7,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * 1.5 * cos(5 * .pi / 3),
                    y: screenCenter.y + baseRadius * 1.5 * sin(5 * .pi / 3)
                ),
                baseSize: 48,
                primaryColor: Color(hex: "00FF88"),
                secondaryColor: Color(hex: "FFE66D"),
                phaseOffset: 0,
                pokemonCount: 81,
                dominantTypes: [.fire, .water, .grass, .psychic],
                legendaryPokemon: ["Solgaleo", "Lunala", "Necrozma"],
                climate: .tropical
            ),
            
            // Galar - Industrial region
            RegionNode(
                name: "Galar",
                generation: 8,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * 0.7 * cos(.pi / 6),
                    y: screenCenter.y + baseRadius * 0.7 * sin(.pi / 6)
                ),
                baseSize: 46,
                primaryColor: Color(hex: "A8E6CF"),
                secondaryColor: Color(hex: "88D8C0"),
                phaseOffset: .pi / 6,
                pokemonCount: 89,
                dominantTypes: [.steel, .poison, .ghost, .dragon],
                legendaryPokemon: ["Zacian", "Zamazenta", "Eternatus"],
                climate: .temperate
            ),
            
            // Paldea - Latest region
            RegionNode(
                name: "Paldea",
                generation: 9,
                position: CGPoint(
                    x: screenCenter.x + baseRadius * 0.8 * cos(7 * .pi / 6),
                    y: screenCenter.y + baseRadius * 0.8 * sin(7 * .pi / 6)
                ),
                baseSize: 44,
                primaryColor: Color(hex: "FF8B94"),
                secondaryColor: Color(hex: "FFD93D"),
                phaseOffset: .pi / 4,
                pokemonCount: 103,
                dominantTypes: [.normal, .fighting, .ghost, .fire],
                legendaryPokemon: ["Koraidon", "Miraidon", "Terapagos"],
                climate: .temperate
            )
        ]
    }
    
    func connectionStrength(to other: RegionNode) -> Float {
        let generationDiff = abs(self.generation - other.generation)
        let typeOverlap = Set(self.dominantTypes).intersection(Set(other.dominantTypes)).count
        
        // Higher connection strength for adjacent generations and shared types
        let baseStrength: Float = 1.0 / Float(generationDiff + 1)
        let typeBonus: Float = Float(typeOverlap) * 0.3
        
        return min(1.0, baseStrength + typeBonus)
    }
    
    func energyColor(for type: PokemonType) -> Color {
        switch type {
        case .fire: return Color(hex: "FF6B6B")
        case .water: return Color(hex: "4ECDC4")
        case .grass: return Color(hex: "00FF88")
        case .electric: return Color(hex: "FFD93D")
        case .psychic: return Color(hex: "6B5FFF")
        case .ice: return Color(hex: "95E1D3")
        case .dragon: return Color(hex: "FF8B94")
        case .dark: return Color(hex: "A8A8A8")
        case .fairy: return Color(hex: "FF9FF3")
        case .fighting: return Color(hex: "FF6B35")
        case .poison: return Color(hex: "B088F9")
        case .ground: return Color(hex: "D4A574")
        case .flying: return Color(hex: "A8E6CF")
        case .bug: return Color(hex: "88C999")
        case .rock: return Color(hex: "B8A082")
        case .ghost: return Color(hex: "8A2BE2")
        case .steel: return Color(hex: "87CEEB")
        case .normal: return Color(hex: "C8C8C8")
        case .unknown: return Color(hex: "68A090")
        }
    }
}

