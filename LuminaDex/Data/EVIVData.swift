//
//  EVIVData.swift
//  LuminaDex
//
//  Complete EV/IV system for competitive training
//

import Foundation
import SwiftUI

// MARK: - IV (Individual Values)
struct IVSpread: Codable, Hashable {
    var hp: Int = 31
    var attack: Int = 31
    var defense: Int = 31
    var specialAttack: Int = 31
    var specialDefense: Int = 31
    var speed: Int = 31
    
    init(hp: Int = 31, attack: Int = 31, defense: Int = 31, 
         specialAttack: Int = 31, specialDefense: Int = 31, speed: Int = 31) {
        self.hp = min(31, max(0, hp))
        self.attack = min(31, max(0, attack))
        self.defense = min(31, max(0, defense))
        self.specialAttack = min(31, max(0, specialAttack))
        self.specialDefense = min(31, max(0, specialDefense))
        self.speed = min(31, max(0, speed))
    }
    
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    var perfection: Double {
        Double(total) / 186.0 * 100 // 186 = 31 * 6
    }
    
    var hiddenPowerType: PokemonType {
        // Hidden Power calculation based on IVs
        let a = hp % 2
        let b = attack % 2
        let c = defense % 2
        let d = speed % 2
        let e = specialAttack % 2
        let f = specialDefense % 2
        
        let typeIndex = ((a + 2*b + 4*c + 8*d + 16*e + 32*f) * 15) / 63
        
        let types: [PokemonType] = [
            .fighting, .flying, .poison, .ground,
            .rock, .bug, .ghost, .steel,
            .fire, .water, .grass, .electric,
            .psychic, .ice, .dragon, .dark
        ]
        
        return types[min(typeIndex, types.count - 1)]
    }
    
    var hiddenPowerDamage: Int {
        let a = (hp % 2 == 1) ? 1 : 0
        let b = (attack % 2 == 1) ? 1 : 0
        let c = (defense % 2 == 1) ? 1 : 0
        let d = (speed % 2 == 1) ? 1 : 0
        let e = (specialAttack % 2 == 1) ? 1 : 0
        let f = (specialDefense % 2 == 1) ? 1 : 0
        
        return ((a + 2*b + 4*c + 8*d + 16*e + 32*f) * 40 / 63) + 30
    }
    
    static let perfect = IVSpread()
    static let zero = IVSpread(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
    static let trickRoom = IVSpread(hp: 31, attack: 31, defense: 31, specialAttack: 31, specialDefense: 31, speed: 0)
    static let special = IVSpread(hp: 31, attack: 0, defense: 31, specialAttack: 31, specialDefense: 31, speed: 31)
}

// MARK: - EV (Effort Values)
struct EVSpread: Codable, Hashable {
    var hp: Int = 0
    var attack: Int = 0
    var defense: Int = 0
    var specialAttack: Int = 0
    var specialDefense: Int = 0
    var speed: Int = 0
    
    init(hp: Int = 0, attack: Int = 0, defense: Int = 0,
         specialAttack: Int = 0, specialDefense: Int = 0, speed: Int = 0) {
        self.hp = min(252, max(0, hp))
        self.attack = min(252, max(0, attack))
        self.defense = min(252, max(0, defense))
        self.specialAttack = min(252, max(0, specialAttack))
        self.specialDefense = min(252, max(0, specialDefense))
        self.speed = min(252, max(0, speed))
        
        // Ensure total doesn't exceed 510
        let total = self.total
        if total > 510 {
            let ratio = 510.0 / Double(total)
            self.hp = Int(Double(self.hp) * ratio)
            self.attack = Int(Double(self.attack) * ratio)
            self.defense = Int(Double(self.defense) * ratio)
            self.specialAttack = Int(Double(self.specialAttack) * ratio)
            self.specialDefense = Int(Double(self.specialDefense) * ratio)
            self.speed = Int(Double(self.speed) * ratio)
        }
    }
    
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    var remaining: Int {
        max(0, 510 - total)
    }
    
    var isValid: Bool {
        total <= 510 && hp <= 252 && attack <= 252 && defense <= 252 &&
        specialAttack <= 252 && specialDefense <= 252 && speed <= 252
    }
    
    var distribution: String {
        var parts: [String] = []
        if hp > 0 { parts.append("\(hp) HP") }
        if attack > 0 { parts.append("\(attack) Atk") }
        if defense > 0 { parts.append("\(defense) Def") }
        if specialAttack > 0 { parts.append("\(specialAttack) SpA") }
        if specialDefense > 0 { parts.append("\(specialDefense) SpD") }
        if speed > 0 { parts.append("\(speed) Spe") }
        return parts.joined(separator: " / ")
    }
    
    // Common competitive spreads
    static let physical = EVSpread(hp: 4, attack: 252, speed: 252)
    static let special = EVSpread(hp: 4, specialAttack: 252, speed: 252)
    static let bulkyPhysical = EVSpread(hp: 252, attack: 252, defense: 4)
    static let bulkySpecial = EVSpread(hp: 252, specialAttack: 252, specialDefense: 4)
    static let defensive = EVSpread(hp: 252, defense: 128, specialDefense: 128)
    static let mixed = EVSpread(attack: 128, specialAttack: 128, speed: 252)
}

// MARK: - EV Yield (What Pokemon gives when defeated)
struct EVYield: Codable, Hashable {
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    var description: String {
        var parts: [String] = []
        if hp > 0 { parts.append("\(hp) HP") }
        if attack > 0 { parts.append("\(attack) Attack") }
        if defense > 0 { parts.append("\(defense) Defense") }
        if specialAttack > 0 { parts.append("\(specialAttack) Sp. Attack") }
        if specialDefense > 0 { parts.append("\(specialDefense) Sp. Defense") }
        if speed > 0 { parts.append("\(speed) Speed") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Training Item
struct TrainingItem {
    let name: String
    let stat: NatureStatType
    let evBoost: Int
    let icon: String
    
    static let powerItems = [
        TrainingItem(name: "Power Weight", stat: NatureStatType.hp, evBoost: 8, icon: "scalemass.fill"),
        TrainingItem(name: "Power Bracer", stat: NatureStatType.attack, evBoost: 8, icon: "bolt.fill"),
        TrainingItem(name: "Power Belt", stat: NatureStatType.defense, evBoost: 8, icon: "shield.fill"),
        TrainingItem(name: "Power Lens", stat: NatureStatType.specialAttack, evBoost: 8, icon: "eye.fill"),
        TrainingItem(name: "Power Band", stat: NatureStatType.specialDefense, evBoost: 8, icon: "bandage.fill"),
        TrainingItem(name: "Power Anklet", stat: NatureStatType.speed, evBoost: 8, icon: "hare.fill")
    ]
    
    static let vitamins = [
        TrainingItem(name: "HP Up", stat: NatureStatType.hp, evBoost: 10, icon: "heart.fill"),
        TrainingItem(name: "Protein", stat: NatureStatType.attack, evBoost: 10, icon: "bolt.fill"),
        TrainingItem(name: "Iron", stat: NatureStatType.defense, evBoost: 10, icon: "shield.fill"),
        TrainingItem(name: "Calcium", stat: NatureStatType.specialAttack, evBoost: 10, icon: "sparkles"),
        TrainingItem(name: "Zinc", stat: NatureStatType.specialDefense, evBoost: 10, icon: "leaf.fill"),
        TrainingItem(name: "Carbos", stat: NatureStatType.speed, evBoost: 10, icon: "hare.fill")
    ]
}

// MARK: - Stat Calculator
struct StatCalculator {
    static func calculateHP(base: Int, iv: Int, ev: Int, level: Int) -> Int {
        if base == 1 { // Shedinja special case
            return 1
        }
        return ((2 * base + iv + (ev / 4)) * level / 100) + level + 10
    }
    
    static func calculateStat(base: Int, iv: Int, ev: Int, level: Int, nature: Double = 1.0) -> Int {
        let stat = ((2 * base + iv + (ev / 4)) * level / 100) + 5
        return Int(Double(stat) * nature)
    }
    
    static func calculateAllStats(pokemon: Pokemon, ivs: IVSpread, evs: EVSpread, 
                                  level: Int = 50, nature: Nature? = nil) -> PokemonStats {
        let natureBonus = nature ?? NatureChart.allNatures[0] // Hardy (neutral) by default
        
        let hp = pokemon.stats.first { $0.stat.name == "hp" }?.baseStat ?? 0
        let attack = pokemon.stats.first { $0.stat.name == "attack" }?.baseStat ?? 0
        let defense = pokemon.stats.first { $0.stat.name == "defense" }?.baseStat ?? 0
        let specialAttack = pokemon.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0
        let specialDefense = pokemon.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0
        let speed = pokemon.stats.first { $0.stat.name == "speed" }?.baseStat ?? 0
        
        return PokemonStats(
            hp: calculateHP(base: hp, iv: ivs.hp, ev: evs.hp, level: level),
            attack: calculateStat(base: attack, iv: ivs.attack, ev: evs.attack, 
                                level: level, nature: natureBonus.getNatureMultiplier(for: NatureStatType.attack)),
            defense: calculateStat(base: defense, iv: ivs.defense, ev: evs.defense,
                                 level: level, nature: natureBonus.getNatureMultiplier(for: NatureStatType.defense)),
            specialAttack: calculateStat(base: specialAttack, iv: ivs.specialAttack, 
                                        ev: evs.specialAttack, level: level, 
                                        nature: natureBonus.getNatureMultiplier(for: NatureStatType.specialAttack)),
            specialDefense: calculateStat(base: specialDefense, iv: ivs.specialDefense,
                                         ev: evs.specialDefense, level: level,
                                         nature: natureBonus.getNatureMultiplier(for: NatureStatType.specialDefense)),
            speed: calculateStat(base: speed, iv: ivs.speed, ev: evs.speed,
                               level: level, nature: natureBonus.getNatureMultiplier(for: NatureStatType.speed))
        )
    }
}