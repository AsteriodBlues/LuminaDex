import Foundation
import GRDB

// MARK: - Pokemon Record
struct PokemonRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "pokemon"
    
    let id: Int
    var name: String
    var height: Int
    var weight: Int
    var baseExperience: Int?
    var orderIndex: Int
    var isDefault: Bool
    var speciesId: Int?
    var generation: Int?
    var isLegendary: Bool
    var isMythical: Bool
    var captureRate: Int?
    var baseHappiness: Int?
    var growthRate: String?
    var habitat: String?
    var shape: String?
    var color: String?
    var genderRate: Int?
    var hatchCounter: Int?
    var hasGenderDifferences: Bool
    var formsSwitchable: Bool
    var evolutionChainId: Int?
    var isBaby: Bool
    
    // Collection data
    var isFavorite: Bool
    var isCaught: Bool
    var catchDate: String?
    var progress: Double
    
    // Timestamps
    var createdAt: String
    var updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case height
        case weight
        case baseExperience = "base_experience"
        case orderIndex = "order_index"
        case isDefault = "is_default"
        case speciesId = "species_id"
        case generation
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
        case captureRate = "capture_rate"
        case baseHappiness = "base_happiness"
        case growthRate = "growth_rate"
        case habitat
        case shape
        case color
        case genderRate = "gender_rate"
        case hatchCounter = "hatch_counter"
        case hasGenderDifferences = "has_gender_differences"
        case formsSwitchable = "forms_switchable"
        case evolutionChainId = "evolution_chain_id"
        case isBaby = "is_baby"
        case isFavorite = "is_favorite"
        case isCaught = "is_caught"
        case catchDate = "catch_date"
        case progress
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Associations
    static let types = hasMany(PokemonTypeRecord.self)
    static let abilities = hasMany(PokemonAbilityRecord.self)
    static let moves = hasMany(PokemonMoveRecord.self)
    static let stats = hasMany(PokemonStatRecord.self)
    static let sprites = hasOne(PokemonSpriteRecord.self)
    static let pokedexEntries = hasMany(PokedexEntryRecord.self)
    static let encounters = hasMany(EncounterRecord.self)
    
    // Computed properties
    var displayName: String {
        name.capitalized.replacingOccurrences(of: "-", with: " ")
    }
    
    var formattedHeight: String {
        let meters = Double(height) / 10.0
        return String(format: "%.1f m", meters)
    }
    
    var formattedWeight: String {
        let kg = Double(weight) / 10.0
        return String(format: "%.1f kg", kg)
    }
    
    // Update timestamps on save
    mutating func willSave(_ db: Database) throws {
        updatedAt = ISO8601DateFormatter().string(from: Date())
        if createdAt.isEmpty {
            createdAt = updatedAt
        }
    }
}

// MARK: - Type Record
struct TypeRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "types"
    
    let id: Int
    var name: String
    var generation: Int?
    var damageClass: String?
    var color: String
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case generation
        case damageClass = "damage_class"
        case color
        case createdAt = "created_at"
    }
    
    // Associations
    static let pokemonTypes = hasMany(PokemonTypeRecord.self)
}

// MARK: - Ability Record
struct AbilityRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "abilities"
    
    let id: Int
    var name: String
    var effect: String?
    var shortEffect: String?
    var generation: Int?
    var isMainSeries: Bool
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case effect
        case shortEffect = "short_effect"
        case generation
        case isMainSeries = "is_main_series"
        case createdAt = "created_at"
    }
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    // Associations
    static let pokemonAbilities = hasMany(PokemonAbilityRecord.self)
}

// MARK: - Move Record
struct MoveRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "moves"
    
    let id: Int
    var name: String
    var accuracy: Int?
    var effectChance: Int?
    var pp: Int?
    var priority: Int?
    var power: Int?
    var damageClass: String?
    var effect: String?
    var shortEffect: String?
    var typeId: Int?
    var generation: Int?
    var contestType: String?
    var contestEffect: String?
    var superContestEffect: String?
    var target: String?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case accuracy
        case effectChance = "effect_chance"
        case pp
        case priority
        case power
        case damageClass = "damage_class"
        case effect
        case shortEffect = "short_effect"
        case typeId = "type_id"
        case generation
        case contestType = "contest_type"
        case contestEffect = "contest_effect"
        case superContestEffect = "super_contest_effect"
        case target
        case createdAt = "created_at"
    }
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    // Associations
    static let type = belongsTo(TypeRecord.self)
    static let pokemonMoves = hasMany(PokemonMoveRecord.self)
}

// MARK: - Item Record
struct ItemRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "items"
    
    let id: Int
    var name: String
    var category: String?
    var effect: String?
    var shortEffect: String?
    var cost: Int?
    var flingPower: Int?
    var flingEffect: String?
    var spriteUrl: String?
    var generation: Int?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case effect
        case shortEffect = "short_effect"
        case cost
        case flingPower = "fling_power"
        case flingEffect = "fling_effect"
        case spriteUrl = "sprite_url"
        case generation
        case createdAt = "created_at"
    }
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
}

// MARK: - Evolution Chain Record
struct EvolutionChainRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "evolution_chains"
    
    let id: Int
    var babyTriggerItemId: Int?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case babyTriggerItemId = "baby_trigger_item_id"
        case createdAt = "created_at"
    }
    
    // Associations
    static let evolutions = hasMany(EvolutionRecord.self)
    static let pokemon = hasMany(PokemonRecord.self)
}

// MARK: - Evolution Record
struct EvolutionRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "evolutions"
    
    let id: Int?
    var evolutionChainId: Int
    var evolvesFromSpeciesId: Int?
    var evolvesToSpeciesId: Int
    var evolutionTrigger: String?
    var minLevel: Int?
    var minHappiness: Int?
    var minBeauty: Int?
    var minAffection: Int?
    var needsOverworldRain: Bool
    var partySpeciesId: Int?
    var partyTypeId: Int?
    var relativePhysicalStats: Int?
    var timeOfDay: String?
    var tradeSpeciesId: Int?
    var turnUpsideDown: Bool
    var triggerItemId: Int?
    var heldItemId: Int?
    var knownMoveId: Int?
    var knownMoveTypeId: Int?
    var locationId: Int?
    var gender: Int?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case evolutionChainId = "evolution_chain_id"
        case evolvesFromSpeciesId = "evolves_from_species_id"
        case evolvesToSpeciesId = "evolves_to_species_id"
        case evolutionTrigger = "evolution_trigger"
        case minLevel = "min_level"
        case minHappiness = "min_happiness"
        case minBeauty = "min_beauty"
        case minAffection = "min_affection"
        case needsOverworldRain = "needs_overworld_rain"
        case partySpeciesId = "party_species_id"
        case partyTypeId = "party_type_id"
        case relativePhysicalStats = "relative_physical_stats"
        case timeOfDay = "time_of_day"
        case tradeSpeciesId = "trade_species_id"
        case turnUpsideDown = "turn_upside_down"
        case triggerItemId = "trigger_item_id"
        case heldItemId = "held_item_id"
        case knownMoveId = "known_move_id"
        case knownMoveTypeId = "known_move_type_id"
        case locationId = "location_id"
        case gender
        case createdAt = "created_at"
    }
    
    // Associations
    static let evolutionChain = belongsTo(EvolutionChainRecord.self)
    static let evolvesFrom = belongsTo(PokemonRecord.self, key: "evolvesFromSpeciesId")
    static let evolvesTo = belongsTo(PokemonRecord.self, key: "evolvesToSpeciesId")
}

// MARK: - Pokemon Sprite Record
struct PokemonSpriteRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "pokemon_sprites"
    
    var pokemonId: Int
    var frontDefault: String?
    var frontShiny: String?
    var frontFemale: String?
    var frontShinyFemale: String?
    var backDefault: String?
    var backShiny: String?
    var backFemale: String?
    var backShinyFemale: String?
    var officialArtworkDefault: String?
    var officialArtworkShiny: String?
    var dreamWorldDefault: String?
    var dreamWorldFemale: String?
    var homeDefault: String?
    var homeFemale: String?
    var homeShiny: String?
    var homeShinyFemale: String?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case pokemonId = "pokemon_id"
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case frontFemale = "front_female"
        case frontShinyFemale = "front_shiny_female"
        case backDefault = "back_default"
        case backShiny = "back_shiny"
        case backFemale = "back_female"
        case backShinyFemale = "back_shiny_female"
        case officialArtworkDefault = "official_artwork_default"
        case officialArtworkShiny = "official_artwork_shiny"
        case dreamWorldDefault = "dream_world_default"
        case dreamWorldFemale = "dream_world_female"
        case homeDefault = "home_default"
        case homeFemale = "home_female"
        case homeShiny = "home_shiny"
        case homeShinyFemale = "home_shiny_female"
        case createdAt = "created_at"
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
    
    var defaultSprite: String? {
        return frontDefault ?? officialArtworkDefault ?? dreamWorldDefault ?? homeDefault
    }
    
    var officialArtwork: String? {
        return officialArtworkDefault ?? dreamWorldDefault ?? frontDefault
    }
}

// MARK: - Pokemon Stat Record
struct PokemonStatRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "pokemon_stats"
    
    let id: Int?
    var pokemonId: Int
    var statName: String
    var baseStat: Int
    var effort: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case pokemonId = "pokemon_id"
        case statName = "stat_name"
        case baseStat = "base_stat"
        case effort
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
    
    var displayName: String {
        switch statName {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Attack"
        case "special-defense": return "Sp. Defense"
        case "speed": return "Speed"
        default: return statName.capitalized
        }
    }
    
    var shortName: String {
        switch statName {
        case "hp": return "HP"
        case "attack": return "ATK"
        case "defense": return "DEF"
        case "special-attack": return "SPA"
        case "special-defense": return "SPD"
        case "speed": return "SPE"
        default: return statName.uppercased()
        }
    }
    
    var normalizedValue: Double {
        return Double(baseStat) / 255.0
    }
}

// MARK: - Pokemon Type Record
struct PokemonTypeRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "pokemon_types"
    
    var pokemonId: Int
    var typeId: Int
    var slot: Int
    
    private enum CodingKeys: String, CodingKey {
        case pokemonId = "pokemon_id"
        case typeId = "type_id"
        case slot
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
    static let type = belongsTo(TypeRecord.self)
}

// MARK: - Pokemon Ability Record
struct PokemonAbilityRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "pokemon_abilities"
    
    var pokemonId: Int
    var abilityId: Int
    var slot: Int
    var isHidden: Bool
    
    private enum CodingKeys: String, CodingKey {
        case pokemonId = "pokemon_id"
        case abilityId = "ability_id"
        case slot
        case isHidden = "is_hidden"
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
    static let ability = belongsTo(AbilityRecord.self)
}

// MARK: - Pokemon Move Record
struct PokemonMoveRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "pokemon_moves"
    
    let id: Int?
    var pokemonId: Int
    var moveId: Int
    var versionGroup: String
    var learnMethod: String
    var levelLearnedAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case pokemonId = "pokemon_id"
        case moveId = "move_id"
        case versionGroup = "version_group"
        case learnMethod = "learn_method"
        case levelLearnedAt = "level_learned_at"
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
    static let move = belongsTo(MoveRecord.self)
}

// MARK: - Encounter Record
struct EncounterRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "encounters"
    
    let id: Int?
    var pokemonId: Int
    var locationArea: String
    var method: String?
    var minLevel: Int?
    var maxLevel: Int?
    var chance: Int?
    var conditionValues: String?
    var version: String?
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case pokemonId = "pokemon_id"
        case locationArea = "location_area"
        case method
        case minLevel = "min_level"
        case maxLevel = "max_level"
        case chance
        case conditionValues = "condition_values"
        case version
        case createdAt = "created_at"
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
}

// MARK: - Pokedex Entry Record
struct PokedexEntryRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = "pokedex_entries"
    
    let id: Int?
    var pokemonId: Int
    var pokedexName: String
    var entryNumber: Int?
    var flavorText: String
    var language: String
    var version: String
    var createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case pokemonId = "pokemon_id"
        case pokedexName = "pokedex_name"
        case entryNumber = "entry_number"
        case flavorText = "flavor_text"
        case language
        case version
        case createdAt = "created_at"
    }
    
    // Associations
    static let pokemon = belongsTo(PokemonRecord.self)
}

// MARK: - Database Extensions
extension DatabaseManager {
    // MARK: - Pokemon Operations
    
    func savePokemon(_ pokemon: PokemonRecord) async throws {
        try await dbQueue.write { db in
            try pokemon.save(db)
        }
    }
    
    func getPokemon(id: Int) async throws -> PokemonRecord? {
        try await dbQueue.read { db in
            try PokemonRecord.fetchOne(db, id: id)
        }
    }
    
    func getAllPokemon() async throws -> [PokemonRecord] {
        try await dbQueue.read { db in
            try PokemonRecord.order(Column("id")).fetchAll(db)
        }
    }
    
    func getPokemonWithDetails(id: Int) async throws -> PokemonWithDetails? {
        let pokemon = try await dbQueue.read { db in
            try PokemonRecord.fetchOne(db, id: id)
        }
        
        guard let pokemon = pokemon else { return nil }
        
        return try await dbQueue.read { db in
            let types = try PokemonTypeRecord.filter(Column("pokemon_id") == pokemon.id).fetchAll(db)
            let abilities = try PokemonAbilityRecord.filter(Column("pokemon_id") == pokemon.id).fetchAll(db)
            let moves = try PokemonMoveRecord.filter(Column("pokemon_id") == pokemon.id).fetchAll(db)
            let stats = try PokemonStatRecord.filter(Column("pokemon_id") == pokemon.id).fetchAll(db)
            let sprites = try PokemonSpriteRecord.filter(Column("pokemon_id") == pokemon.id).fetchOne(db)
            let pokedexEntries = try PokedexEntryRecord.filter(Column("pokemon_id") == pokemon.id).fetchAll(db)
            
            return PokemonWithDetails(
                pokemon: pokemon,
                types: types,
                abilities: abilities,
                moves: moves,
                stats: stats,
                sprites: sprites,
                pokedexEntries: pokedexEntries
            )
        }
    }
    
    // MARK: - Collection Operations
    
    func toggleFavorite(pokemonId: Int) async throws {
        try await dbQueue.write { db in
            try db.execute(sql: """
                UPDATE pokemon 
                SET is_favorite = NOT is_favorite, updated_at = ? 
                WHERE id = ?
            """, arguments: [ISO8601DateFormatter().string(from: Date()), pokemonId])
        }
    }
    
    func toggleCaught(pokemonId: Int) async throws {
        try await dbQueue.write { db in
            let now = ISO8601DateFormatter().string(from: Date())
            try db.execute(sql: """
                UPDATE pokemon 
                SET is_caught = NOT is_caught, 
                    catch_date = CASE WHEN is_caught = 0 THEN ? ELSE NULL END,
                    updated_at = ?
                WHERE id = ?
            """, arguments: [now, now, pokemonId])
        }
    }
    
    func updateProgress(pokemonId: Int, progress: Double) async throws {
        try await dbQueue.write { db in
            try db.execute(sql: """
                UPDATE pokemon 
                SET progress = ?, updated_at = ? 
                WHERE id = ?
            """, arguments: [progress, ISO8601DateFormatter().string(from: Date()), pokemonId])
        }
    }
}

// MARK: - Pokemon With Details
struct PokemonWithDetails {
    let pokemon: PokemonRecord
    let types: [PokemonTypeRecord]
    let abilities: [PokemonAbilityRecord]
    let moves: [PokemonMoveRecord]
    let stats: [PokemonStatRecord]
    let sprites: PokemonSpriteRecord?
    let pokedexEntries: [PokedexEntryRecord]
}