//
//  ComparisonQueries.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import Foundation
import GRDB

struct ComparisonQueries {
    
    // MARK: - Multi-Pokemon Queries
    
    /// Fetch multiple Pokemon by their IDs for comparison
    /// - Parameter ids: Array of Pokemon IDs (2-6 Pokemon)
    /// - Returns: Array of PokemonRecord sorted by the order of input IDs
    static func fetchPokemonForComparison(ids: [Int]) async throws -> [PokemonRecord] {
        guard ids.count >= 2 && ids.count <= 6 else {
            throw ComparisonError.invalidPokemonCount
        }
        
        return try await DatabaseManager.shared.dbQueue.read { db in
            let placeholders = ids.map { _ in "?" }.joined(separator: ",")
            let query = """
                SELECT * FROM pokemon 
                WHERE id IN (\(placeholders))
                ORDER BY CASE id \(ids.enumerated().map { "WHEN \($0.element) THEN \($0.offset)" }.joined(separator: " ")) END
            """
            
            let arguments = StatementArguments(ids)
            return try PokemonRecord.fetchAll(db, sql: query, arguments: arguments)
        }
    }
    
    /// Fetch Pokemon with full stats for comparison analysis
    /// - Parameter ids: Array of Pokemon IDs
    /// - Returns: Array of PokemonRecord with complete stat information
    static func fetchPokemonWithCompleteStats(ids: [Int]) async throws -> [PokemonRecord] {
        return try await DatabaseManager.shared.dbQueue.read { db in
            let placeholders = ids.map { _ in "?" }.joined(separator: ",")
            let query = """
                SELECT * FROM pokemon
                WHERE id IN (\(placeholders))
                ORDER BY CASE id \(ids.enumerated().map { "WHEN \($0.element) THEN \($0.offset)" }.joined(separator: " ")) END
            """
            
            let arguments = StatementArguments(ids)
            return try PokemonRecord.fetchAll(db, sql: query, arguments: arguments)
        }
    }
    
    // MARK: - Stat Analysis Queries
    
    /// Get stat rankings for a specific stat across all Pokemon
    /// - Parameter statName: Name of the stat (hp, attack, defense, etc.)
    /// - Returns: Array of Pokemon ranked by the specified stat
    static func getPokemonRankedByStat(statName: String, limit: Int = 10) async throws -> [PokemonStatRanking] {
        return try await DatabaseManager.shared.dbQueue.read { db in
            let query = """
                SELECT p.id, p.name, ps.base_stat, 
                       RANK() OVER (ORDER BY ps.base_stat DESC) as rank
                FROM pokemon p
                INNER JOIN pokemon_stats ps ON p.id = ps.pokemon_id
                WHERE ps.stat_name = ?
                ORDER BY ps.base_stat DESC
                LIMIT ?
            """
            
            return try PokemonStatRanking.fetchAll(db, sql: query, arguments: [statName, limit])
        }
    }
    
    /// Get the percentile ranking for a Pokemon's stat
    /// - Parameters:
    ///   - pokemonId: ID of the Pokemon
    ///   - statName: Name of the stat
    /// - Returns: Percentile ranking (0-100)
    static func getStatPercentile(pokemonId: Int, statName: String) async throws -> Double {
        return try await DatabaseManager.shared.dbQueue.read { db in
            let query = """
                SELECT ROUND(
                    (SELECT COUNT(*) FROM pokemon_stats ps2 
                     WHERE ps2.stat_name = ? AND ps2.base_stat < ps1.base_stat) * 100.0 
                    / (SELECT COUNT(*) FROM pokemon_stats ps3 WHERE ps3.stat_name = ?), 2
                ) as percentile
                FROM pokemon_stats ps1
                WHERE ps1.pokemon_id = ? AND ps1.stat_name = ?
            """
            
            return try Double.fetchOne(db, sql: query, arguments: [statName, statName, pokemonId, statName]) ?? 0.0
        }
    }
    
    // MARK: - Type Effectiveness Queries
    
    /// Calculate type effectiveness between Pokemon types
    /// - Parameters:
    ///   - attackingTypes: Array of attacking Pokemon types
    ///   - defendingTypes: Array of defending Pokemon types
    /// - Returns: Type effectiveness multiplier
    static func calculateTypeEffectiveness(attackingTypes: [String], defendingTypes: [String]) async throws -> TypeEffectivenessResult {
        return try await DatabaseManager.shared.dbQueue.read { db in
            var totalEffectiveness: Double = 1.0
            var effectivenessDetails: [String: Double] = [:]
            
            for attackingType in attackingTypes {
                for defendingType in defendingTypes {
                    let query = """
                        SELECT effectiveness FROM type_effectiveness 
                        WHERE attacking_type = ? AND defending_type = ?
                    """
                    
                    let effectiveness = try Double.fetchOne(db, sql: query, arguments: [attackingType, defendingType]) ?? 1.0
                    totalEffectiveness *= effectiveness
                    effectivenessDetails["\(attackingType) -> \(defendingType)"] = effectiveness
                }
            }
            
            return TypeEffectivenessResult(
                totalEffectiveness: totalEffectiveness,
                details: effectivenessDetails
            )
        }
    }
    
    // MARK: - Advanced Comparison Queries
    
    /// Find Pokemon similar to the given Pokemon based on stat distribution
    /// - Parameter pokemonId: ID of the reference Pokemon
    /// - Parameter limit: Maximum number of similar Pokemon to return
    /// - Returns: Array of similar Pokemon with similarity scores
    static func findSimilarPokemon(to pokemonId: Int, limit: Int = 5) async throws -> [PokemonSimilarity] {
        return try await DatabaseManager.shared.dbQueue.read { db in
            let query = """
                WITH reference_stats AS (
                    SELECT stat_name, base_stat
                    FROM pokemon_stats
                    WHERE pokemon_id = ?
                ),
                stat_differences AS (
                    SELECT 
                        ps.pokemon_id,
                        p.name,
                        SUM(ABS(ps.base_stat - rs.base_stat)) as total_difference,
                        COUNT(*) as stat_count
                    FROM pokemon_stats ps
                    INNER JOIN pokemon p ON ps.pokemon_id = p.id
                    INNER JOIN reference_stats rs ON ps.stat_name = rs.stat_name
                    WHERE ps.pokemon_id != ?
                    GROUP BY ps.pokemon_id, p.name
                )
                SELECT 
                    pokemon_id,
                    name,
                    total_difference,
                    ROUND(100.0 - (total_difference * 100.0 / 1530.0), 2) as similarity_score
                FROM stat_differences
                WHERE stat_count = 6
                ORDER BY total_difference ASC
                LIMIT ?
            """
            
            return try PokemonSimilarity.fetchAll(db, sql: query, arguments: [pokemonId, pokemonId, limit])
        }
    }
    
    /// Get comprehensive comparison data for multiple Pokemon
    /// - Parameter ids: Array of Pokemon IDs
    /// - Returns: Comprehensive comparison data
    static func getComprehensiveComparisonData(ids: [Int]) async throws -> ComparisonData {
        let pokemon = try await fetchPokemonForComparison(ids: ids)
        
        return try await DatabaseManager.shared.dbQueue.read { db in
            var statRankings: [String: [Int: Int]] = [:]
            
            // Get rankings for each stat
            for statName in ["hp", "attack", "defense", "special-attack", "special-defense", "speed"] {
                let query = """
                    SELECT pokemon_id, 
                           RANK() OVER (ORDER BY base_stat DESC) as rank
                    FROM pokemon_stats
                    WHERE stat_name = ? AND pokemon_id IN (\(ids.map { _ in "?" }.joined(separator: ",")))
                """
                
                var args: [DatabaseValueConvertible] = [statName]
                args.append(contentsOf: ids)
                let rankings = try Row.fetchAll(db, sql: query, arguments: StatementArguments(args))
                
                statRankings[statName] = [:]
                for row in rankings {
                    let pokemonId: Int = row["pokemon_id"]
                    let rank: Int = row["rank"]
                    statRankings[statName]?[pokemonId] = rank
                }
            }
            
            return ComparisonData(
                pokemon: pokemon,
                statRankings: statRankings,
                comparisonDate: Date()
            )
        }
    }
}

// MARK: - Supporting Data Models

struct PokemonStatRanking: Codable, FetchableRecord {
    let id: Int
    let name: String
    let baseStat: Int
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, rank
        case baseStat = "base_stat"
    }
}

struct TypeEffectivenessResult: Codable {
    let totalEffectiveness: Double
    let details: [String: Double]
    
    var effectivenessDescription: String {
        switch totalEffectiveness {
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

struct PokemonSimilarity: Codable, FetchableRecord {
    let pokemonId: Int
    let name: String
    let totalDifference: Int
    let similarityScore: Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case pokemonId = "pokemon_id"
        case totalDifference = "total_difference"
        case similarityScore = "similarity_score"
    }
}

struct ComparisonData: Codable {
    let pokemon: [PokemonRecord]
    let statRankings: [String: [Int: Int]]
    let comparisonDate: Date
    
    func getRank(for pokemonId: Int, stat: String) -> Int? {
        return statRankings[stat]?[pokemonId]
    }
}

// MARK: - Error Types

enum ComparisonError: Error, LocalizedError {
    case invalidPokemonCount
    case pokemonNotFound
    case databaseError
    
    var errorDescription: String? {
        switch self {
        case .invalidPokemonCount:
            return "Invalid number of Pokemon for comparison. Please select 2-6 Pokemon."
        case .pokemonNotFound:
            return "One or more Pokemon could not be found in the database."
        case .databaseError:
            return "Database error occurred during comparison query."
        }
    }
}