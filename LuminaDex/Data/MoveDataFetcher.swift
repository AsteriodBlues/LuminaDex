//
//  MoveDataFetcher.swift
//  LuminaDex
//
//  Fetches complete move data from PokeAPI
//

import Foundation
import SwiftUI

// MARK: - API Response Models
struct APIMoveResponse: Codable {
    let id: Int
    let name: String
    let accuracy: Int?
    let effectChance: Int?
    let pp: Int
    let priority: Int
    let power: Int?
    let damageClass: APIDamageClass
    let effectEntries: [APIEffectEntry]
    let type: APIType
    let target: APITarget
    let generation: APIGeneration
    let learnedByPokemon: [APINamedResource]
    
    enum CodingKeys: String, CodingKey {
        case id, name, accuracy, pp, priority, power, type, target, generation
        case effectChance = "effect_chance"
        case damageClass = "damage_class"
        case effectEntries = "effect_entries"
        case learnedByPokemon = "learned_by_pokemon"
    }
}

struct APIDamageClass: Codable {
    let name: String
}

struct APIEffectEntry: Codable {
    let effect: String
    let shortEffect: String
    let language: APILanguage
    
    enum CodingKeys: String, CodingKey {
        case effect
        case shortEffect = "short_effect"
        case language
    }
}

struct APILanguage: Codable {
    let name: String
}

struct APIType: Codable {
    let name: String
}

struct APITarget: Codable {
    let name: String
}

struct APIGeneration: Codable {
    let name: String
}

struct APINamedResource: Codable {
    let name: String
    let url: String
}

// MARK: - Pokemon API Response
struct APIPokemonResponse: Codable {
    let id: Int
    let name: String
    let moves: [APIPokemonMove]
}

struct APIPokemonMove: Codable {
    let move: APINamedResource
    let versionGroupDetails: [APIVersionGroupDetail]
    
    enum CodingKeys: String, CodingKey {
        case move
        case versionGroupDetails = "version_group_details"
    }
}

struct APIVersionGroupDetail: Codable {
    let levelLearnedAt: Int
    let moveLearnMethod: APINamedResource
    let versionGroup: APINamedResource
    
    enum CodingKeys: String, CodingKey {
        case levelLearnedAt = "level_learned_at"
        case moveLearnMethod = "move_learn_method"
        case versionGroup = "version_group"
    }
}

// MARK: - Move Data Fetcher
@MainActor
class MoveDataFetcher: ObservableObject {
    static let shared = MoveDataFetcher()
    
    @Published var allMoves: [Move] = []
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0
    @Published var loadingMessage = ""
    
    private let database = DatabaseManager.shared
    private var moveCache: [Int: Move] = [:]
    private var moveNameCache: [String: Move] = [:]
    
    // MARK: - Fetch All Moves for Encyclopedia
    func fetchAllMoves() async {
        guard !isLoading else { return }
        
        // If we already have moves, don't fetch again
        if !allMoves.isEmpty {
            return
        }
        
        isLoading = true
        loadingMessage = "Fetching move list..."
        
        do {
            // First, get the list of all moves
            let listURL = "https://pokeapi.co/api/v2/move?limit=1000"
            guard let url = URL(string: listURL) else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(APIResourceList.self, from: data)
            
            var fetchedMoves: [Move] = []
            
            // Fetch a comprehensive set of moves (300 most popular)
            let moveUrls = Array(response.results.prefix(300))
            let totalMoves = moveUrls.count
            
            for (index, resource) in moveUrls.enumerated() {
                loadingProgress = Double(index) / Double(totalMoves)
                loadingMessage = "Loading move \(index + 1) of \(totalMoves): \(resource.name)"
                
                if let move = await fetchMoveDetails(from: resource.url) {
                    fetchedMoves.append(move)
                    moveCache[move.id] = move
                    moveNameCache[move.name] = move
                }
                
                // Rate limiting
                if index % 10 == 0 {
                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 second
                }
            }
            
            allMoves = fetchedMoves.sorted { $0.id < $1.id }
            
            loadingMessage = "Complete! Loaded \(fetchedMoves.count) moves"
            isLoading = false
            
        } catch {
            print("❌ Error fetching moves: \(error)")
            loadingMessage = "Error loading moves"
            isLoading = false
            
            // Load fallback moves
            loadSampleMoves()
        }
    }
    
    // MARK: - Fetch Single Move Details
    private func fetchMoveDetails(from urlString: String) async -> Move? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let apiMove = try JSONDecoder().decode(APIMoveResponse.self, from: data)
            
            // Convert API response to our Move model
            let move = Move(
                id: apiMove.id,
                name: apiMove.name,
                type: PokemonType(rawValue: apiMove.type.name) ?? .unknown,
                category: determineMoveCategory(from: apiMove.damageClass.name),
                power: apiMove.power,
                accuracy: apiMove.accuracy,
                pp: apiMove.pp,
                priority: apiMove.priority,
                generation: extractGeneration(from: apiMove.generation.name),
                damageClass: DamageClass(rawValue: apiMove.damageClass.name) ?? .physical,
                effect: apiMove.effectEntries.first(where: { $0.language.name == "en" })?.shortEffect,
                effectChance: apiMove.effectChance,
                target: MoveTarget(rawValue: apiMove.target.name.replacingOccurrences(of: "-", with: "")) ?? .selectedPokemon,
                critRate: 0
            )
            
            return move
            
        } catch {
            print("❌ Error fetching move details for \(urlString): \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Pokemon Moves
    func fetchPokemonMoves(for pokemonId: Int) async -> [PokemonMoveInfo] {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(pokemonId)"
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(APIPokemonResponse.self, from: data)
            
            var moveDetails: [PokemonMoveInfo] = []
            var processedMoves = Set<String>() // Track unique moves
            
            // Limit to 50 moves for performance
            let movesToProcess = Array(response.moves.prefix(50))
            
            for apiMove in movesToProcess {
                // Skip if we've already processed this move
                if processedMoves.contains(apiMove.move.name) {
                    continue
                }
                processedMoves.insert(apiMove.move.name)
                
                // Try to get from cache first
                var move: Move?
                
                // Check name cache
                if let cachedMove = moveNameCache[apiMove.move.name] {
                    move = cachedMove
                } else {
                    // Extract move ID and check ID cache
                    let moveId = extractId(from: apiMove.move.url)
                    if let cachedMove = moveCache[moveId] {
                        move = cachedMove
                    } else {
                        // Fetch the move details
                        if let fetchedMove = await fetchMoveDetails(from: apiMove.move.url) {
                            move = fetchedMove
                            moveCache[moveId] = fetchedMove
                            moveNameCache[fetchedMove.name] = fetchedMove
                        }
                    }
                }
                
                if let move = move {
                    // Find the best learn method (prefer level-up)
                    var bestDetail: APIVersionGroupDetail?
                    var bestMethod: LearnMethodType = .machine
                    
                    for detail in apiMove.versionGroupDetails {
                        let method = determineLearnMethod(from: detail.moveLearnMethod.name)
                        if method == .levelUp && detail.levelLearnedAt > 0 {
                            bestDetail = detail
                            bestMethod = method
                            break
                        } else if bestDetail == nil {
                            bestDetail = detail
                            bestMethod = method
                        }
                    }
                    
                    if let detail = bestDetail {
                        let pokemonMoveDetail = PokemonMoveInfo(
                            move: move,
                            learnMethod: bestMethod,
                            levelLearnedAt: detail.levelLearnedAt > 0 ? detail.levelLearnedAt : nil
                        )
                        
                        moveDetails.append(pokemonMoveDetail)
                    }
                }
                
                // Small delay to avoid rate limiting
                if moveDetails.count % 5 == 0 {
                    try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second
                }
            }
            
            return moveDetails.sorted { 
                // Sort by learn method priority, then by level if applicable
                if $0.learnMethod != $1.learnMethod {
                    return $0.learnMethod.sortPriority < $1.learnMethod.sortPriority
                }
                if let level0 = $0.levelLearnedAt, let level1 = $1.levelLearnedAt {
                    return level0 < level1
                }
                return $0.move.name < $1.move.name
            }
            
        } catch {
            print("❌ Error fetching moves for Pokemon \(pokemonId): \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    private func determineMoveCategory(from damageClass: String) -> MoveCategory {
        switch damageClass {
        case "physical":
            return .physical
        case "special":
            return .special
        case "status":
            return .status
        default:
            return .physical
        }
    }
    
    private func determineLearnMethod(from method: String) -> LearnMethodType {
        switch method {
        case "level-up":
            return .levelUp
        case "machine", "tm", "hm":
            return .machine
        case "egg":
            return .egg
        case "tutor":
            return .tutor
        default:
            return .levelUp  // Default fallback
        }
    }
    
    private func extractGeneration(from genName: String) -> Int {
        // Format: "generation-i", "generation-ii", etc.
        let romanNumerals = ["i": 1, "ii": 2, "iii": 3, "iv": 4, "v": 5, "vi": 6, "vii": 7, "viii": 8, "ix": 9]
        let parts = genName.split(separator: "-")
        if parts.count > 1 {
            return romanNumerals[String(parts[1])] ?? 1
        }
        return 1
    }
    
    private func extractId(from url: String) -> Int {
        // URL format: https://pokeapi.co/api/v2/move/1/
        let components = url.trimmingCharacters(in: .init(charactersIn: "/")).split(separator: "/")
        if let idString = components.last {
            return Int(idString) ?? 0
        }
        return 0
    }
    
    // MARK: - Load Sample Moves (Fallback)
    func loadSampleMoves() {
        if allMoves.isEmpty {
            allMoves = [
                Move(id: 1, name: "pound", type: .normal, category: .physical, power: 40, accuracy: 100, pp: 35, priority: 0, generation: 1, damageClass: .physical, effect: "Inflicts regular damage.", effectChance: nil, target: .selectedPokemon, critRate: 0),
                Move(id: 5, name: "mega-punch", type: .normal, category: .physical, power: 80, accuracy: 85, pp: 20, priority: 0, generation: 1, damageClass: .physical, effect: "Inflicts regular damage.", effectChance: nil, target: .selectedPokemon, critRate: 0),
                Move(id: 7, name: "fire-punch", type: .fire, category: .physical, power: 75, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .physical, effect: "10% chance to burn.", effectChance: 10, target: .selectedPokemon, critRate: 0),
                Move(id: 9, name: "thunder-punch", type: .electric, category: .physical, power: 75, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .physical, effect: "10% chance to paralyze.", effectChance: 10, target: .selectedPokemon, critRate: 0),
                Move(id: 13, name: "razor-wind", type: .normal, category: .special, power: 80, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: "Charges turn 1. Hits turn 2.", effectChance: nil, target: .allOtherPokemon, critRate: 1),
                Move(id: 85, name: "thunderbolt", type: .electric, category: .special, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to paralyze.", effectChance: 10, target: .selectedPokemon, critRate: 0),
                Move(id: 87, name: "thunder", type: .electric, category: .special, power: 110, accuracy: 70, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: "30% chance to paralyze.", effectChance: 30, target: .selectedPokemon, critRate: 0),
                Move(id: 89, name: "earthquake", type: .ground, category: .physical, power: 100, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .physical, effect: "Inflicts regular damage.", effectChance: nil, target: .allOtherPokemon, critRate: 0),
                Move(id: 94, name: "psychic", type: .psychic, category: .special, power: 90, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to lower Sp. Def.", effectChance: 10, target: .selectedPokemon, critRate: 0),
                Move(id: 126, name: "fire-blast", type: .fire, category: .special, power: 110, accuracy: 85, pp: 5, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to burn.", effectChance: 10, target: .selectedPokemon, critRate: 0)
            ]
        }
    }
}

// MARK: - Pokemon Move Detail
struct PokemonMoveInfo: Identifiable {
    let id = UUID()
    let move: Move
    let learnMethod: LearnMethodType
    let levelLearnedAt: Int?
    
    var displayName: String {
        move.displayName
    }
}

// MARK: - API Resource List
struct APIResourceList: Codable {
    let count: Int
    let results: [APINamedResource]
}

// MARK: - Learn Method Extension
extension LearnMethodType {
    var sortPriority: Int {
        switch self {
        case .levelUp: return 0
        case .machine: return 1
        case .egg: return 2
        case .tutor: return 3
        case .stadium: return 4
        case .lightBall: return 5
        case .form: return 6
        }
    }
}