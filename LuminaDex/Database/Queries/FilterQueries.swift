//
//  FilterQueries.swift
//  LuminaDex
//
//  Day 24: GRDB filter queries for comprehensive filtering
//

import Foundation
import GRDB

// MARK: - Filter Criteria
struct FilterCriteria: Codable, Equatable {
    var types: Set<PokemonType> = []
    var typeLogic: TypeFilterLogic = .or
    var generations: Set<Int> = []
    var minStats: [String: Int] = [:]
    var maxStats: [String: Int] = [:]
    var minHeight: Double?
    var maxHeight: Double?
    var minWeight: Double?
    var maxWeight: Double?
    var isLegendary: Bool?
    var isMythical: Bool?
    var isBaby: Bool?
    var abilities: Set<String> = []
    var searchText: String = ""
    
    enum TypeFilterLogic: String, Codable, CaseIterable, Equatable {
        case or = "Any Type"
        case and = "All Types"
    }
}

// MARK: - Filter Queries Extension
extension DatabaseManager {
    
    /// Apply comprehensive filters to Pokemon query
    func fetchFilteredPokemon(criteria: FilterCriteria) async throws -> [Pokemon] {
        return try await dbQueue.read { db -> [Pokemon] in
            var query = PokemonRecord.all()
            
            // Apply search text filter
            if !criteria.searchText.isEmpty {
                let searchQuery = "'\(criteria.searchText)*'"
                let searchResults = try PokemonRecord.fetchAll(db, sql: """
                    SELECT pokemon.* FROM pokemon 
                    JOIN pokemon_fts ON pokemon.id = pokemon_fts.rowid 
                    WHERE pokemon_fts MATCH ?
                """, arguments: [searchQuery])
                
                let searchIds = searchResults.map { $0.id }
                query = query.filter(searchIds.contains(Column("id")))
            }
            
            // Apply type filters
            if !criteria.types.isEmpty {
                let typeIds = criteria.types.map { type in
                    // Map type to database ID
                    switch type {
                    case .normal: return 1
                    case .fighting: return 2
                    case .flying: return 3
                    case .poison: return 4
                    case .ground: return 5
                    case .rock: return 6
                    case .bug: return 7
                    case .ghost: return 8
                    case .steel: return 9
                    case .fire: return 10
                    case .water: return 11
                    case .grass: return 12
                    case .electric: return 13
                    case .psychic: return 14
                    case .ice: return 15
                    case .dragon: return 16
                    case .dark: return 17
                    case .fairy: return 18
                    case .unknown: return 10001
                    }
                }
                
                if criteria.typeLogic == .and {
                    // Pokemon must have ALL selected types
                    for typeId in typeIds {
                        let pokemonIds = try Int.fetchAll(db, sql: """
                            SELECT pokemon_id FROM pokemon_types WHERE type_id = ?
                        """, arguments: [typeId])
                        query = query.filter(pokemonIds.contains(Column("id")))
                    }
                } else {
                    // Pokemon must have ANY selected type
                    let pokemonIds = try Int.fetchAll(db, sql: """
                        SELECT DISTINCT pokemon_id FROM pokemon_types 
                        WHERE type_id IN (\(typeIds.map { "\($0)" }.joined(separator: ",")))
                    """)
                    query = query.filter(pokemonIds.contains(Column("id")))
                }
            }
            
            // Apply generation filter
            if !criteria.generations.isEmpty {
                query = query.filter(criteria.generations.contains(Column("generation")))
            }
            
            // Apply stat filters
            for (statName, minValue) in criteria.minStats {
                let pokemonIds = try Int.fetchAll(db, sql: """
                    SELECT pokemon_id FROM pokemon_stats 
                    WHERE stat_name = ? AND base_stat >= ?
                """, arguments: [statName, minValue])
                query = query.filter(pokemonIds.contains(Column("id")))
            }
            
            for (statName, maxValue) in criteria.maxStats {
                let pokemonIds = try Int.fetchAll(db, sql: """
                    SELECT pokemon_id FROM pokemon_stats 
                    WHERE stat_name = ? AND base_stat <= ?
                """, arguments: [statName, maxValue])
                query = query.filter(pokemonIds.contains(Column("id")))
            }
            
            // Apply height/weight filters
            if let minHeight = criteria.minHeight {
                query = query.filter(Column("height") >= minHeight * 10) // Convert to decimeters
            }
            if let maxHeight = criteria.maxHeight {
                query = query.filter(Column("height") <= maxHeight * 10)
            }
            if let minWeight = criteria.minWeight {
                query = query.filter(Column("weight") >= minWeight * 10) // Convert to hectograms
            }
            if let maxWeight = criteria.maxWeight {
                query = query.filter(Column("weight") <= maxWeight * 10)
            }
            
            // Apply legendary/mythical filters
            if let isLegendary = criteria.isLegendary {
                query = query.filter(Column("is_legendary") == isLegendary)
            }
            if let isMythical = criteria.isMythical {
                query = query.filter(Column("is_mythical") == isMythical)
            }
            if let isBaby = criteria.isBaby {
                query = query.filter(Column("is_baby") == isBaby)
            }
            
            // Apply ability filter
            if !criteria.abilities.isEmpty {
                let abilityIds = try Int.fetchAll(db, sql: """
                    SELECT id FROM abilities 
                    WHERE name IN (\(criteria.abilities.map { "'\($0)'" }.joined(separator: ",")))
                """)
                
                let pokemonIds = try Int.fetchAll(db, sql: """
                    SELECT DISTINCT pokemon_id FROM pokemon_abilities 
                    WHERE ability_id IN (\(abilityIds.map { "\($0)" }.joined(separator: ",")))
                """)
                query = query.filter(pokemonIds.contains(Column("id")))
            }
            
            // Fetch Pokemon records
            let records = try query.fetchAll(db)
            
            // Convert to Pokemon models inline (not async)
            return try records.map { record in
                // Fetch related data
                let types = try PokemonTypeRecord.filter(Column("pokemon_id") == record.id).fetchAll(db)
                let stats = try PokemonStatRecord.filter(Column("pokemon_id") == record.id).fetchAll(db)
                let sprites = try PokemonSpriteRecord.fetchOne(db, key: record.id)
                
                // Convert to Pokemon model
                return Pokemon(
                    id: record.id,
                    name: record.name,
                    height: record.height,
                    weight: record.weight,
                    baseExperience: record.baseExperience,
                    order: record.orderIndex,
                    isDefault: record.isDefault,
                    sprites: PokemonSprites(
                        frontDefault: sprites?.frontDefault,
                        frontShiny: sprites?.frontShiny,
                        frontFemale: sprites?.frontFemale,
                        frontShinyFemale: sprites?.frontShinyFemale,
                        backDefault: sprites?.backDefault,
                        backShiny: sprites?.backShiny,
                        backFemale: sprites?.backFemale,
                        backShinyFemale: sprites?.backShinyFemale,
                        other: nil
                    ),
                    types: types.compactMap { typeRecord in
                        // Convert typeId to PokemonType
                        let typeName: String
                        switch typeRecord.typeId {
                        case 1: typeName = "normal"
                        case 2: typeName = "fighting"
                        case 3: typeName = "flying"
                        case 4: typeName = "poison"
                        case 5: typeName = "ground"
                        case 6: typeName = "rock"
                        case 7: typeName = "bug"
                        case 8: typeName = "ghost"
                        case 9: typeName = "steel"
                        case 10: typeName = "fire"
                        case 11: typeName = "water"
                        case 12: typeName = "grass"
                        case 13: typeName = "electric"
                        case 14: typeName = "psychic"
                        case 15: typeName = "ice"
                        case 16: typeName = "dragon"
                        case 17: typeName = "dark"
                        case 18: typeName = "fairy"
                        default: typeName = "normal"
                        }
                        
                        return PokemonTypeSlot(
                            slot: typeRecord.slot,
                            type: PokemonTypeInfo(
                                name: typeName,
                                url: ""
                            )
                        )
                    },
                    abilities: [],
                    stats: stats.map { statRecord in
                        PokemonStat(
                            baseStat: statRecord.baseStat,
                            effort: statRecord.effort,
                            stat: StatType(
                                name: statRecord.statName,
                                url: ""
                            )
                        )
                    },
                    species: PokemonSpecies(name: record.name, url: ""),
                    moves: nil,
                    gameIndices: nil
                )
            }
        }
    }
    
    /// Get count of Pokemon matching criteria
    func countFilteredPokemon(criteria: FilterCriteria) async throws -> Int {
        // Similar logic but just return count
        let pokemon = try await fetchFilteredPokemon(criteria: criteria)
        return pokemon.count
    }
    
    /// Get available filter options based on current selection
    func getAvailableFilterOptions(currentCriteria: FilterCriteria) async throws -> FilterOptions {
        return try await dbQueue.read { db in
            // Get available types
            let types = try PokemonType.allCases
            
            // Get available generations
            let generations = try Int.fetchAll(db, sql: """
                SELECT DISTINCT generation FROM pokemon 
                WHERE generation IS NOT NULL 
                ORDER BY generation
            """)
            
            // Get stat ranges
            let stats = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]
            var statRanges: [String: (min: Int, max: Int)] = [:]
            
            for stat in stats {
                let minMax = try Row.fetchOne(db, sql: """
                    SELECT MIN(base_stat) as min, MAX(base_stat) as max 
                    FROM pokemon_stats WHERE stat_name = ?
                """, arguments: [stat])
                
                if let min = minMax?["min"] as? Int, let max = minMax?["max"] as? Int {
                    statRanges[stat] = (min, max)
                }
            }
            
            // Get abilities
            let abilities = try String.fetchAll(db, sql: """
                SELECT DISTINCT name FROM abilities ORDER BY name
            """)
            
            return FilterOptions(
                availableTypes: types,
                availableGenerations: generations,
                statRanges: statRanges,
                availableAbilities: abilities
            )
        }
    }
}

// MARK: - Filter Options
struct FilterOptions {
    let availableTypes: [PokemonType]
    let availableGenerations: [Int]
    let statRanges: [String: (min: Int, max: Int)]
    let availableAbilities: [String]
}