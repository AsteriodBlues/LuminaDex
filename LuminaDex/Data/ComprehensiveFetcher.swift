//
//  ComprehensiveFetcher.swift
//  LuminaDex
//
//  Comprehensive API fetcher for all Pokemon data
//

import Foundation
import SwiftUI

// MARK: - Comprehensive Pokemon Fetcher
@MainActor
class ComprehensiveFetcher: ObservableObject {
    static let shared = ComprehensiveFetcher()
    
    @Published var isLoading = false
    @Published var loadingMessage = ""
    @Published var loadingProgress: Double = 0
    
    // MARK: - Fetch Complete Pokemon Data
    func fetchCompletePokemonData(for pokemonId: Int) async -> CompletePokemonData? {
        do {
            async let basicData = fetchPokemonBasicData(id: pokemonId)
            async let speciesData = fetchPokemonSpeciesData(id: pokemonId) 
            async let abilities = fetchPokemonAbilities(id: pokemonId)
            async let moves = fetchPokemonMoves(id: pokemonId)
            
            let (basic, species, abilitiesData, movesData) = await (basicData, speciesData, abilities, moves)
            
            guard let basic = basic, let species = species else { return nil }
            
            return CompletePokemonData(
                basic: basic,
                species: species,
                abilities: abilitiesData,
                moves: movesData,
                items: [],
                evYield: calculateEVYield(from: basic),
                nature: nil // Will be set by user
            )
        } catch {
            print("Error fetching complete Pokemon data: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Pokemon Basic Data
    private func fetchPokemonBasicData(id: Int) async -> PokemonBasicData? {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(id)"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            return try decoder.decode(PokemonBasicData.self, from: data)
        } catch {
            print("Error fetching Pokemon basic data: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Pokemon Species Data
    private func fetchPokemonSpeciesData(id: Int) async -> PokemonSpeciesData? {
        let urlString = "https://pokeapi.co/api/v2/pokemon-species/\(id)"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            return try decoder.decode(PokemonSpeciesData.self, from: data)
        } catch {
            print("Error fetching Pokemon species data: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Pokemon Abilities
    private func fetchPokemonAbilities(id: Int) async -> [PokemonAbilitySlot] {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(id)"
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let abilitiesArray = json["abilities"] as? [[String: Any]] {
                
                var abilities: [PokemonAbilitySlot] = []
                
                for abilityDict in abilitiesArray {
                    if let abilityInfo = abilityDict["ability"] as? [String: Any],
                       let name = abilityInfo["name"] as? String,
                       let url = abilityInfo["url"] as? String,
                       let isHidden = abilityDict["is_hidden"] as? Bool,
                       let slot = abilityDict["slot"] as? Int {
                        
                        let pokemonAbility = PokemonAbility(name: name, url: url)
                        let abilitySlot = PokemonAbilitySlot(
                            isHidden: isHidden,
                            slot: slot,
                            ability: pokemonAbility
                        )
                        abilities.append(abilitySlot)
                    }
                }
                
                return abilities.sorted(by: { $0.slot < $1.slot })
            }
        } catch {
            print("Error fetching abilities: \(error)")
        }
        
        return []
    }
    
    // MARK: - Fetch Pokemon Moves
    private func fetchPokemonMoves(id: Int) async -> [MoveInfo] {
        // Reuse existing move fetcher
        let fetcher = MoveDataFetcher.shared
        let moves = await fetcher.fetchPokemonMoves(for: id)
        return moves.map { MoveInfo(move: $0.move, learnMethod: $0.learnMethod, level: $0.levelLearnedAt) }
    }
    
    // MARK: - Fetch Berry
    func fetchBerry(name: String) async -> Berry? {
        let urlString = "https://pokeapi.co/api/v2/berry/\(name)"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(APIBerryResponse.self, from: data)
            
            return Berry(
                id: apiResponse.id,
                name: apiResponse.name,
                growthTime: apiResponse.growthTime,
                maxHarvest: apiResponse.maxHarvest,
                naturalGiftPower: apiResponse.naturalGiftPower,
                naturalGiftType: nil,
                size: apiResponse.size,
                smoothness: apiResponse.smoothness,
                soilDryness: apiResponse.soilDryness,
                firmness: apiResponse.firmness.name,
                flavors: BerryFlavors(
                    spicy: apiResponse.flavors.first { $0.flavor.name == "spicy" }?.potency ?? 0,
                    dry: apiResponse.flavors.first { $0.flavor.name == "dry" }?.potency ?? 0,
                    sweet: apiResponse.flavors.first { $0.flavor.name == "sweet" }?.potency ?? 0,
                    bitter: apiResponse.flavors.first { $0.flavor.name == "bitter" }?.potency ?? 0,
                    sour: apiResponse.flavors.first { $0.flavor.name == "sour" }?.potency ?? 0
                ),
                item: BerryItem(
                    name: apiResponse.item.name, 
                    effect: "Berry effect", 
                    shortEffect: "Berry",
                    cost: 0,
                    attributes: []
                )
            )
        } catch {
            print("Error fetching berry: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Item
    func fetchItem(name: String) async -> Item? {
        let urlString = "https://pokeapi.co/api/v2/item/\(name)"
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(APIItemResponse.self, from: data)
            
            let effect = apiResponse.effectEntries.first { $0.language.name == "en" }
            
            return Item(
                id: apiResponse.id,
                name: apiResponse.name,
                category: ItemCategory(rawValue: apiResponse.category.name) ?? .keyItems,
                cost: apiResponse.cost,
                flingPower: apiResponse.flingPower,
                flingEffect: apiResponse.flingEffect?.name,
                effect: effect?.effect ?? "",
                shortEffect: effect?.shortEffect ?? "",
                attributes: apiResponse.attributes.map { $0.name }
            )
        } catch {
            print("Error fetching item: \(error)")
            return nil
        }
    }
    
    // MARK: - Calculate EV Yield
    private func calculateEVYield(from data: PokemonBasicData) -> EVYield {
        // Parse EV yield from stats
        var hp = 0, attack = 0, defense = 0, spAttack = 0, spDefense = 0, speed = 0
        
        for stat in data.stats {
            let effort = stat.effort
            switch stat.stat.name {
            case "hp": hp = effort
            case "attack": attack = effort
            case "defense": defense = effort
            case "special-attack": spAttack = effort
            case "special-defense": spDefense = effort
            case "speed": speed = effort
            default: break
            }
        }
        
        return EVYield(
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: spAttack,
            specialDefense: spDefense,
            speed: speed
        )
    }
}

// MARK: - API Response Models
struct PokemonBasicData: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let stats: [StatData]
    let types: [TypeData]
    let sprites: SpritesData
    
    struct StatData: Decodable {
        let baseStat: Int
        let effort: Int
        let stat: StatReference
        
        enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case effort
            case stat
        }
    }
    
    struct StatReference: Decodable {
        let name: String
    }
    
    struct TypeData: Decodable {
        let slot: Int
        let type: TypeReference
    }
    
    struct TypeReference: Decodable {
        let name: String
    }
    
    struct SpritesData: Decodable {
        let frontDefault: String?
        let frontShiny: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
            case frontShiny = "front_shiny"
        }
    }
}

struct PokemonSpeciesData: Decodable {
    let id: Int
    let name: String
    let baseHappiness: Int?
    let captureRate: Int
    let genderRate: Int
    let hatchCounter: Int?
    let hasGenderDifferences: Bool
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool
    let eggGroups: [EggGroupData]
    let growthRate: GrowthRateData
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case baseHappiness = "base_happiness"
        case captureRate = "capture_rate"
        case genderRate = "gender_rate"
        case hatchCounter = "hatch_counter"
        case hasGenderDifferences = "has_gender_differences"
        case isBaby = "is_baby"
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
        case eggGroups = "egg_groups"
        case growthRate = "growth_rate"
    }
    
    struct EggGroupData: Decodable {
        let name: String
    }
    
    struct GrowthRateData: Decodable {
        let name: String
    }
}

struct APIBerryResponse: Decodable {
    let id: Int
    let name: String
    let growthTime: Int
    let maxHarvest: Int
    let naturalGiftPower: Int
    let size: Int
    let smoothness: Int
    let soilDryness: Int
    let firmness: FirmnessData
    let flavors: [FlavorData]
    let item: ItemData
    
    enum CodingKeys: String, CodingKey {
        case id, name, size, smoothness, firmness, flavors, item
        case growthTime = "growth_time"
        case maxHarvest = "max_harvest"
        case naturalGiftPower = "natural_gift_power"
        case soilDryness = "soil_dryness"
    }
    
    struct FirmnessData: Decodable {
        let name: String
    }
    
    struct FlavorData: Decodable {
        let potency: Int
        let flavor: FlavorReference
    }
    
    struct FlavorReference: Decodable {
        let name: String
    }
    
    struct ItemData: Decodable {
        let name: String
    }
}

struct APIItemResponse: Decodable {
    let id: Int
    let name: String
    let cost: Int
    let flingPower: Int?
    let flingEffect: FlingEffectData?
    let attributes: [AttributeData]
    let category: CategoryData
    let effectEntries: [EffectEntry]
    
    enum CodingKeys: String, CodingKey {
        case id, name, cost, attributes, category
        case flingPower = "fling_power"
        case flingEffect = "fling_effect"
        case effectEntries = "effect_entries"
    }
    
    struct FlingEffectData: Decodable {
        let name: String
    }
    
    struct AttributeData: Decodable {
        let name: String
    }
    
    struct CategoryData: Decodable {
        let name: String
    }
    
    struct EffectEntry: Decodable {
        let effect: String
        let shortEffect: String
        let language: LanguageData
        
        enum CodingKeys: String, CodingKey {
            case effect
            case shortEffect = "short_effect"
            case language
        }
    }
    
    struct LanguageData: Decodable {
        let name: String
    }
}

// MARK: - Complete Pokemon Data
struct CompletePokemonData {
    let basic: PokemonBasicData
    let species: PokemonSpeciesData
    let abilities: [PokemonAbilitySlot]
    let moves: [MoveInfo]
    let items: [HeldItem]
    let evYield: EVYield
    let nature: Nature?
    
    var breedingInfo: BreedingInfo {
        BreedingInfo(
            eggGroups: species.eggGroups.compactMap { EggGroup(rawValue: $0.name) },
            hatchCycles: species.hatchCounter ?? 0,
            babyTriggerItem: nil,
            genderRate: species.genderRate,
            hasGenderDifferences: species.hasGenderDifferences
        )
    }
}

struct MoveInfo {
    let move: Move
    let learnMethod: LearnMethodType
    let level: Int?
}