//
//  ItemData.swift
//  LuminaDex
//
//  Complete item system with categories and effects
//

import Foundation
import SwiftUI

// MARK: - Item Model
struct Item: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let category: ItemCategory
    let cost: Int
    let flingPower: Int?
    let flingEffect: String?
    let effect: String
    let shortEffect: String
    let attributes: [String]
    
    var displayName: String {
        name.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var spriteURL: String {
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(name).png"
    }
    
    var isHoldable: Bool {
        attributes.contains("holdable")
    }
    
    var isUsableInBattle: Bool {
        attributes.contains("usable-in-battle")
    }
    
    var isConsumable: Bool {
        attributes.contains("consumable")
    }
}

// MARK: - Item Category
enum ItemCategory: String, CaseIterable, Codable {
    case pokeballs = "pokeballs"
    case medicine = "medicine"
    case battleItems = "battle-items"
    case berries = "berries"
    case tmhm = "tm-hm"
    case treasures = "treasures"
    case keyItems = "key-items"
    case heldItems = "held-items"
    case evolutionItems = "evolution"
    case megaStones = "mega-stones"
    case zCrystals = "z-crystals"
    case memories = "memories"
    case plates = "plates"
    case training = "training"
    case vitamins = "vitamins"
    
    var displayName: String {
        switch self {
        case .pokeballs: return "Poké Balls"
        case .medicine: return "Medicine"
        case .battleItems: return "Battle Items"
        case .berries: return "Berries"
        case .tmhm: return "TMs & HMs"
        case .treasures: return "Treasures"
        case .keyItems: return "Key Items"
        case .heldItems: return "Held Items"
        case .evolutionItems: return "Evolution Items"
        case .megaStones: return "Mega Stones"
        case .zCrystals: return "Z-Crystals"
        case .memories: return "Memories"
        case .plates: return "Plates"
        case .training: return "Training"
        case .vitamins: return "Vitamins"
        }
    }
    
    var icon: String {
        switch self {
        case .pokeballs: return "circle.circle.fill"
        case .medicine: return "cross.case.fill"
        case .battleItems: return "shield.fill"
        case .berries: return "leaf.fill"
        case .tmhm: return "disc.fill"
        case .treasures: return "sparkles"
        case .keyItems: return "key.fill"
        case .heldItems: return "hands.sparkles"
        case .evolutionItems: return "arrow.triangle.2.circlepath"
        case .megaStones: return "star.circle.fill"
        case .zCrystals: return "diamond.fill"
        case .memories: return "memories"
        case .plates: return "square.stack.3d.up.fill"
        case .training: return "figure.run"
        case .vitamins: return "pills.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pokeballs: return .red
        case .medicine: return .pink
        case .battleItems: return .orange
        case .berries: return .green
        case .tmhm: return .blue
        case .treasures: return .yellow
        case .keyItems: return .purple
        case .heldItems: return .indigo
        case .evolutionItems: return .mint
        case .megaStones: return Color(red: 0.7, green: 0.3, blue: 0.9)
        case .zCrystals: return .cyan
        case .memories: return .gray
        case .plates: return .brown
        case .training: return .teal
        case .vitamins: return .orange
        }
    }
}

// MARK: - Held Item
struct HeldItem: Codable, Hashable {
    let item: ItemReference
    let versionDetails: [VersionDetail]
    
    struct ItemReference: Codable, Hashable {
        let name: String
        let url: String
    }
    
    struct VersionDetail: Codable, Hashable {
        let rarity: Int
        let version: VersionReference
    }
    
    struct VersionReference: Codable, Hashable {
        let name: String
        let url: String
    }
}

// MARK: - Competitive Items
struct CompetitiveItem {
    let item: Item
    let tier: Tier
    let usage: Double
    let builds: [String]
    
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
    }
    
    static let topItems = [
        "choice-band", "choice-specs", "choice-scarf",
        "leftovers", "life-orb", "focus-sash",
        "assault-vest", "rocky-helmet", "heavy-duty-boots",
        "weakness-policy", "eviolite", "light-clay"
    ]
}

// MARK: - Evolution Items
struct EvolutionItem {
    let itemName: String
    let evolutions: [Evolution]
    
    struct Evolution {
        let from: String
        let to: String
        let condition: String?
    }
    
    static let items = [
        "fire-stone", "water-stone", "thunder-stone", "leaf-stone",
        "moon-stone", "sun-stone", "shiny-stone", "dusk-stone",
        "dawn-stone", "ice-stone", "kings-rock", "metal-coat",
        "dragon-scale", "upgrade", "dubious-disc", "protector",
        "electirizer", "magmarizer", "razor-claw", "razor-fang",
        "reaper-cloth", "prism-scale", "whipped-dream", "sachet"
    ]
}

