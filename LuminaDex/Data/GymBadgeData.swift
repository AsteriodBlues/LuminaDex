//
//  GymBadgeData.swift
//  LuminaDex
//
//  Comprehensive Gym Badge system with all regions
//

import Foundation
import SwiftUI

// MARK: - Gym Badge Model
struct GymBadge: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let region: Region
    let gymLeader: String
    let city: String
    let type: PokemonType
    let badgeNumber: Int
    let tmReward: String?
    let levelCap: Int?
    let description: String
    
    var displayName: String {
        "\(name) Badge"
    }
    
    var imageURL: String {
        // Using actual badge sprites from Serebii
        switch region {
        case .kanto:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .johto:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .hoenn:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .sinnoh:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .unova:
            return "https://www.serebii.net/itemdex/sprites/\(unovanBadgeName())badge.png"
        case .kalos:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .galar:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        case .paldea:
            return "https://www.serebii.net/itemdex/sprites/\(name.lowercased())badge.png"
        default:
            return ""
        }
    }
    
    private func unovanBadgeName() -> String {
        // Unova badges have different naming
        switch name.lowercased() {
        case "trio": return "basic"
        case "basic": return "basic"
        case "insect": return "beetle"
        case "bolt": return "bolt"
        case "quake": return "quake"
        case "jet": return "jet"
        case "freeze": return "freeze"
        case "legend": return "legend"
        default: return name.lowercased()
        }
    }
    
    enum Region: String, CaseIterable, Codable {
        case kanto = "Kanto"
        case johto = "Johto"
        case hoenn = "Hoenn"
        case sinnoh = "Sinnoh"
        case unova = "Unova"
        case kalos = "Kalos"
        case alola = "Alola"
        case galar = "Galar"
        case paldea = "Paldea"
        
        var displayName: String {
            rawValue
        }
        
        var color: Color {
            switch self {
            case .kanto: return .red
            case .johto: return .yellow
            case .hoenn: return .blue
            case .sinnoh: return .purple
            case .unova: return .orange
            case .kalos: return .pink
            case .alola: return .green
            case .galar: return .indigo
            case .paldea: return .mint
            }
        }
        
        var badgeImagePath: String {
            switch self {
            case .kanto: return "d/d0"
            case .johto: return "7/70"
            case .hoenn: return "4/42"
            case .sinnoh: return "6/6b"
            case .unova: return "5/54"
            case .kalos: return "b/b9"
            case .alola: return "0/0a"
            case .galar: return "1/1a"
            case .paldea: return "8/8d"
            }
        }
        
        var totalBadges: Int {
            switch self {
            case .kanto, .johto, .hoenn, .sinnoh, .unova, .kalos, .galar, .paldea: return 8
            case .alola: return 0 // Alola uses trials instead
            }
        }
    }
}

// MARK: - All Gym Badges Data
struct GymBadgeDatabase {
    static let allBadges: [GymBadge] = [
        // MARK: Kanto Badges
        GymBadge(
            id: "kanto-boulder",
            name: "Boulder",
            region: .kanto,
            gymLeader: "Brock",
            city: "Pewter City",
            type: .rock,
            badgeNumber: 1,
            tmReward: "TM34 (Bide)",
            levelCap: 20,
            description: "Proof of victory at Pewter City Gym. Boosts Attack and allows use of Flash outside battle."
        ),
        GymBadge(
            id: "kanto-cascade",
            name: "Cascade",
            region: .kanto,
            gymLeader: "Misty",
            city: "Cerulean City",
            type: .water,
            badgeNumber: 2,
            tmReward: "TM11 (BubbleBeam)",
            levelCap: 30,
            description: "Proof of victory at Cerulean City Gym. Enables use of Cut outside battle."
        ),
        GymBadge(
            id: "kanto-thunder",
            name: "Thunder",
            region: .kanto,
            gymLeader: "Lt. Surge",
            city: "Vermilion City",
            type: .electric,
            badgeNumber: 3,
            tmReward: "TM24 (Thunderbolt)",
            levelCap: 40,
            description: "Proof of victory at Vermilion City Gym. Boosts Speed and enables Fly outside battle."
        ),
        GymBadge(
            id: "kanto-rainbow",
            name: "Rainbow",
            region: .kanto,
            gymLeader: "Erika",
            city: "Celadon City",
            type: .grass,
            badgeNumber: 4,
            tmReward: "TM21 (Mega Drain)",
            levelCap: 50,
            description: "Proof of victory at Celadon City Gym. Enables use of Strength outside battle."
        ),
        GymBadge(
            id: "kanto-soul",
            name: "Soul",
            region: .kanto,
            gymLeader: "Koga",
            city: "Fuchsia City",
            type: .poison,
            badgeNumber: 5,
            tmReward: "TM06 (Toxic)",
            levelCap: 60,
            description: "Proof of victory at Fuchsia City Gym. Boosts Defense and enables Surf outside battle."
        ),
        GymBadge(
            id: "kanto-marsh",
            name: "Marsh",
            region: .kanto,
            gymLeader: "Sabrina",
            city: "Saffron City",
            type: .psychic,
            badgeNumber: 6,
            tmReward: "TM46 (Psywave)",
            levelCap: 70,
            description: "Proof of victory at Saffron City Gym. Enables use of Rock Smash outside battle."
        ),
        GymBadge(
            id: "kanto-volcano",
            name: "Volcano",
            region: .kanto,
            gymLeader: "Blaine",
            city: "Cinnabar Island",
            type: .fire,
            badgeNumber: 7,
            tmReward: "TM38 (Fire Blast)",
            levelCap: 80,
            description: "Proof of victory at Cinnabar Island Gym. Boosts Special stats."
        ),
        GymBadge(
            id: "kanto-earth",
            name: "Earth",
            region: .kanto,
            gymLeader: "Giovanni",
            city: "Viridian City",
            type: .ground,
            badgeNumber: 8,
            tmReward: "TM27 (Fissure)",
            levelCap: 100,
            description: "Proof of victory at Viridian City Gym. All Pokémon obey regardless of level."
        ),
        
        // MARK: Johto Badges
        GymBadge(
            id: "johto-zephyr",
            name: "Zephyr",
            region: .johto,
            gymLeader: "Falkner",
            city: "Violet City",
            type: .flying,
            badgeNumber: 1,
            tmReward: "TM51 (Roost)",
            levelCap: 20,
            description: "Proof of victory at Violet City Gym. Boosts Attack and enables Rock Smash."
        ),
        GymBadge(
            id: "johto-hive",
            name: "Hive",
            region: .johto,
            gymLeader: "Bugsy",
            city: "Azalea Town",
            type: .bug,
            badgeNumber: 2,
            tmReward: "TM89 (U-turn)",
            levelCap: 30,
            description: "Proof of victory at Azalea Town Gym. Enables use of Cut outside battle."
        ),
        GymBadge(
            id: "johto-plain",
            name: "Plain",
            region: .johto,
            gymLeader: "Whitney",
            city: "Goldenrod City",
            type: .normal,
            badgeNumber: 3,
            tmReward: "TM45 (Attract)",
            levelCap: 40,
            description: "Proof of victory at Goldenrod City Gym. Boosts Speed and enables Strength."
        ),
        GymBadge(
            id: "johto-fog",
            name: "Fog",
            region: .johto,
            gymLeader: "Morty",
            city: "Ecruteak City",
            type: .ghost,
            badgeNumber: 4,
            tmReward: "TM30 (Shadow Ball)",
            levelCap: 50,
            description: "Proof of victory at Ecruteak City Gym. Enables use of Surf outside battle."
        ),
        GymBadge(
            id: "johto-storm",
            name: "Storm",
            region: .johto,
            gymLeader: "Chuck",
            city: "Cianwood City",
            type: .fighting,
            badgeNumber: 5,
            tmReward: "TM01 (Focus Punch)",
            levelCap: 60,
            description: "Proof of victory at Cianwood City Gym. Enables use of Fly outside battle."
        ),
        GymBadge(
            id: "johto-mineral",
            name: "Mineral",
            region: .johto,
            gymLeader: "Jasmine",
            city: "Olivine City",
            type: .steel,
            badgeNumber: 6,
            tmReward: "TM23 (Iron Tail)",
            levelCap: 70,
            description: "Proof of victory at Olivine City Gym. Boosts Defense."
        ),
        GymBadge(
            id: "johto-glacier",
            name: "Glacier",
            region: .johto,
            gymLeader: "Pryce",
            city: "Mahogany Town",
            type: .ice,
            badgeNumber: 7,
            tmReward: "TM07 (Hail)",
            levelCap: 80,
            description: "Proof of victory at Mahogany Town Gym. Boosts Special stats and enables Whirlpool."
        ),
        GymBadge(
            id: "johto-rising",
            name: "Rising",
            region: .johto,
            gymLeader: "Clair",
            city: "Blackthorn City",
            type: .dragon,
            badgeNumber: 8,
            tmReward: "TM59 (Dragon Pulse)",
            levelCap: 100,
            description: "Proof of victory at Blackthorn City Gym. All Pokémon obey and enables Waterfall."
        ),
        
        // MARK: Hoenn Badges
        GymBadge(
            id: "hoenn-stone",
            name: "Stone",
            region: .hoenn,
            gymLeader: "Roxanne",
            city: "Rustboro City",
            type: .rock,
            badgeNumber: 1,
            tmReward: "TM39 (Rock Tomb)",
            levelCap: 20,
            description: "Proof of victory at Rustboro City Gym. Boosts Attack and enables Cut."
        ),
        GymBadge(
            id: "hoenn-knuckle",
            name: "Knuckle",
            region: .hoenn,
            gymLeader: "Brawly",
            city: "Dewford Town",
            type: .fighting,
            badgeNumber: 2,
            tmReward: "TM08 (Bulk Up)",
            levelCap: 30,
            description: "Proof of victory at Dewford Town Gym. Enables use of Flash outside battle."
        ),
        GymBadge(
            id: "hoenn-dynamo",
            name: "Dynamo",
            region: .hoenn,
            gymLeader: "Wattson",
            city: "Mauville City",
            type: .electric,
            badgeNumber: 3,
            tmReward: "TM34 (Shock Wave)",
            levelCap: 40,
            description: "Proof of victory at Mauville City Gym. Boosts Speed and enables Rock Smash."
        ),
        GymBadge(
            id: "hoenn-heat",
            name: "Heat",
            region: .hoenn,
            gymLeader: "Flannery",
            city: "Lavaridge Town",
            type: .fire,
            badgeNumber: 4,
            tmReward: "TM50 (Overheat)",
            levelCap: 50,
            description: "Proof of victory at Lavaridge Town Gym. Boosts Defense and enables Strength."
        ),
        GymBadge(
            id: "hoenn-balance",
            name: "Balance",
            region: .hoenn,
            gymLeader: "Norman",
            city: "Petalburg City",
            type: .normal,
            badgeNumber: 5,
            tmReward: "TM42 (Facade)",
            levelCap: 60,
            description: "Proof of victory at Petalburg City Gym. Enables use of Surf outside battle."
        ),
        GymBadge(
            id: "hoenn-feather",
            name: "Feather",
            region: .hoenn,
            gymLeader: "Winona",
            city: "Fortree City",
            type: .flying,
            badgeNumber: 6,
            tmReward: "TM40 (Aerial Ace)",
            levelCap: 70,
            description: "Proof of victory at Fortree City Gym. Enables use of Fly outside battle."
        ),
        GymBadge(
            id: "hoenn-mind",
            name: "Mind",
            region: .hoenn,
            gymLeader: "Tate & Liza",
            city: "Mossdeep City",
            type: .psychic,
            badgeNumber: 7,
            tmReward: "TM04 (Calm Mind)",
            levelCap: 80,
            description: "Proof of victory at Mossdeep City Gym. Boosts Sp. Attack and Sp. Defense, enables Dive."
        ),
        GymBadge(
            id: "hoenn-rain",
            name: "Rain",
            region: .hoenn,
            gymLeader: "Wallace/Juan",
            city: "Sootopolis City",
            type: .water,
            badgeNumber: 8,
            tmReward: "TM03 (Water Pulse)",
            levelCap: 100,
            description: "Proof of victory at Sootopolis City Gym. All Pokémon obey and enables Waterfall."
        ),
        
        // MARK: Sinnoh Badges
        GymBadge(
            id: "sinnoh-coal",
            name: "Coal",
            region: .sinnoh,
            gymLeader: "Roark",
            city: "Oreburgh City",
            type: .rock,
            badgeNumber: 1,
            tmReward: "TM76 (Stealth Rock)",
            levelCap: 20,
            description: "Proof of victory at Oreburgh City Gym. Enables use of Rock Smash outside battle."
        ),
        GymBadge(
            id: "sinnoh-forest",
            name: "Forest",
            region: .sinnoh,
            gymLeader: "Gardenia",
            city: "Eterna City",
            type: .grass,
            badgeNumber: 2,
            tmReward: "TM86 (Grass Knot)",
            levelCap: 30,
            description: "Proof of victory at Eterna City Gym. Enables use of Cut outside battle."
        ),
        GymBadge(
            id: "sinnoh-cobble",
            name: "Cobble",
            region: .sinnoh,
            gymLeader: "Maylene",
            city: "Veilstone City",
            type: .fighting,
            badgeNumber: 3,
            tmReward: "TM60 (Drain Punch)",
            levelCap: 40,
            description: "Proof of victory at Veilstone City Gym. Enables use of Fly outside battle."
        ),
        GymBadge(
            id: "sinnoh-fen",
            name: "Fen",
            region: .sinnoh,
            gymLeader: "Crasher Wake",
            city: "Pastoria City",
            type: .water,
            badgeNumber: 4,
            tmReward: "TM55 (Brine)",
            levelCap: 50,
            description: "Proof of victory at Pastoria City Gym. Enables use of Defog outside battle."
        ),
        GymBadge(
            id: "sinnoh-relic",
            name: "Relic",
            region: .sinnoh,
            gymLeader: "Fantina",
            city: "Hearthome City",
            type: .ghost,
            badgeNumber: 5,
            tmReward: "TM65 (Shadow Claw)",
            levelCap: 60,
            description: "Proof of victory at Hearthome City Gym. Enables use of Surf outside battle."
        ),
        GymBadge(
            id: "sinnoh-mine",
            name: "Mine",
            region: .sinnoh,
            gymLeader: "Byron",
            city: "Canalave City",
            type: .steel,
            badgeNumber: 6,
            tmReward: "TM91 (Flash Cannon)",
            levelCap: 70,
            description: "Proof of victory at Canalave City Gym. Enables use of Strength outside battle."
        ),
        GymBadge(
            id: "sinnoh-icicle",
            name: "Icicle",
            region: .sinnoh,
            gymLeader: "Candice",
            city: "Snowpoint City",
            type: .ice,
            badgeNumber: 7,
            tmReward: "TM72 (Avalanche)",
            levelCap: 80,
            description: "Proof of victory at Snowpoint City Gym. Enables use of Rock Climb outside battle."
        ),
        GymBadge(
            id: "sinnoh-beacon",
            name: "Beacon",
            region: .sinnoh,
            gymLeader: "Volkner",
            city: "Sunyshore City",
            type: .electric,
            badgeNumber: 8,
            tmReward: "TM57 (Charge Beam)",
            levelCap: 100,
            description: "Proof of victory at Sunyshore City Gym. All Pokémon obey and enables Waterfall."
        ),
        
        // MARK: Unova Badges
        GymBadge(
            id: "unova-trio",
            name: "Trio",
            region: .unova,
            gymLeader: "Cilan/Chili/Cress",
            city: "Striaton City",
            type: .grass,
            badgeNumber: 1,
            tmReward: "TM83 (Work Up)",
            levelCap: 20,
            description: "Proof of victory at Striaton City Gym. Enables use of Cut outside battle."
        ),
        GymBadge(
            id: "unova-basic",
            name: "Basic",
            region: .unova,
            gymLeader: "Lenora/Cheren",
            city: "Nacrene City/Aspertia City",
            type: .normal,
            badgeNumber: 2,
            tmReward: "TM67 (Retaliate)",
            levelCap: 30,
            description: "Proof of victory at Nacrene/Aspertia City Gym. Boosts Speed."
        ),
        GymBadge(
            id: "unova-insect",
            name: "Insect",
            region: .unova,
            gymLeader: "Burgh",
            city: "Castelia City",
            type: .bug,
            badgeNumber: 3,
            tmReward: "TM76 (Struggle Bug)",
            levelCap: 40,
            description: "Proof of victory at Castelia City Gym. Boosts Attack."
        ),
        GymBadge(
            id: "unova-bolt",
            name: "Bolt",
            region: .unova,
            gymLeader: "Elesa",
            city: "Nimbasa City",
            type: .electric,
            badgeNumber: 4,
            tmReward: "TM72 (Volt Switch)",
            levelCap: 50,
            description: "Proof of victory at Nimbasa City Gym. Enables use of Strength outside battle."
        ),
        GymBadge(
            id: "unova-quake",
            name: "Quake",
            region: .unova,
            gymLeader: "Clay",
            city: "Driftveil City",
            type: .ground,
            badgeNumber: 5,
            tmReward: "TM78 (Bulldoze)",
            levelCap: 60,
            description: "Proof of victory at Driftveil City Gym. Enables use of Fly outside battle."
        ),
        GymBadge(
            id: "unova-jet",
            name: "Jet",
            region: .unova,
            gymLeader: "Skyla",
            city: "Mistralton City",
            type: .flying,
            badgeNumber: 6,
            tmReward: "TM62 (Acrobatics)",
            levelCap: 70,
            description: "Proof of victory at Mistralton City Gym. Enables use of Surf outside battle."
        ),
        GymBadge(
            id: "unova-freeze",
            name: "Freeze",
            region: .unova,
            gymLeader: "Brycen",
            city: "Icirrus City",
            type: .ice,
            badgeNumber: 7,
            tmReward: "TM79 (Frost Breath)",
            levelCap: 80,
            description: "Proof of victory at Icirrus City Gym. Boosts Special stats."
        ),
        GymBadge(
            id: "unova-legend",
            name: "Legend",
            region: .unova,
            gymLeader: "Drayden/Iris",
            city: "Opelucid City",
            type: .dragon,
            badgeNumber: 8,
            tmReward: "TM82 (Dragon Tail)",
            levelCap: 100,
            description: "Proof of victory at Opelucid City Gym. All Pokémon obey regardless of level."
        ),
        
        // MARK: Kalos Badges
        GymBadge(
            id: "kalos-bug",
            name: "Bug",
            region: .kalos,
            gymLeader: "Viola",
            city: "Santalune City",
            type: .bug,
            badgeNumber: 1,
            tmReward: "TM83 (Infestation)",
            levelCap: 30,
            description: "Proof of victory at Santalune City Gym. Pokémon up to Lv. 30 obey."
        ),
        GymBadge(
            id: "kalos-cliff",
            name: "Cliff",
            region: .kalos,
            gymLeader: "Grant",
            city: "Cyllage City",
            type: .rock,
            badgeNumber: 2,
            tmReward: "TM39 (Rock Tomb)",
            levelCap: 40,
            description: "Proof of victory at Cyllage City Gym. Enables use of Strength."
        ),
        GymBadge(
            id: "kalos-rumble",
            name: "Rumble",
            region: .kalos,
            gymLeader: "Korrina",
            city: "Shalour City",
            type: .fighting,
            badgeNumber: 3,
            tmReward: "TM98 (Power-Up Punch)",
            levelCap: 50,
            description: "Proof of victory at Shalour City Gym. Enables use of Surf and Mega Evolution."
        ),
        GymBadge(
            id: "kalos-plant",
            name: "Plant",
            region: .kalos,
            gymLeader: "Ramos",
            city: "Coumarine City",
            type: .grass,
            badgeNumber: 4,
            tmReward: "TM86 (Grass Knot)",
            levelCap: 60,
            description: "Proof of victory at Coumarine City Gym. Enables use of Fly."
        ),
        GymBadge(
            id: "kalos-voltage",
            name: "Voltage",
            region: .kalos,
            gymLeader: "Clemont",
            city: "Lumiose City",
            type: .electric,
            badgeNumber: 5,
            tmReward: "TM24 (Thunderbolt)",
            levelCap: 70,
            description: "Proof of victory at Lumiose City Gym. Boosts Speed."
        ),
        GymBadge(
            id: "kalos-fairy",
            name: "Fairy",
            region: .kalos,
            gymLeader: "Valerie",
            city: "Laverre City",
            type: .fairy,
            badgeNumber: 6,
            tmReward: "TM99 (Dazzling Gleam)",
            levelCap: 80,
            description: "Proof of victory at Laverre City Gym. First Fairy-type Gym Badge."
        ),
        GymBadge(
            id: "kalos-psychic",
            name: "Psychic",
            region: .kalos,
            gymLeader: "Olympia",
            city: "Anistar City",
            type: .psychic,
            badgeNumber: 7,
            tmReward: "TM04 (Calm Mind)",
            levelCap: 90,
            description: "Proof of victory at Anistar City Gym. Boosts Special Defense."
        ),
        GymBadge(
            id: "kalos-iceberg",
            name: "Iceberg",
            region: .kalos,
            gymLeader: "Wulfric",
            city: "Snowbelle City",
            type: .ice,
            badgeNumber: 8,
            tmReward: "TM13 (Ice Beam)",
            levelCap: 100,
            description: "Proof of victory at Snowbelle City Gym. All Pokémon obey and enables Waterfall."
        ),
        
        // MARK: Galar Badges
        GymBadge(
            id: "galar-grass",
            name: "Grass",
            region: .galar,
            gymLeader: "Milo",
            city: "Turffield",
            type: .grass,
            badgeNumber: 1,
            tmReward: "TM10 (Magical Leaf)",
            levelCap: 25,
            description: "Proof of victory at Turffield Stadium. Allows catching Pokémon up to Lv. 25."
        ),
        GymBadge(
            id: "galar-water",
            name: "Water",
            region: .galar,
            gymLeader: "Nessa",
            city: "Hulbury",
            type: .water,
            badgeNumber: 2,
            tmReward: "TM36 (Whirlpool)",
            levelCap: 30,
            description: "Proof of victory at Hulbury Stadium. Allows catching Pokémon up to Lv. 30."
        ),
        GymBadge(
            id: "galar-fire",
            name: "Fire",
            region: .galar,
            gymLeader: "Kabu",
            city: "Motostoke",
            type: .fire,
            badgeNumber: 3,
            tmReward: "TM38 (Will-O-Wisp)",
            levelCap: 35,
            description: "Proof of victory at Motostoke Stadium. Allows catching Pokémon up to Lv. 35."
        ),
        GymBadge(
            id: "galar-fighting",
            name: "Fighting",
            region: .galar,
            gymLeader: "Bea/Allister",
            city: "Stow-on-Side",
            type: .fighting,
            badgeNumber: 4,
            tmReward: "TM42 (Revenge) / TM77 (Hex)",
            levelCap: 40,
            description: "Proof of victory at Stow-on-Side Stadium. Version exclusive Gym."
        ),
        GymBadge(
            id: "galar-fairy",
            name: "Fairy",
            region: .galar,
            gymLeader: "Opal",
            city: "Ballonlea",
            type: .fairy,
            badgeNumber: 5,
            tmReward: "TM87 (Draining Kiss)",
            levelCap: 45,
            description: "Proof of victory at Ballonlea Stadium. Quiz-based Gym challenge."
        ),
        GymBadge(
            id: "galar-rock",
            name: "Rock",
            region: .galar,
            gymLeader: "Gordie/Melony",
            city: "Circhester",
            type: .rock,
            badgeNumber: 6,
            tmReward: "TM48 (Rock Tomb) / TM27 (Icy Wind)",
            levelCap: 50,
            description: "Proof of victory at Circhester Stadium. Version exclusive Gym."
        ),
        GymBadge(
            id: "galar-dark",
            name: "Dark",
            region: .galar,
            gymLeader: "Piers",
            city: "Spikemuth",
            type: .dark,
            badgeNumber: 7,
            tmReward: "TM85 (Snarl)",
            levelCap: 55,
            description: "Proof of victory at Spikemuth. Only Gym without Dynamax."
        ),
        GymBadge(
            id: "galar-dragon",
            name: "Dragon",
            region: .galar,
            gymLeader: "Raihan",
            city: "Hammerlocke",
            type: .dragon,
            badgeNumber: 8,
            tmReward: "TM99 (Breaking Swipe)",
            levelCap: 100,
            description: "Proof of victory at Hammerlocke Stadium. Uses weather strategies."
        ),
        
        // MARK: Paldea Badges
        GymBadge(
            id: "paldea-bug",
            name: "Bug",
            region: .paldea,
            gymLeader: "Katy",
            city: "Cortondo",
            type: .bug,
            badgeNumber: 1,
            tmReward: "TM021 (Pounce)",
            levelCap: 25,
            description: "Proof of victory at Cortondo Gym. Sweet dessert-themed Gym test."
        ),
        GymBadge(
            id: "paldea-grass",
            name: "Grass",
            region: .paldea,
            gymLeader: "Brassius",
            city: "Artazon",
            type: .grass,
            badgeNumber: 2,
            tmReward: "TM020 (Trailblaze)",
            levelCap: 30,
            description: "Proof of victory at Artazon Gym. Sunflora hide-and-seek test."
        ),
        GymBadge(
            id: "paldea-electric",
            name: "Electric",
            region: .paldea,
            gymLeader: "Iono",
            city: "Levincia",
            type: .electric,
            badgeNumber: 3,
            tmReward: "TM048 (Volt Switch)",
            levelCap: 35,
            description: "Proof of victory at Levincia Gym. Streaming personality Gym Leader."
        ),
        GymBadge(
            id: "paldea-water",
            name: "Water",
            region: .paldea,
            gymLeader: "Kofu",
            city: "Cascarrafa",
            type: .water,
            badgeNumber: 4,
            tmReward: "TM022 (Chilling Water)",
            levelCap: 40,
            description: "Proof of victory at Cascarrafa Gym. Auction house test."
        ),
        GymBadge(
            id: "paldea-normal",
            name: "Normal",
            region: .paldea,
            gymLeader: "Larry",
            city: "Medali",
            type: .normal,
            badgeNumber: 5,
            tmReward: "TM025 (Facade)",
            levelCap: 45,
            description: "Proof of victory at Medali Gym. Secret menu order test."
        ),
        GymBadge(
            id: "paldea-ghost",
            name: "Ghost",
            region: .paldea,
            gymLeader: "Ryme",
            city: "Montenevera",
            type: .ghost,
            badgeNumber: 6,
            tmReward: "TM114 (Shadow Ball)",
            levelCap: 50,
            description: "Proof of victory at Montenevera Gym. Double battle rap battles."
        ),
        GymBadge(
            id: "paldea-psychic",
            name: "Psychic",
            region: .paldea,
            gymLeader: "Tulip",
            city: "Alfornada",
            type: .psychic,
            badgeNumber: 7,
            tmReward: "TM120 (Psychic)",
            levelCap: 55,
            description: "Proof of victory at Alfornada Gym. ESP training test."
        ),
        GymBadge(
            id: "paldea-ice",
            name: "Ice",
            region: .paldea,
            gymLeader: "Grusha",
            city: "Glaseado",
            type: .ice,
            badgeNumber: 8,
            tmReward: "TM124 (Ice Spinner)",
            levelCap: 100,
            description: "Proof of victory at Glaseado Gym. Snow slope race test."
        )
    ]
    
    static func getBadgesByRegion(_ region: GymBadge.Region) -> [GymBadge] {
        allBadges.filter { $0.region == region }.sorted { $0.badgeNumber < $1.badgeNumber }
    }
    
    static func getBadge(id: String) -> GymBadge? {
        allBadges.first { $0.id == id }
    }
    
    static func getProgressForRegion(_ region: GymBadge.Region, earnedBadges: Set<String>) -> Double {
        let regionBadges = getBadgesByRegion(region)
        let earnedCount = regionBadges.filter { earnedBadges.contains($0.id) }.count
        return Double(earnedCount) / Double(regionBadges.count)
    }
}