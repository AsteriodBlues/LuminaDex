import Foundation
import AsyncAlgorithms
import GRDB
import Combine

// MARK: - Pokemon Data Fetcher
@MainActor
class PokemonDataFetcher: ObservableObject {
    static let shared = PokemonDataFetcher()
    
    private let api = PokemonAPI.shared
    private let database = DatabaseManager.shared
    
    // Progress tracking
    @Published var isLoading = false
    @Published var currentOperation = ""
    @Published var progress: Double = 0.0
    @Published var pokemonFetched = 0
    @Published var totalPokemon = 1025
    @Published var movesFetched = 0
    @Published var totalMoves = 918
    @Published var abilitiesFetched = 0
    @Published var totalAbilities = 367
    @Published var itemsFetched = 0
    @Published var totalItems = 2050
    
    // Error tracking
    @Published var errors: [DataFetchError] = []
    @Published var hasErrors = false
    
    // Batch processing configuration
    private let pokemonBatchSize = 50
    private let movesBatchSize = 100
    private let abilitiesBatchSize = 50
    private let itemsBatchSize = 100
    
    // Rate limiting
    private let rateLimiter = AsyncThrottler(interval: 0.1) // 100ms between requests
    
    private init() {}
    
    // MARK: - Main Data Fetching Methods
    
    /// Fetch all Pokemon data progressively
    func fetchAllPokemonData() async {
        isLoading = true
        errors.removeAll()
        
        do {
            // Step 1: Fetch all Pokemon
            await fetchAllPokemon()
            
            // Step 2: Fetch all moves
            await fetchAllMoves()
            
            // Step 3: Fetch all abilities
            await fetchAllAbilities()
            
            // Step 4: Fetch all items
            await fetchAllItems()
            
            // Step 5: Fetch evolution chains
            await fetchEvolutionChains()
            
            // Step 6: Fetch Pokedex entries
            await fetchPokedexEntries()
            
            currentOperation = "Data fetching completed!"
            print("✅ All Pokemon data fetched successfully")
            
        } catch {
            addError(DataFetchError(operation: currentOperation, error: error))
            print("❌ Error during data fetching: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Pokemon Fetching
    
    private func fetchAllPokemon() async {
        currentOperation = "Fetching Pokemon..."
        
        do {
            // Get Pokemon list first
            let pokemonList = try await api.fetchPokemonList(limit: totalPokemon, offset: 0)
            totalPokemon = min(pokemonList.count, 1025) // Ensure we don't exceed known count
            
            // Create async sequence of Pokemon IDs in batches
            let pokemonIDs = Array(1...totalPokemon)
            let batches = pokemonIDs.chunked(into: pokemonBatchSize)
            
            for batch in batches {
                await processPokemonBatch(Array(batch))
            }
            
        } catch {
            addError(DataFetchError(operation: "Fetching Pokemon list", error: error))
        }
    }
    
    private func processPokemonBatch(_ pokemonIDs: [Int]) async {
        // Process batch in parallel with rate limiting
        await withTaskGroup(of: Void.self) { group in
            for pokemonID in pokemonIDs {
                group.addTask { [weak self] in
                    await self?.fetchSinglePokemon(id: pokemonID)
                }
            }
        }
        
        pokemonFetched += pokemonIDs.count
        progress = Double(pokemonFetched) / Double(totalPokemon) * 0.6 // Pokemon accounts for 60% of progress
        currentOperation = "Fetched \(pokemonFetched)/\(totalPokemon) Pokemon"
    }
    
    private func fetchSinglePokemon(id: Int) async {
        do {
            await rateLimiter.throttle()
            
            let pokemon = try await api.fetchPokemon(id: id)
            await storePokemonInDatabase(pokemon)
            
        } catch {
            addError(DataFetchError(operation: "Fetching Pokemon #\(id)", error: error))
        }
    }
    
    private func storePokemonInDatabase(_ pokemon: Pokemon) async {
        do {
            // Convert API model to database record
            let pokemonRecord = PokemonRecord(
                id: pokemon.id,
                name: pokemon.name,
                height: pokemon.height,
                weight: pokemon.weight,
                baseExperience: pokemon.baseExperience,
                orderIndex: pokemon.order,
                isDefault: pokemon.isDefault ?? true,
                speciesId: pokemon.id, // For now, use same ID
                generation: getGenerationFromID(pokemon.id),
                isLegendary: false, // Will be updated when we fetch species data
                isMythical: false,
                captureRate: nil,
                baseHappiness: nil,
                growthRate: nil,
                habitat: nil,
                shape: nil,
                color: nil,
                genderRate: nil,
                hatchCounter: nil,
                hasGenderDifferences: false,
                formsSwitchable: false,
                evolutionChainId: nil,
                isBaby: false,
                isFavorite: false,
                isCaught: false,
                catchDate: nil,
                progress: 0.0,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
            
            try await database.savePokemon(pokemonRecord)
            
            // Store sprites
            await storePokemonSprites(pokemon)
            
            // Store stats
            await storePokemonStats(pokemon)
            
            // Store types
            await storePokemonTypes(pokemon)
            
            // Store abilities
            await storePokemonAbilities(pokemon)
            
            // Store moves
            await storePokemonMoves(pokemon)
            
        } catch {
            addError(DataFetchError(operation: "Storing Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    // MARK: - Pokemon Data Storage Helpers
    
    private func storePokemonSprites(_ pokemon: Pokemon) async {
        do {
            let spriteRecord = PokemonSpriteRecord(
                pokemonId: pokemon.id,
                frontDefault: pokemon.sprites.frontDefault,
                frontShiny: pokemon.sprites.frontShiny,
                frontFemale: pokemon.sprites.frontFemale,
                frontShinyFemale: pokemon.sprites.frontShinyFemale,
                backDefault: pokemon.sprites.backDefault,
                backShiny: pokemon.sprites.backShiny,
                backFemale: pokemon.sprites.backFemale,
                backShinyFemale: pokemon.sprites.backShinyFemale,
                officialArtworkDefault: pokemon.sprites.other?.officialArtwork?.frontDefault,
                officialArtworkShiny: pokemon.sprites.other?.officialArtwork?.frontShiny,
                dreamWorldDefault: pokemon.sprites.other?.dreamWorld?.frontDefault,
                dreamWorldFemale: pokemon.sprites.other?.dreamWorld?.frontFemale,
                homeDefault: pokemon.sprites.other?.home?.frontDefault,
                homeFemale: pokemon.sprites.other?.home?.frontFemale,
                homeShiny: pokemon.sprites.other?.home?.frontShiny,
                homeShinyFemale: pokemon.sprites.other?.home?.frontShinyFemale,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
            
            try await database.databaseQueue.write { db in
                try spriteRecord.save(db)
            }
            
        } catch {
            addError(DataFetchError(operation: "Storing sprites for Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    private func storePokemonStats(_ pokemon: Pokemon) async {
        do {
            try await database.databaseQueue.write { db in
                for stat in pokemon.stats {
                    let statRecord = PokemonStatRecord(
                        id: nil,
                        pokemonId: pokemon.id,
                        statName: stat.stat.name,
                        baseStat: stat.baseStat,
                        effort: stat.effort
                    )
                    try statRecord.save(db)
                }
            }
        } catch {
            addError(DataFetchError(operation: "Storing stats for Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    private func storePokemonTypes(_ pokemon: Pokemon) async {
        do {
            try await database.databaseQueue.write { db in
                for typeSlot in pokemon.types {
                    let typeId = self.getTypeID(from: typeSlot.type.name)
                    let typeRecord = PokemonTypeRecord(
                        pokemonId: pokemon.id,
                        typeId: typeId,
                        slot: typeSlot.slot
                    )
                    try typeRecord.save(db)
                }
            }
        } catch {
            addError(DataFetchError(operation: "Storing types for Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    private func storePokemonAbilities(_ pokemon: Pokemon) async {
        do {
            try await database.databaseQueue.write { db in
                for abilitySlot in pokemon.abilities {
                    // Extract ability ID from URL
                    let abilityId = self.extractIDFromURL(abilitySlot.ability.url)
                    
                    let abilityRecord = PokemonAbilityRecord(
                        pokemonId: pokemon.id,
                        abilityId: abilityId,
                        slot: abilitySlot.slot,
                        isHidden: abilitySlot.isHidden
                    )
                    try abilityRecord.save(db)
                }
            }
        } catch {
            addError(DataFetchError(operation: "Storing abilities for Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    private func storePokemonMoves(_ pokemon: Pokemon) async {
        do {
            try await database.databaseQueue.write { db in
                for moveData in pokemon.moves ?? [] {
                    let moveId = self.extractIDFromURL(moveData.move.url)
                    
                    for versionDetail in moveData.versionGroupDetails {
                        let moveRecord = PokemonMoveRecord(
                            id: nil,
                            pokemonId: pokemon.id,
                            moveId: moveId,
                            versionGroup: versionDetail.versionGroup.name,
                            learnMethod: versionDetail.moveLearnMethod.name,
                            levelLearnedAt: versionDetail.levelLearnedAt
                        )
                        try moveRecord.save(db)
                    }
                }
            }
        } catch {
            addError(DataFetchError(operation: "Storing moves for Pokemon #\(pokemon.id)", error: error))
        }
    }
    
    // MARK: - Moves Fetching
    
    private func fetchAllMoves() async {
        currentOperation = "Fetching moves..."
        
        do {
            let moveIDs = Array(1...totalMoves)
            let batches = moveIDs.chunked(into: movesBatchSize)
            
            for batch in batches {
                await processMovesBatch(Array(batch))
            }
            
        } catch {
            addError(DataFetchError(operation: "Fetching moves", error: error))
        }
    }
    
    private func processMovesBatch(_ moveIDs: [Int]) async {
        await withTaskGroup(of: Void.self) { group in
            for moveID in moveIDs {
                group.addTask { [weak self] in
                    await self?.fetchSingleMove(id: moveID)
                }
            }
        }
        
        movesFetched += moveIDs.count
        let moveProgress = Double(movesFetched) / Double(totalMoves) * 0.15 // Moves account for 15% of progress
        progress = 0.6 + moveProgress
        currentOperation = "Fetched \(movesFetched)/\(totalMoves) moves"
    }
    
    private func fetchSingleMove(id: Int) async {
        do {
            await rateLimiter.throttle()
            
            // Fetch move data from API
            let moveData = try await fetchMoveFromAPI(id: id)
            await storeMoveInDatabase(moveData, id: id)
            
        } catch {
            addError(DataFetchError(operation: "Fetching move #\(id)", error: error))
        }
    }
    
    // MARK: - Abilities Fetching
    
    private func fetchAllAbilities() async {
        currentOperation = "Fetching abilities..."
        
        let abilityIDs = Array(1...totalAbilities)
        let batches = abilityIDs.chunked(into: abilitiesBatchSize)
        
        for batch in batches {
            await processAbilitiesBatch(Array(batch))
        }
    }
    
    private func processAbilitiesBatch(_ abilityIDs: [Int]) async {
        await withTaskGroup(of: Void.self) { group in
            for abilityID in abilityIDs {
                group.addTask { [weak self] in
                    await self?.fetchSingleAbility(id: abilityID)
                }
            }
        }
        
        abilitiesFetched += abilityIDs.count
        let abilityProgress = Double(abilitiesFetched) / Double(totalAbilities) * 0.1 // Abilities account for 10% of progress
        progress = 0.75 + abilityProgress
        currentOperation = "Fetched \(abilitiesFetched)/\(totalAbilities) abilities"
    }
    
    private func fetchSingleAbility(id: Int) async {
        do {
            await rateLimiter.throttle()
            
            let abilityData = try await fetchAbilityFromAPI(id: id)
            await storeAbilityInDatabase(abilityData, id: id)
            
        } catch {
            addError(DataFetchError(operation: "Fetching ability #\(id)", error: error))
        }
    }
    
    // MARK: - Items Fetching
    
    private func fetchAllItems() async {
        currentOperation = "Fetching items..."
        
        let itemIDs = Array(1...totalItems)
        let batches = itemIDs.chunked(into: itemsBatchSize)
        
        for batch in batches {
            await processItemsBatch(Array(batch))
        }
    }
    
    private func processItemsBatch(_ itemIDs: [Int]) async {
        await withTaskGroup(of: Void.self) { group in
            for itemID in itemIDs {
                group.addTask { [weak self] in
                    await self?.fetchSingleItem(id: itemID)
                }
            }
        }
        
        itemsFetched += itemIDs.count
        let itemProgress = Double(itemsFetched) / Double(totalItems) * 0.1 // Items account for 10% of progress
        progress = 0.85 + itemProgress
        currentOperation = "Fetched \(itemsFetched)/\(totalItems) items"
    }
    
    private func fetchSingleItem(id: Int) async {
        do {
            await rateLimiter.throttle()
            
            let itemData = try await fetchItemFromAPI(id: id)
            await storeItemInDatabase(itemData, id: id)
            
        } catch {
            addError(DataFetchError(operation: "Fetching item #\(id)", error: error))
        }
    }
    
    // MARK: - Evolution Chains & Pokedex Entries
    
    private func fetchEvolutionChains() async {
        currentOperation = "Fetching evolution chains..."
        progress = 0.95
        
        // Evolution chains will be implemented when we fetch species data
        // For now, we'll skip this to focus on core data
    }
    
    private func fetchPokedexEntries() async {
        currentOperation = "Fetching Pokedex entries..."
        progress = 1.0
        
        // Pokedex entries will be fetched when we fetch species data
        // For now, we'll skip this to focus on core data
    }
    
    // MARK: - Helper Methods
    
    private func getGenerationFromID(_ id: Int) -> Int {
        switch id {
        case 1...151: return 1
        case 152...251: return 2
        case 252...386: return 3
        case 387...493: return 4
        case 494...649: return 5
        case 650...721: return 6
        case 722...809: return 7
        case 810...905: return 8
        case 906...1025: return 9
        default: return 1
        }
    }
    
    private nonisolated func getTypeID(from typeName: String) -> Int {
        let typeMap: [String: Int] = [
            "normal": 1, "fighting": 2, "flying": 3, "poison": 4,
            "ground": 5, "rock": 6, "bug": 7, "ghost": 8,
            "steel": 9, "fire": 10, "water": 11, "grass": 12,
            "electric": 13, "psychic": 14, "ice": 15, "dragon": 16,
            "dark": 17, "fairy": 18, "unknown": 10001, "shadow": 10002
        ]
        return typeMap[typeName] ?? 1
    }
    
    private nonisolated func extractIDFromURL(_ url: String) -> Int {
        let components = url.components(separatedBy: "/")
        return Int(components[components.count - 2]) ?? 0
    }
    
    private func addError(_ error: DataFetchError) {
        errors.append(error)
        hasErrors = true
    }
    
    // MARK: - Placeholder API Methods (to be implemented)
    
    private func fetchMoveFromAPI(id: Int) async throws -> MoveAPIResponse {
        // Placeholder - will implement actual API call
        return MoveAPIResponse(id: id, name: "move-\(id)")
    }
    
    private func fetchAbilityFromAPI(id: Int) async throws -> AbilityAPIResponse {
        // Placeholder - will implement actual API call
        return AbilityAPIResponse(id: id, name: "ability-\(id)")
    }
    
    private func fetchItemFromAPI(id: Int) async throws -> ItemAPIResponse {
        // Placeholder - will implement actual API call
        return ItemAPIResponse(id: id, name: "item-\(id)")
    }
    
    private func storeMoveInDatabase(_ move: MoveAPIResponse, id: Int) async {
        // Placeholder - will implement actual database storage
    }
    
    private func storeAbilityInDatabase(_ ability: AbilityAPIResponse, id: Int) async {
        // Placeholder - will implement actual database storage
    }
    
    private func storeItemInDatabase(_ item: ItemAPIResponse, id: Int) async {
        // Placeholder - will implement actual database storage
    }
}

// MARK: - Async Throttler
actor AsyncThrottler {
    private var lastExecutionTime: Date = Date.distantPast
    private let interval: TimeInterval
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func throttle() async {
        let now = Date()
        let timeSinceLastExecution = now.timeIntervalSince(lastExecutionTime)
        
        if timeSinceLastExecution < interval {
            let delay = interval - timeSinceLastExecution
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        lastExecutionTime = Date()
    }
}

// MARK: - Data Fetch Error
struct DataFetchError: Error, Identifiable {
    let id = UUID()
    let operation: String
    let error: Error
    let timestamp = Date()
    
    var localizedDescription: String {
        "\(operation): \(error.localizedDescription)"
    }
}

// MARK: - Array Extension for Chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Placeholder API Response Models
struct MoveAPIResponse {
    let id: Int
    let name: String
}

struct AbilityAPIResponse {
    let id: Int
    let name: String
}

struct ItemAPIResponse {
    let id: Int
    let name: String
}