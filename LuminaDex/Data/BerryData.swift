//
//  BerryData.swift
//  LuminaDex
//
//  Complete berry system with effects and flavors
//

import Foundation
import SwiftUI

// MARK: - Berry Model
struct Berry: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let growthTime: Int
    let maxHarvest: Int
    let naturalGiftPower: Int
    let naturalGiftType: PokemonType?
    let size: Int
    let smoothness: Int
    let soilDryness: Int
    let firmness: String
    let flavors: BerryFlavors
    let item: BerryItem
    
    var displayName: String {
        name.capitalized + " Berry"
    }
    
    var growthTimeHours: Int {
        growthTime
    }
    
    var spriteURL: String {
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(name)-berry.png"
    }
}

// MARK: - Berry Flavors
struct BerryFlavors: Codable, Hashable {
    let spicy: Int
    let dry: Int
    let sweet: Int
    let bitter: Int
    let sour: Int
    
    var dominant: BerryFlavor? {
        let flavors = [
            (BerryFlavor.spicy, spicy),
            (BerryFlavor.dry, dry),
            (BerryFlavor.sweet, sweet),
            (BerryFlavor.bitter, bitter),
            (BerryFlavor.sour, sour)
        ]
        
        return flavors.max(by: { $0.1 < $1.1 })?.0
    }
    
    var total: Int {
        spicy + dry + sweet + bitter + sour
    }
}

// MARK: - Berry Item
struct BerryItem: Codable, Hashable {
    let name: String
    let effect: String
    let shortEffect: String
    let cost: Int
    let attributes: [String]
    
    var displayName: String {
        name.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

// MARK: - Berry Category
enum BerryCategory: String, CaseIterable, Codable {
    case healing = "healing"
    case statusCure = "status-cure"
    case typeResist = "type-resist"
    case evReducing = "ev-reducing"
    case statBoost = "stat-boost"
    case pinch = "pinch"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .healing: return "Healing"
        case .statusCure: return "Status Cure"
        case .typeResist: return "Type Resist"
        case .evReducing: return "EV Reducing"
        case .statBoost: return "Stat Boost"
        case .pinch: return "Pinch"
        case .other: return "Other"
        }
    }
    
    var color: Color {
        switch self {
        case .healing: return .pink
        case .statusCure: return .green
        case .typeResist: return .blue
        case .evReducing: return .orange
        case .statBoost: return .purple
        case .pinch: return .red
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .healing: return "heart.fill"
        case .statusCure: return "cross.circle.fill"
        case .typeResist: return "shield.fill"
        case .evReducing: return "minus.circle.fill"
        case .statBoost: return "arrow.up.circle.fill"
        case .pinch: return "exclamationmark.triangle.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    static func categorize(_ berry: Berry) -> BerryCategory {
        let name = berry.name.lowercased()
        let effect = berry.item.effect.lowercased()
        
        // Check for healing berries
        if name.contains("oran") || name.contains("sitrus") || name.contains("mago") ||
           name.contains("wiki") || name.contains("aguav") || name.contains("iapapa") ||
           name.contains("figy") || effect.contains("restores hp") {
            return .healing
        }
        
        // Check for status cure berries
        if name.contains("cheri") || name.contains("chesto") || name.contains("pecha") ||
           name.contains("rawst") || name.contains("aspear") || name.contains("leppa") ||
           name.contains("lum") || name.contains("persim") || effect.contains("cures") {
            return .statusCure
        }
        
        // Check for type resist berries
        if name.contains("occa") || name.contains("passho") || name.contains("wacan") ||
           name.contains("rindo") || name.contains("yache") || name.contains("chople") ||
           name.contains("kebia") || name.contains("shuca") || name.contains("coba") ||
           name.contains("payapa") || name.contains("tanga") || name.contains("charti") ||
           name.contains("kasib") || name.contains("haban") || name.contains("colbur") ||
           name.contains("babiri") || name.contains("chilan") || name.contains("roseli") ||
           effect.contains("weakens") || effect.contains("super effective") {
            return .typeResist
        }
        
        // Check for EV reducing berries
        if name.contains("pomeg") || name.contains("kelpsy") || name.contains("qualot") ||
           name.contains("hondew") || name.contains("grepa") || name.contains("tamato") ||
           effect.contains("lowers") && effect.contains("ev") {
            return .evReducing
        }
        
        // Check for stat boost berries
        if name.contains("liechi") || name.contains("ganlon") || name.contains("salac") ||
           name.contains("petaya") || name.contains("apicot") || name.contains("lansat") ||
           name.contains("starf") || name.contains("micle") || name.contains("custap") ||
           effect.contains("raises") || effect.contains("boosts") {
            return .statBoost
        }
        
        // Check for pinch berries
        if effect.contains("when hp") || effect.contains("in a pinch") {
            return .pinch
        }
        
        return .other
    }
}

// MARK: - Common Berries
struct CommonBerries {
    static let healingBerries = [
        "oran", // Restores 10 HP
        "sitrus", // Restores 25% HP
        "figy", // Restores 50% HP but confuses if nature dislikes spicy
        "wiki", // Restores 50% HP but confuses if nature dislikes dry
        "mago", // Restores 50% HP but confuses if nature dislikes sweet
        "aguav", // Restores 50% HP but confuses if nature dislikes bitter
        "iapapa" // Restores 50% HP but confuses if nature dislikes sour
    ]
    
    static let statusBerries = [
        "cheri", // Cures paralysis
        "chesto", // Cures sleep
        "pecha", // Cures poison
        "rawst", // Cures burn
        "aspear", // Cures freeze
        "persim", // Cures confusion
        "lum" // Cures any status
    ]
    
    static let typeResistBerries = [
        "occa", // Fire resist
        "passho", // Water resist
        "wacan", // Electric resist
        "rindo", // Grass resist
        "yache", // Ice resist
        "chople", // Fighting resist
        "kebia", // Poison resist
        "shuca", // Ground resist
        "coba", // Flying resist
        "payapa", // Psychic resist
        "tanga", // Bug resist
        "charti", // Rock resist
        "kasib", // Ghost resist
        "haban", // Dragon resist
        "colbur", // Dark resist
        "babiri", // Steel resist
        "chilan", // Normal resist
        "roseli" // Fairy resist
    ]
    
    static let evReducingBerries = [
        "pomeg", // HP EVs -10
        "kelpsy", // Attack EVs -10
        "qualot", // Defense EVs -10
        "hondew", // Sp. Attack EVs -10
        "grepa", // Sp. Defense EVs -10
        "tamato" // Speed EVs -10
    ]
    
    static let pinchBerries = [
        "liechi", // +1 Attack at 25% HP
        "ganlon", // +1 Defense at 25% HP
        "salac", // +1 Speed at 25% HP
        "petaya", // +1 Sp. Attack at 25% HP
        "apicot", // +1 Sp. Defense at 25% HP
        "lansat", // +Critical hit ratio at 25% HP
        "starf", // +2 random stat at 25% HP
        "micle", // +20% accuracy at 25% HP
        "custap" // Move first in priority bracket at 25% HP
    ]
}

// MARK: - Berry Farming
struct BerryFarming {
    let berry: Berry
    let plantedAt: Date
    let wateringCount: Int
    let mutations: [Berry]
    
    var isReady: Bool {
        let hoursElapsed = Date().timeIntervalSince(plantedAt) / 3600
        return hoursElapsed >= Double(berry.growthTime)
    }
    
    var timeRemaining: TimeInterval {
        let targetTime = plantedAt.addingTimeInterval(TimeInterval(berry.growthTime * 3600))
        return max(0, targetTime.timeIntervalSince(Date()))
    }
    
    var yield: Int {
        // More watering = more berries
        let baseYield = berry.maxHarvest / 2
        let waterBonus = min(wateringCount, berry.maxHarvest / 2)
        return baseYield + waterBonus
    }
    
    static func checkMutation(berry1: Berry, berry2: Berry) -> Berry? {
        // Implement berry mutation logic
        // Different berry combinations can produce rare berries
        return nil
    }
}