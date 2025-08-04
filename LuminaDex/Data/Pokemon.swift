//
//  Pokemon.swift
//  LuminaDex
//
//  Created by Ritwik on 8/1/25.
//
import Foundation
import SwiftUI

// MARK: - Pokemon Model
struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let order: Int
    let isDefault: Bool?
    
    // These are local database fields, not from API
    var isFavorite: Bool = false
    var isCaught: Bool = false
    var catchDate: Date?
    var progress: Double = 0.0
    
    // Visual data
    let sprites: PokemonSprites
    let types: [PokemonTypeSlot]
    let abilities: [PokemonAbilitySlot]
    let stats: [PokemonStat]
    
    // Game data
    let species: PokemonSpecies
    let moves: [PokemonMove]?
    let gameIndices: [PokemonGameIndex]?
    
    // Computed properties for UI
    var displayName: String {
        name.capitalized
    }
    
    var primaryType: PokemonType {
        types.first?.pokemonType ?? .unknown
    }
    
    var formattedHeight: String {
        let meters = Double(height) / 10.0
        return String(format: "%.1f m", meters)
    }
    
    var formattedWeight: String {
        let kg = Double(weight) / 10.0
        return String(format: "%.1f kg", kg)
    }
    
    var primaryColor: Color {
        primaryType.color
    }
    
    var gradientColors: [Color] {
        if types.count >= 2 {
            return [types[0].pokemonType.color, types[1].pokemonType.color]
        }
        return [primaryType.color, primaryType.color.opacity(0.7)]
    }
    
    // Custom CodingKeys to exclude local database fields from API decoding
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case height
        case weight
        case baseExperience = "base_experience"
        case order
        case isDefault = "is_default"
        case sprites
        case types
        case abilities
        case stats
        case species
        case moves
        case gameIndices = "game_indices"
        // Exclude: isFavorite, isCaught, catchDate, progress
    }
}

// MARK: - Pokemon Sprites
struct PokemonSprites: Codable, Hashable {
    let frontDefault: String?
    let frontShiny: String?
    let frontFemale: String?
    let frontShinyFemale: String?
    let backDefault: String?
    let backShiny: String?
    let backFemale: String?
    let backShinyFemale: String?
    
    // Official artwork
    let other: PokemonSpritesOther?
    
    var defaultSprite: String {
        frontDefault ?? ""
    }
    
    var officialArtwork: String {
        other?.officialArtwork?.frontDefault ?? defaultSprite
    }
    
    var dreamWorldSprite: String {
        other?.dreamWorld?.frontDefault ?? defaultSprite
    }
}

// MARK: - Pokemon Sprites Other
struct PokemonSpritesOther: Codable, Hashable {
    let dreamWorld: PokemonDreamWorld?
    let home: PokemonHome?
    let officialArtwork: PokemonOfficialArtwork?
    
    private enum CodingKeys: String, CodingKey {
        case dreamWorld = "dream_world"
        case home
        case officialArtwork = "official-artwork"
    }
}

// MARK: - Pokemon Dream World
struct PokemonDreamWorld: Codable, Hashable {
    let frontDefault: String?
    let frontFemale: String?
}

// MARK: - Pokemon Home
struct PokemonHome: Codable, Hashable {
    let frontDefault: String?
    let frontFemale: String?
    let frontShiny: String?
    let frontShinyFemale: String?
}

// MARK: - Pokemon Official Artwork
struct PokemonOfficialArtwork: Codable, Hashable {
    let frontDefault: String?
    let frontShiny: String?
}

// MARK: - Pokemon Type Slot
struct PokemonTypeSlot: Codable, Hashable {
    let slot: Int
    let type: PokemonTypeInfo
    
    var pokemonType: PokemonType {
        PokemonType(rawValue: type.name) ?? .unknown
    }
}

// MARK: - Pokemon Type Info
struct PokemonTypeInfo: Codable, Hashable {
    let name: String
    let url: String
}

// MARK: - Pokemon Ability Slot
struct PokemonAbilitySlot: Codable, Hashable {
    let isHidden: Bool
    let slot: Int
    let ability: PokemonAbility
}

// MARK: - Pokemon Ability
struct PokemonAbility: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Pokemon Stat
struct PokemonStat: Codable, Hashable {
    let baseStat: Int
    let effort: Int
    let stat: StatType
    
    var normalizedValue: Double {
        // Normalize to 0-1 for UI animations
        Double(baseStat) / 255.0
    }
}

// MARK: - Stat Type
struct StatType: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Attack"
        case "special-defense": return "Sp. Defense"
        case "speed": return "Speed"
        default: return name.capitalized
        }
    }
    
    var shortName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "ATK"
        case "defense": return "DEF"
        case "special-attack": return "SPA"
        case "special-defense": return "SPD"
        case "speed": return "SPE"
        default: return name.uppercased()
        }
    }
}

// MARK: - Pokemon Species
struct PokemonSpecies: Codable, Hashable {
    let name: String
    let url: String
}

// MARK: - Pokemon Move
struct PokemonMove: Codable, Hashable {
    let move: PokemonMoveDetail
    let versionGroupDetails: [PokemonMoveVersionGroup]
}

// MARK: - Pokemon Move Detail
struct PokemonMoveDetail: Codable, Hashable {
    let name: String
    let url: String
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Pokemon Move Version Group
struct PokemonMoveVersionGroup: Codable, Hashable {
    let levelLearnedAt: Int
    let moveLearnMethod: PokemonMoveLearnMethod
    let versionGroup: PokemonVersionGroup
}

// MARK: - Pokemon Move Learn Method
struct PokemonMoveLearnMethod: Codable, Hashable {
    let name: String
    let url: String
}

// MARK: - Pokemon Version Group
struct PokemonVersionGroup: Codable, Hashable {
    let name: String
    let url: String
}

// MARK: - Pokemon Game Index
struct PokemonGameIndex: Codable, Hashable {
    let gameIndex: Int
    let version: PokemonVersion
}

// MARK: - Pokemon Version
struct PokemonVersion: Codable, Hashable {
    let name: String
    let url: String
}
