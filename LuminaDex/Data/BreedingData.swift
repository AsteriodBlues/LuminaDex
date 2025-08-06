//
//  BreedingData.swift
//  LuminaDex
//
//  Complete breeding system with egg groups and inheritance
//

import Foundation
import SwiftUI

// MARK: - Egg Group
enum EggGroup: String, CaseIterable, Codable {
    case monster = "monster"
    case waterOne = "water1"
    case waterTwo = "water2"
    case waterThree = "water3"
    case bug = "bug"
    case flying = "flying"
    case field = "field"
    case fairy = "fairy"
    case grass = "grass"
    case humanLike = "human-like"
    case mineral = "mineral"
    case amorphous = "amorphous"
    case dragon = "dragon"
    case undiscovered = "undiscovered"
    case ditto = "ditto"
    
    var displayName: String {
        switch self {
        case .waterOne: return "Water 1"
        case .waterTwo: return "Water 2"
        case .waterThree: return "Water 3"
        case .humanLike: return "Human-Like"
        default: return rawValue.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .monster: return "pawprint.fill"
        case .waterOne, .waterTwo, .waterThree: return "drop.fill"
        case .bug: return "ant.fill"
        case .flying: return "bird.fill"
        case .field: return "hare.fill"
        case .fairy: return "sparkles"
        case .grass: return "leaf.fill"
        case .humanLike: return "person.fill"
        case .mineral: return "cube.fill"
        case .amorphous: return "smoke.fill"
        case .dragon: return "flame.fill"
        case .undiscovered: return "questionmark.circle.fill"
        case .ditto: return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .monster: return .purple
        case .waterOne, .waterTwo, .waterThree: return .blue
        case .bug: return .green
        case .flying: return .cyan
        case .field: return .brown
        case .fairy: return .pink
        case .grass: return .green
        case .humanLike: return .orange
        case .mineral: return .gray
        case .amorphous: return .indigo
        case .dragon: return .red
        case .undiscovered: return .black
        case .ditto: return .purple
        }
    }
}

// MARK: - Breeding Info
struct BreedingInfo: Codable, Hashable {
    let eggGroups: [EggGroup]
    let hatchCycles: Int
    let babyTriggerItem: String?
    let genderRate: Int // -1 = genderless, 0 = always male, 8 = always female, 1-7 = ratio
    let hasGenderDifferences: Bool
    
    var canBreed: Bool {
        !eggGroups.contains(.undiscovered)
    }
    
    var eggSteps: Int {
        hatchCycles * 256
    }
    
    var genderRatio: (male: Double, female: Double) {
        if genderRate == -1 {
            return (0, 0) // Genderless
        } else if genderRate == 0 {
            return (100, 0) // Always male
        } else if genderRate == 8 {
            return (0, 100) // Always female
        } else {
            let femaleChance = Double(genderRate) * 12.5
            return (100 - femaleChance, femaleChance)
        }
    }
    
    var genderDescription: String {
        if genderRate == -1 {
            return "Genderless"
        } else {
            let ratio = genderRatio
            return "♂ \(Int(ratio.male))% / ♀ \(Int(ratio.female))%"
        }
    }
}

// MARK: - Egg Move
struct EggMove: Identifiable, Codable, Hashable {
    let id = UUID()
    let moveId: Int
    let moveName: String
    let learnMethod: String
    
    var displayName: String {
        moveName.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

// MARK: - Inheritance
struct Inheritance {
    enum InheritanceType {
        case nature(chance: Double)
        case ability(slot: Int)
        case ivs(count: Int)
        case eggMoves([EggMove])
        case pokeball
        case hiddenAbility(chance: Double)
    }
    
    static func calculateInheritedIVs(parent1: IVSpread, parent2: IVSpread, 
                                     destinyKnot: Bool = false) -> IVSpread {
        let inheritCount = destinyKnot ? 5 : 3
        let stats: [WritableKeyPath<IVSpread, Int>] = [
            \.hp, \.attack, \.defense, \.specialAttack, \.specialDefense, \.speed
        ]
        
        var childIVs = IVSpread(
            hp: Int.random(in: 0...31),
            attack: Int.random(in: 0...31),
            defense: Int.random(in: 0...31),
            specialAttack: Int.random(in: 0...31),
            specialDefense: Int.random(in: 0...31),
            speed: Int.random(in: 0...31)
        )
        
        let selectedStats = stats.shuffled().prefix(inheritCount)
        
        for stat in selectedStats {
            let parentChoice = Bool.random()
            let parentIV = parentChoice ? parent1[keyPath: stat] : parent2[keyPath: stat]
            childIVs[keyPath: stat] = parentIV
        }
        
        return childIVs
    }
    
    static func calculateNatureInheritance(parent1Nature: Nature?, parent2Nature: Nature?, 
                                          everstone: Bool = false) -> Nature? {
        guard everstone, let parentNature = parent1Nature ?? parent2Nature else {
            return nil // Random nature
        }
        
        // 100% chance with Everstone
        return parentNature
    }
    
    static func calculateAbilityInheritance(motherAbility: PokemonAbilitySlot, 
                                           fatherAbility: PokemonAbilitySlot?,
                                           isDitto: Bool = false) -> Double {
        // Hidden Ability inheritance chances
        if motherAbility.isHidden {
            return isDitto ? 0.6 : 0.8 // 60% with Ditto, 80% otherwise
        } else if let father = fatherAbility, father.isHidden && isDitto {
            return 0.6 // Male/Genderless with Hidden Ability + Ditto
        }
        
        return 0.0 // Cannot pass Hidden Ability
    }
}

// MARK: - Breeding Calculator
struct BreedingCalculator {
    static func canBreedTogether(_ pokemon1: BreedingInfo, _ pokemon2: BreedingInfo) -> Bool {
        // Check if either is Ditto
        if pokemon1.eggGroups.contains(.ditto) || pokemon2.eggGroups.contains(.ditto) {
            // Ditto can breed with anything except Undiscovered and other Ditto
            return !pokemon1.eggGroups.contains(.undiscovered) && 
                   !pokemon2.eggGroups.contains(.undiscovered) &&
                   !(pokemon1.eggGroups.contains(.ditto) && pokemon2.eggGroups.contains(.ditto))
        }
        
        // Check if they share an egg group
        let sharedGroups = Set(pokemon1.eggGroups).intersection(Set(pokemon2.eggGroups))
        return !sharedGroups.isEmpty && !sharedGroups.contains(.undiscovered)
    }
    
    static func calculateShinyOdds(masudaMethod: Bool = false, shinyCharm: Bool = false) -> String {
        var odds = 4096 // Base odds 1/4096
        
        if masudaMethod {
            odds = odds / 6 // 6x increase with Masuda Method
        }
        
        if shinyCharm {
            odds = odds * 2 / 3 // Additional increase with Shiny Charm
        }
        
        return "1/\(odds)"
    }
}

// MARK: - Daycare Compatibility
enum DaycareCompatibility {
    case preferDifferentSpecies
    case preferSameSpecies  
    case notVeryCompatible
    case incompatible
    
    var message: String {
        switch self {
        case .preferDifferentSpecies:
            return "The two prefer to play with other Pokémon more than with each other."
        case .preferSameSpecies:
            return "The two seem to get along very well!"
        case .notVeryCompatible:
            return "The two don't really seem to like each other very much."
        case .incompatible:
            return "The two prefer to play with other Pokémon more than with each other."
        }
    }
    
    var eggChance: Int {
        switch self {
        case .preferDifferentSpecies: return 70
        case .preferSameSpecies: return 50
        case .notVeryCompatible: return 20
        case .incompatible: return 0
        }
    }
}