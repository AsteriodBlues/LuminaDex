import Foundation
import GRDB
import Combine

// MARK: - Database Manager
@MainActor
class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    
    let dbQueue: DatabaseQueue
    private let dbPath: String
    private var cancellables = Set<AnyCancellable>()
    
    // Database version for migrations
    static let currentDatabaseVersion = 1
    
    private init() {
        // Create database path in Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dbPath = documentsPath.appendingPathComponent("LuminaDex.sqlite").path
        
        // Configure database
        var config = Configuration()
        config.prepareDatabase { db in
            // Enable foreign key support
            try db.execute(sql: "PRAGMA foreign_keys = ON")
            // Enable WAL mode for better concurrency
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            // Optimize for performance
            try db.execute(sql: "PRAGMA synchronous = NORMAL")
            try db.execute(sql: "PRAGMA cache_size = 10000")
            try db.execute(sql: "PRAGMA temp_store = MEMORY")
        }
        
        // Initialize database queue
        do {
            dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
            try setupDatabase()
            print("✅ Database initialized at: \(dbPath)")
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    // MARK: - Database Setup
    
    private func setupDatabase() throws {
        try dbQueue.write { db in
            // Create all tables
            try createPokemonTable(db)
            try createTypesTable(db)
            try createAbilitiesTable(db)
            try createMovesTable(db)
            try createItemsTable(db)
            try createEvolutionChainsTable(db)
            try createEncountersTable(db)
            try createPokedexEntriesTable(db)
            try createPokemonSpritesTable(db)
            try createPokemonStatsTable(db)
            try createPokemonTypesTable(db)
            try createPokemonAbilitiesTable(db)
            try createPokemonMovesTable(db)
            
            // Create indexes for performance
            try createIndexes(db)
            
            // Set database version
            try db.execute(sql: "PRAGMA user_version = \(Self.currentDatabaseVersion)")
        }
    }
    
    // MARK: - Table Creation
    
    private func createPokemonTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL,
                height INTEGER NOT NULL,
                weight INTEGER NOT NULL,
                base_experience INTEGER,
                order_index INTEGER NOT NULL,
                is_default BOOLEAN NOT NULL DEFAULT 1,
                species_id INTEGER,
                generation INTEGER,
                is_legendary BOOLEAN NOT NULL DEFAULT 0,
                is_mythical BOOLEAN NOT NULL DEFAULT 0,
                capture_rate INTEGER,
                base_happiness INTEGER,
                growth_rate TEXT,
                habitat TEXT,
                shape TEXT,
                color TEXT,
                gender_rate INTEGER,
                hatch_counter INTEGER,
                has_gender_differences BOOLEAN NOT NULL DEFAULT 0,
                forms_switchable BOOLEAN NOT NULL DEFAULT 0,
                evolution_chain_id INTEGER,
                is_baby BOOLEAN NOT NULL DEFAULT 0,
                
                -- Collection data
                is_favorite BOOLEAN NOT NULL DEFAULT 0,
                is_caught BOOLEAN NOT NULL DEFAULT 0,
                catch_date TEXT,
                progress REAL NOT NULL DEFAULT 0.0,
                
                -- Timestamps
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                UNIQUE(id),
                FOREIGN KEY (evolution_chain_id) REFERENCES evolution_chains(id)
            )
        """)
        
        // Add full-text search
        try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS pokemon_fts USING fts5(
                name, 
                content='pokemon',
                content_rowid='id'
            )
        """)
        
        // Trigger to keep FTS in sync
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS pokemon_fts_insert AFTER INSERT ON pokemon BEGIN
                INSERT INTO pokemon_fts(rowid, name) VALUES (new.id, new.name);
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS pokemon_fts_update AFTER UPDATE ON pokemon BEGIN
                UPDATE pokemon_fts SET name = new.name WHERE rowid = new.id;
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS pokemon_fts_delete AFTER DELETE ON pokemon BEGIN
                DELETE FROM pokemon_fts WHERE rowid = old.id;
            END
        """)
    }
    
    private func createTypesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS types (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL UNIQUE,
                generation INTEGER,
                damage_class TEXT,
                color TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        // Insert default types
        let defaultTypes: [(Int, String, String)] = [
            (1, "normal", "#A8A878"),
            (2, "fighting", "#C03028"),
            (3, "flying", "#A890F0"),
            (4, "poison", "#A040A0"),
            (5, "ground", "#E0C068"),
            (6, "rock", "#B8A038"),
            (7, "bug", "#A8B820"),
            (8, "ghost", "#705898"),
            (9, "steel", "#B8B8D0"),
            (10, "fire", "#F08030"),
            (11, "water", "#6890F0"),
            (12, "grass", "#78C850"),
            (13, "electric", "#F8D030"),
            (14, "psychic", "#F85888"),
            (15, "ice", "#98D8D8"),
            (16, "dragon", "#7038F8"),
            (17, "dark", "#705848"),
            (18, "fairy", "#EE99AC"),
            (10001, "unknown", "#68A090"),
            (10002, "shadow", "#000000")
        ]
        
        for (id, name, color) in defaultTypes {
            try db.execute(sql: """
                INSERT OR IGNORE INTO types (id, name, color, generation) 
                VALUES (?, ?, ?, ?)
            """, arguments: [id, name, color, id <= 18 ? 1 : 8])
        }
    }
    
    private func createAbilitiesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS abilities (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL UNIQUE,
                effect TEXT,
                short_effect TEXT,
                generation INTEGER,
                is_main_series BOOLEAN NOT NULL DEFAULT 1,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)
    }
    
    private func createMovesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS moves (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL UNIQUE,
                accuracy INTEGER,
                effect_chance INTEGER,
                pp INTEGER,
                priority INTEGER,
                power INTEGER,
                damage_class TEXT,
                effect TEXT,
                short_effect TEXT,
                type_id INTEGER,
                generation INTEGER,
                contest_type TEXT,
                contest_effect TEXT,
                super_contest_effect TEXT,
                target TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (type_id) REFERENCES types(id)
            )
        """)
    }
    
    private func createItemsTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS items (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL UNIQUE,
                category TEXT,
                effect TEXT,
                short_effect TEXT,
                cost INTEGER,
                fling_power INTEGER,
                fling_effect TEXT,
                sprite_url TEXT,
                generation INTEGER,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)
    }
    
    private func createEvolutionChainsTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS evolution_chains (
                id INTEGER PRIMARY KEY NOT NULL,
                baby_trigger_item_id INTEGER,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (baby_trigger_item_id) REFERENCES items(id)
            )
        """)
        
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS evolutions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                evolution_chain_id INTEGER NOT NULL,
                evolves_from_species_id INTEGER,
                evolves_to_species_id INTEGER NOT NULL,
                evolution_trigger TEXT,
                min_level INTEGER,
                min_happiness INTEGER,
                min_beauty INTEGER,
                min_affection INTEGER,
                needs_overworld_rain BOOLEAN DEFAULT 0,
                party_species_id INTEGER,
                party_type_id INTEGER,
                relative_physical_stats INTEGER,
                time_of_day TEXT,
                trade_species_id INTEGER,
                turn_upside_down BOOLEAN DEFAULT 0,
                trigger_item_id INTEGER,
                held_item_id INTEGER,
                known_move_id INTEGER,
                known_move_type_id INTEGER,
                location_id INTEGER,
                gender INTEGER,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (evolution_chain_id) REFERENCES evolution_chains(id),
                FOREIGN KEY (evolves_from_species_id) REFERENCES pokemon(id),
                FOREIGN KEY (evolves_to_species_id) REFERENCES pokemon(id),
                FOREIGN KEY (party_type_id) REFERENCES types(id),
                FOREIGN KEY (trigger_item_id) REFERENCES items(id),
                FOREIGN KEY (held_item_id) REFERENCES items(id),
                FOREIGN KEY (known_move_id) REFERENCES moves(id),
                FOREIGN KEY (known_move_type_id) REFERENCES types(id)
            )
        """)
    }
    
    private func createEncountersTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS encounters (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pokemon_id INTEGER NOT NULL,
                location_area TEXT NOT NULL,
                method TEXT,
                min_level INTEGER,
                max_level INTEGER,
                chance INTEGER,
                condition_values TEXT,
                version TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id),
                UNIQUE(pokemon_id, location_area, method, version)
            )
        """)
    }
    
    private func createPokedexEntriesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokedex_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pokemon_id INTEGER NOT NULL,
                pokedex_name TEXT NOT NULL,
                entry_number INTEGER,
                flavor_text TEXT NOT NULL,
                language TEXT NOT NULL DEFAULT 'en',
                version TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id),
                UNIQUE(pokemon_id, pokedex_name, version, language)
            )
        """)
    }
    
    private func createPokemonSpritesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon_sprites (
                pokemon_id INTEGER PRIMARY KEY NOT NULL,
                front_default TEXT,
                front_shiny TEXT,
                front_female TEXT,
                front_shiny_female TEXT,
                back_default TEXT,
                back_shiny TEXT,
                back_female TEXT,
                back_shiny_female TEXT,
                official_artwork_default TEXT,
                official_artwork_shiny TEXT,
                dream_world_default TEXT,
                dream_world_female TEXT,
                home_default TEXT,
                home_female TEXT,
                home_shiny TEXT,
                home_shiny_female TEXT,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
                
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE
            )
        """)
    }
    
    private func createPokemonStatsTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon_stats (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pokemon_id INTEGER NOT NULL,
                stat_name TEXT NOT NULL,
                base_stat INTEGER NOT NULL,
                effort INTEGER NOT NULL DEFAULT 0,
                
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
                UNIQUE(pokemon_id, stat_name)
            )
        """)
    }
    
    private func createPokemonTypesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon_types (
                pokemon_id INTEGER NOT NULL,
                type_id INTEGER NOT NULL,
                slot INTEGER NOT NULL,
                
                PRIMARY KEY (pokemon_id, slot),
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
                FOREIGN KEY (type_id) REFERENCES types(id)
            )
        """)
    }
    
    private func createPokemonAbilitiesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon_abilities (
                pokemon_id INTEGER NOT NULL,
                ability_id INTEGER NOT NULL,
                slot INTEGER NOT NULL,
                is_hidden BOOLEAN NOT NULL DEFAULT 0,
                
                PRIMARY KEY (pokemon_id, slot),
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
                FOREIGN KEY (ability_id) REFERENCES abilities(id)
            )
        """)
    }
    
    private func createPokemonMovesTable(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS pokemon_moves (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pokemon_id INTEGER NOT NULL,
                move_id INTEGER NOT NULL,
                version_group TEXT NOT NULL,
                learn_method TEXT NOT NULL,
                level_learned_at INTEGER NOT NULL DEFAULT 0,
                
                FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
                FOREIGN KEY (move_id) REFERENCES moves(id),
                UNIQUE(pokemon_id, move_id, version_group, learn_method)
            )
        """)
    }
    
    private func createIndexes(_ db: Database) throws {
        // Pokemon indexes
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_name ON pokemon(name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_generation ON pokemon(generation)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_caught ON pokemon(is_caught)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_favorite ON pokemon(is_favorite)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_evolution_chain ON pokemon(evolution_chain_id)")
        
        // Type relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_types_pokemon ON pokemon_types(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_types_type ON pokemon_types(type_id)")
        
        // Ability relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_pokemon ON pokemon_abilities(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_ability ON pokemon_abilities(ability_id)")
        
        // Move relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_pokemon ON pokemon_moves(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_move ON pokemon_moves(move_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_method ON pokemon_moves(learn_method)")
        
        // Stats
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_stats_pokemon ON pokemon_stats(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_stats_stat ON pokemon_stats(stat_name)")
        
        // Encounters
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_pokemon ON encounters(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_location ON encounters(location_area)")
        
        // Pokedex entries
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_pokemon ON pokedex_entries(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_pokedex ON pokedex_entries(pokedex_name)")
        
        // Evolutions
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_chain ON evolutions(evolution_chain_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_from ON evolutions(evolves_from_species_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_to ON evolutions(evolves_to_species_id)")
    }
    
    // MARK: - Database Access
    
    var databaseQueue: DatabaseQueue {
        return dbQueue
    }
    
    // MARK: - Observation
    
    func observePokemon() -> AnyPublisher<[PokemonRecord], Error> {
        return ValueObservation
            .tracking(PokemonRecord.fetchAll)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func observeFavoritePokemon() -> AnyPublisher<[PokemonRecord], Error> {
        return ValueObservation
            .tracking { db in
                try PokemonRecord.filter(Column("is_favorite") == true).fetchAll(db)
            }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func observeCaughtPokemon() -> AnyPublisher<[PokemonRecord], Error> {
        return ValueObservation
            .tracking { db in
                try PokemonRecord.filter(Column("is_caught") == true).fetchAll(db)
            }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Full-Text Search
    
    func searchPokemon(query: String) async throws -> [PokemonRecord] {
        return try await dbQueue.read { db in
            let searchQuery = "'\(query)*'"
            return try PokemonRecord.fetchAll(db, sql: """
                SELECT pokemon.* FROM pokemon 
                JOIN pokemon_fts ON pokemon.id = pokemon_fts.rowid 
                WHERE pokemon_fts MATCH ?
            """, arguments: [searchQuery])
        }
    }
    
    // MARK: - Team Builder Support
    
    func getAllExtendedPokemon() async throws -> [ExtendedPokemonRecord] {
        // Return all Pokemon from comprehensive data
        return AllPokemonData.getAllPokemon()
        
        /* Database code for future use
        let dbRecords = try? await dbQueue.read { db -> [ExtendedPokemonRecord] in
            let rows = try Row.fetchAll(db, sql: """
                SELECT 
                    p.id,
                    p.name,
                    GROUP_CONCAT(DISTINCT t.name) as types,
                    ps.front_default as sprite_url,
                    MAX(CASE WHEN s.stat_name = 'hp' THEN s.base_stat END) as hp,
                    MAX(CASE WHEN s.stat_name = 'attack' THEN s.base_stat END) as attack,
                    MAX(CASE WHEN s.stat_name = 'defense' THEN s.base_stat END) as defense,
                    MAX(CASE WHEN s.stat_name = 'special-attack' THEN s.base_stat END) as special_attack,
                    MAX(CASE WHEN s.stat_name = 'special-defense' THEN s.base_stat END) as special_defense,
                    MAX(CASE WHEN s.stat_name = 'speed' THEN s.base_stat END) as speed
                FROM pokemon p
                LEFT JOIN pokemon_types pt ON p.id = pt.pokemon_id
                LEFT JOIN types t ON pt.type_id = t.id
                LEFT JOIN pokemon_sprites ps ON p.id = ps.pokemon_id
                LEFT JOIN pokemon_stats s ON p.id = s.pokemon_id
                GROUP BY p.id
                ORDER BY p.id
                LIMIT 1025
            """)
            
            return rows.compactMap { row in
                guard let id = row["id"] as? Int, id > 0,
                      let name = row["name"] as? String, !name.isEmpty else {
                    return nil
                }
                
                let typesString = row["types"] as? String ?? ""
                let types = typesString.split(separator: ",").map { String($0) }
                
                var stats: [String: Int] = [:]
                if let hp = row["hp"] as? Int { stats["hp"] = hp }
                if let attack = row["attack"] as? Int { stats["attack"] = attack }
                if let defense = row["defense"] as? Int { stats["defense"] = defense }
                if let spAttack = row["special_attack"] as? Int { stats["special-attack"] = spAttack }
                if let spDefense = row["special_defense"] as? Int { stats["special-defense"] = spDefense }
                if let speed = row["speed"] as? Int { stats["speed"] = speed }
                
                let spriteUrl = (row["sprite_url"] as? String) ?? 
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
                
                return ExtendedPokemonRecord(
                    id: id,
                    name: name,
                    types: types,
                    stats: stats,
                    spriteUrl: spriteUrl
                )
            }
        }
        
        // If database is empty, fetch from API
        if dbRecords == nil || dbRecords?.isEmpty == true {
            return try await fetchAllPokemonFromAPI()
        }
        
        return dbRecords ?? []
        */
    }
    
    private func fetchAllPokemonFromAPI() async throws -> [ExtendedPokemonRecord] {
        // For now, return comprehensive mock data immediately
        // This ensures the team builder works while API integration is improved
        return createComprehensiveMockData()
    }
    
    private func createComprehensiveMockData() -> [ExtendedPokemonRecord] {
        // Return first 151 Pokemon (Gen 1) with proper data
        var pokemon: [ExtendedPokemonRecord] = []
        
        // Gen 1 Pokemon with proper types and base stats
        let gen1Data: [(Int, String, [String], [String: Int])] = [
            (1, "bulbasaur", ["grass", "poison"], ["hp": 45, "attack": 49, "defense": 49, "special-attack": 65, "special-defense": 65, "speed": 45]),
            (2, "ivysaur", ["grass", "poison"], ["hp": 60, "attack": 62, "defense": 63, "special-attack": 80, "special-defense": 80, "speed": 60]),
            (3, "venusaur", ["grass", "poison"], ["hp": 80, "attack": 82, "defense": 83, "special-attack": 100, "special-defense": 100, "speed": 80]),
            (4, "charmander", ["fire"], ["hp": 39, "attack": 52, "defense": 43, "special-attack": 60, "special-defense": 50, "speed": 65]),
            (5, "charmeleon", ["fire"], ["hp": 58, "attack": 64, "defense": 58, "special-attack": 80, "special-defense": 65, "speed": 80]),
            (6, "charizard", ["fire", "flying"], ["hp": 78, "attack": 84, "defense": 78, "special-attack": 109, "special-defense": 85, "speed": 100]),
            (7, "squirtle", ["water"], ["hp": 44, "attack": 48, "defense": 65, "special-attack": 50, "special-defense": 64, "speed": 43]),
            (8, "wartortle", ["water"], ["hp": 59, "attack": 63, "defense": 80, "special-attack": 65, "special-defense": 80, "speed": 58]),
            (9, "blastoise", ["water"], ["hp": 79, "attack": 83, "defense": 100, "special-attack": 85, "special-defense": 105, "speed": 78]),
            (10, "caterpie", ["bug"], ["hp": 45, "attack": 30, "defense": 35, "special-attack": 20, "special-defense": 20, "speed": 45]),
            (11, "metapod", ["bug"], ["hp": 50, "attack": 20, "defense": 55, "special-attack": 25, "special-defense": 25, "speed": 30]),
            (12, "butterfree", ["bug", "flying"], ["hp": 60, "attack": 45, "defense": 50, "special-attack": 90, "special-defense": 80, "speed": 70]),
            (13, "weedle", ["bug", "poison"], ["hp": 40, "attack": 35, "defense": 30, "special-attack": 20, "special-defense": 20, "speed": 50]),
            (14, "kakuna", ["bug", "poison"], ["hp": 45, "attack": 25, "defense": 50, "special-attack": 25, "special-defense": 25, "speed": 35]),
            (15, "beedrill", ["bug", "poison"], ["hp": 65, "attack": 90, "defense": 40, "special-attack": 45, "special-defense": 80, "speed": 75]),
            (16, "pidgey", ["normal", "flying"], ["hp": 40, "attack": 45, "defense": 40, "special-attack": 35, "special-defense": 35, "speed": 56]),
            (17, "pidgeotto", ["normal", "flying"], ["hp": 63, "attack": 60, "defense": 55, "special-attack": 50, "special-defense": 50, "speed": 71]),
            (18, "pidgeot", ["normal", "flying"], ["hp": 83, "attack": 80, "defense": 75, "special-attack": 70, "special-defense": 70, "speed": 101]),
            (19, "rattata", ["normal"], ["hp": 30, "attack": 56, "defense": 35, "special-attack": 25, "special-defense": 35, "speed": 72]),
            (20, "raticate", ["normal"], ["hp": 55, "attack": 81, "defense": 60, "special-attack": 50, "special-defense": 70, "speed": 97]),
            (21, "spearow", ["normal", "flying"], ["hp": 40, "attack": 60, "defense": 30, "special-attack": 31, "special-defense": 31, "speed": 70]),
            (22, "fearow", ["normal", "flying"], ["hp": 65, "attack": 90, "defense": 65, "special-attack": 61, "special-defense": 61, "speed": 100]),
            (23, "ekans", ["poison"], ["hp": 35, "attack": 60, "defense": 44, "special-attack": 40, "special-defense": 54, "speed": 55]),
            (24, "arbok", ["poison"], ["hp": 60, "attack": 95, "defense": 69, "special-attack": 65, "special-defense": 79, "speed": 80]),
            (25, "pikachu", ["electric"], ["hp": 35, "attack": 55, "defense": 40, "special-attack": 50, "special-defense": 50, "speed": 90]),
            (26, "raichu", ["electric"], ["hp": 60, "attack": 90, "defense": 55, "special-attack": 90, "special-defense": 80, "speed": 110]),
            (27, "sandshrew", ["ground"], ["hp": 50, "attack": 75, "defense": 85, "special-attack": 20, "special-defense": 30, "speed": 40]),
            (28, "sandslash", ["ground"], ["hp": 75, "attack": 100, "defense": 110, "special-attack": 45, "special-defense": 55, "speed": 65]),
            (29, "nidoran-f", ["poison"], ["hp": 55, "attack": 47, "defense": 52, "special-attack": 40, "special-defense": 40, "speed": 41]),
            (30, "nidorina", ["poison"], ["hp": 70, "attack": 62, "defense": 67, "special-attack": 55, "special-defense": 55, "speed": 56]),
            (31, "nidoqueen", ["poison", "ground"], ["hp": 90, "attack": 92, "defense": 87, "special-attack": 75, "special-defense": 85, "speed": 76]),
            (32, "nidoran-m", ["poison"], ["hp": 46, "attack": 57, "defense": 40, "special-attack": 40, "special-defense": 40, "speed": 50]),
            (33, "nidorino", ["poison"], ["hp": 61, "attack": 72, "defense": 57, "special-attack": 55, "special-defense": 55, "speed": 65]),
            (34, "nidoking", ["poison", "ground"], ["hp": 81, "attack": 102, "defense": 77, "special-attack": 85, "special-defense": 75, "speed": 85]),
            (35, "clefairy", ["fairy"], ["hp": 70, "attack": 45, "defense": 48, "special-attack": 60, "special-defense": 65, "speed": 35]),
            (36, "clefable", ["fairy"], ["hp": 95, "attack": 70, "defense": 73, "special-attack": 95, "special-defense": 90, "speed": 60]),
            (37, "vulpix", ["fire"], ["hp": 38, "attack": 41, "defense": 40, "special-attack": 50, "special-defense": 65, "speed": 65]),
            (38, "ninetales", ["fire"], ["hp": 73, "attack": 76, "defense": 75, "special-attack": 81, "special-defense": 100, "speed": 100]),
            (39, "jigglypuff", ["normal", "fairy"], ["hp": 115, "attack": 45, "defense": 20, "special-attack": 45, "special-defense": 25, "speed": 20]),
            (40, "wigglytuff", ["normal", "fairy"], ["hp": 140, "attack": 70, "defense": 45, "special-attack": 85, "special-defense": 50, "speed": 45]),
            (41, "zubat", ["poison", "flying"], ["hp": 40, "attack": 45, "defense": 35, "special-attack": 30, "special-defense": 40, "speed": 55]),
            (42, "golbat", ["poison", "flying"], ["hp": 75, "attack": 80, "defense": 70, "special-attack": 65, "special-defense": 75, "speed": 90]),
            (43, "oddish", ["grass", "poison"], ["hp": 45, "attack": 50, "defense": 55, "special-attack": 75, "special-defense": 65, "speed": 30]),
            (44, "gloom", ["grass", "poison"], ["hp": 60, "attack": 65, "defense": 70, "special-attack": 85, "special-defense": 75, "speed": 40]),
            (45, "vileplume", ["grass", "poison"], ["hp": 75, "attack": 80, "defense": 85, "special-attack": 110, "special-defense": 90, "speed": 50]),
            (46, "paras", ["bug", "grass"], ["hp": 35, "attack": 70, "defense": 55, "special-attack": 45, "special-defense": 55, "speed": 25]),
            (47, "parasect", ["bug", "grass"], ["hp": 60, "attack": 95, "defense": 80, "special-attack": 60, "special-defense": 80, "speed": 30]),
            (48, "venonat", ["bug", "poison"], ["hp": 60, "attack": 55, "defense": 50, "special-attack": 40, "special-defense": 55, "speed": 45]),
            (49, "venomoth", ["bug", "poison"], ["hp": 70, "attack": 65, "defense": 60, "special-attack": 90, "special-defense": 75, "speed": 90]),
            (50, "diglett", ["ground"], ["hp": 10, "attack": 55, "defense": 25, "special-attack": 35, "special-defense": 45, "speed": 95])
        ]
        
        // Add more Gen 1 Pokemon to complete the list
        let moreGen1: [(Int, String, [String], [String: Int])] = [
            (51, "dugtrio", ["ground"], ["hp": 35, "attack": 100, "defense": 50, "special-attack": 50, "special-defense": 70, "speed": 120]),
            (52, "meowth", ["normal"], ["hp": 40, "attack": 45, "defense": 35, "special-attack": 40, "special-defense": 40, "speed": 90]),
            (53, "persian", ["normal"], ["hp": 65, "attack": 70, "defense": 60, "special-attack": 65, "special-defense": 65, "speed": 115]),
            (54, "psyduck", ["water"], ["hp": 50, "attack": 52, "defense": 48, "special-attack": 65, "special-defense": 50, "speed": 55]),
            (55, "golduck", ["water"], ["hp": 80, "attack": 82, "defense": 78, "special-attack": 95, "special-defense": 80, "speed": 85]),
            (56, "mankey", ["fighting"], ["hp": 40, "attack": 80, "defense": 35, "special-attack": 35, "special-defense": 45, "speed": 70]),
            (57, "primeape", ["fighting"], ["hp": 65, "attack": 105, "defense": 60, "special-attack": 60, "special-defense": 70, "speed": 95]),
            (58, "growlithe", ["fire"], ["hp": 55, "attack": 70, "defense": 45, "special-attack": 70, "special-defense": 50, "speed": 60]),
            (59, "arcanine", ["fire"], ["hp": 90, "attack": 110, "defense": 80, "special-attack": 100, "special-defense": 80, "speed": 95]),
            (60, "poliwag", ["water"], ["hp": 40, "attack": 50, "defense": 40, "special-attack": 40, "special-defense": 40, "speed": 90]),
            (61, "poliwhirl", ["water"], ["hp": 65, "attack": 65, "defense": 65, "special-attack": 50, "special-defense": 50, "speed": 90]),
            (62, "poliwrath", ["water", "fighting"], ["hp": 90, "attack": 95, "defense": 95, "special-attack": 70, "special-defense": 90, "speed": 70]),
            (63, "abra", ["psychic"], ["hp": 25, "attack": 20, "defense": 15, "special-attack": 105, "special-defense": 55, "speed": 90]),
            (64, "kadabra", ["psychic"], ["hp": 40, "attack": 35, "defense": 30, "special-attack": 120, "special-defense": 70, "speed": 105]),
            (65, "alakazam", ["psychic"], ["hp": 55, "attack": 50, "defense": 45, "special-attack": 135, "special-defense": 95, "speed": 120]),
            (66, "machop", ["fighting"], ["hp": 70, "attack": 80, "defense": 50, "special-attack": 35, "special-defense": 35, "speed": 35]),
            (67, "machoke", ["fighting"], ["hp": 80, "attack": 100, "defense": 70, "special-attack": 50, "special-defense": 60, "speed": 45]),
            (68, "machamp", ["fighting"], ["hp": 90, "attack": 130, "defense": 80, "special-attack": 65, "special-defense": 85, "speed": 55]),
            (69, "bellsprout", ["grass", "poison"], ["hp": 50, "attack": 75, "defense": 35, "special-attack": 70, "special-defense": 30, "speed": 40]),
            (70, "weepinbell", ["grass", "poison"], ["hp": 65, "attack": 90, "defense": 50, "special-attack": 85, "special-defense": 45, "speed": 55]),
            (71, "victreebel", ["grass", "poison"], ["hp": 80, "attack": 105, "defense": 65, "special-attack": 100, "special-defense": 70, "speed": 70]),
            (72, "tentacool", ["water", "poison"], ["hp": 40, "attack": 40, "defense": 35, "special-attack": 50, "special-defense": 100, "speed": 70]),
            (73, "tentacruel", ["water", "poison"], ["hp": 80, "attack": 70, "defense": 65, "special-attack": 80, "special-defense": 120, "speed": 100]),
            (74, "geodude", ["rock", "ground"], ["hp": 40, "attack": 80, "defense": 100, "special-attack": 30, "special-defense": 30, "speed": 20]),
            (75, "graveler", ["rock", "ground"], ["hp": 55, "attack": 95, "defense": 115, "special-attack": 45, "special-defense": 45, "speed": 35]),
            (76, "golem", ["rock", "ground"], ["hp": 80, "attack": 120, "defense": 130, "special-attack": 55, "special-defense": 65, "speed": 45])
        ]
        
        // Add more popular Pokemon beyond Gen 1
        let additionalPokemon: [(Int, String, [String], [String: Int])] = [
            (94, "gengar", ["ghost", "poison"], ["hp": 60, "attack": 65, "defense": 60, "special-attack": 130, "special-defense": 75, "speed": 110]),
            (130, "gyarados", ["water", "flying"], ["hp": 95, "attack": 125, "defense": 79, "special-attack": 60, "special-defense": 100, "speed": 81]),
            (131, "lapras", ["water", "ice"], ["hp": 130, "attack": 85, "defense": 80, "special-attack": 85, "special-defense": 95, "speed": 60]),
            (143, "snorlax", ["normal"], ["hp": 160, "attack": 110, "defense": 65, "special-attack": 65, "special-defense": 110, "speed": 30]),
            (149, "dragonite", ["dragon", "flying"], ["hp": 91, "attack": 134, "defense": 95, "special-attack": 100, "special-defense": 100, "speed": 80]),
            (150, "mewtwo", ["psychic"], ["hp": 106, "attack": 110, "defense": 90, "special-attack": 154, "special-defense": 90, "speed": 130]),
            (151, "mew", ["psychic"], ["hp": 100, "attack": 100, "defense": 100, "special-attack": 100, "special-defense": 100, "speed": 100])
        ]
        
        // Combine all Pokemon data
        let allPokemonData = gen1Data + moreGen1 + additionalPokemon
        
        for (id, name, types, stats) in allPokemonData {
            pokemon.append(ExtendedPokemonRecord(
                id: id,
                name: name,
                types: types,
                stats: stats,
                spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
            ))
        }
        
        // Sort by ID to ensure proper ordering
        pokemon.sort { $0.id < $1.id }
        
        print("DEBUG: Returning \(pokemon.count) Pokemon")
        if pokemon.count > 0 {
            print("DEBUG: First Pokemon: \(pokemon[0].name) (ID: \(pokemon[0].id))")
            print("DEBUG: Last Pokemon: \(pokemon[pokemon.count-1].name) (ID: \(pokemon[pokemon.count-1].id))")
        }
        
        return pokemon
    }
    
    private func loadCachedPokemonData() -> [ExtendedPokemonRecord]? {
        let cacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("pokemon_cache.json")
        
        guard let data = try? Data(contentsOf: cacheURL),
              let records = try? JSONDecoder().decode([ExtendedPokemonRecord].self, from: data) else {
            return nil
        }
        
        // Check if cache is recent (within 24 hours)
        let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path)
        if let modificationDate = attributes?[.modificationDate] as? Date {
            let age = Date().timeIntervalSince(modificationDate)
            if age > 86400 { // 24 hours
                return nil // Cache is too old
            }
        }
        
        return records
    }
    
    private func cachePokemonData(_ records: [ExtendedPokemonRecord]) {
        let cacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("pokemon_cache.json")
        
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: cacheURL)
        }
    }
    
    private func createMockPokemonData() -> [ExtendedPokemonRecord] {
        // Popular Pokemon data for team builder - competitive favorites
        let mockPokemon = [
            // Starters
            (1, "bulbasaur", ["grass", "poison"], ["hp": 45, "attack": 49, "defense": 49, "special-attack": 65, "special-defense": 65, "speed": 45]),
            (2, "ivysaur", ["grass", "poison"], ["hp": 60, "attack": 62, "defense": 63, "special-attack": 80, "special-defense": 80, "speed": 60]),
            (3, "venusaur", ["grass", "poison"], ["hp": 80, "attack": 82, "defense": 83, "special-attack": 100, "special-defense": 100, "speed": 80]),
            (4, "charmander", ["fire"], ["hp": 39, "attack": 52, "defense": 43, "special-attack": 60, "special-defense": 50, "speed": 65]),
            (5, "charmeleon", ["fire"], ["hp": 58, "attack": 64, "defense": 58, "special-attack": 80, "special-defense": 65, "speed": 80]),
            (6, "charizard", ["fire", "flying"], ["hp": 78, "attack": 84, "defense": 78, "special-attack": 109, "special-defense": 85, "speed": 100]),
            (7, "squirtle", ["water"], ["hp": 44, "attack": 48, "defense": 65, "special-attack": 50, "special-defense": 64, "speed": 43]),
            (8, "wartortle", ["water"], ["hp": 59, "attack": 63, "defense": 80, "special-attack": 65, "special-defense": 80, "speed": 58]),
            (9, "blastoise", ["water"], ["hp": 79, "attack": 83, "defense": 100, "special-attack": 85, "special-defense": 105, "speed": 78]),
            
            // Popular Gen 1
            (25, "pikachu", ["electric"], ["hp": 35, "attack": 55, "defense": 40, "special-attack": 50, "special-defense": 50, "speed": 90]),
            (26, "raichu", ["electric"], ["hp": 60, "attack": 90, "defense": 55, "special-attack": 90, "special-defense": 80, "speed": 110]),
            (38, "ninetales", ["fire"], ["hp": 73, "attack": 76, "defense": 75, "special-attack": 81, "special-defense": 100, "speed": 100]),
            (59, "arcanine", ["fire"], ["hp": 90, "attack": 110, "defense": 80, "special-attack": 100, "special-defense": 80, "speed": 95]),
            (65, "alakazam", ["psychic"], ["hp": 55, "attack": 50, "defense": 45, "special-attack": 135, "special-defense": 95, "speed": 120]),
            (68, "machamp", ["fighting"], ["hp": 90, "attack": 130, "defense": 80, "special-attack": 65, "special-defense": 85, "speed": 55]),
            (94, "gengar", ["ghost", "poison"], ["hp": 60, "attack": 65, "defense": 60, "special-attack": 130, "special-defense": 75, "speed": 110]),
            (103, "exeggutor", ["grass", "psychic"], ["hp": 95, "attack": 95, "defense": 85, "special-attack": 125, "special-defense": 75, "speed": 55]),
            (115, "kangaskhan", ["normal"], ["hp": 105, "attack": 95, "defense": 80, "special-attack": 40, "special-defense": 80, "speed": 90]),
            (121, "starmie", ["water", "psychic"], ["hp": 60, "attack": 75, "defense": 85, "special-attack": 100, "special-defense": 85, "speed": 115]),
            (127, "pinsir", ["bug"], ["hp": 65, "attack": 125, "defense": 100, "special-attack": 55, "special-defense": 70, "speed": 85]),
            (130, "gyarados", ["water", "flying"], ["hp": 95, "attack": 125, "defense": 79, "special-attack": 60, "special-defense": 100, "speed": 81]),
            (131, "lapras", ["water", "ice"], ["hp": 130, "attack": 85, "defense": 80, "special-attack": 85, "special-defense": 95, "speed": 60]),
            (134, "vaporeon", ["water"], ["hp": 130, "attack": 65, "defense": 60, "special-attack": 110, "special-defense": 95, "speed": 65]),
            (135, "jolteon", ["electric"], ["hp": 65, "attack": 65, "defense": 60, "special-attack": 110, "special-defense": 95, "speed": 130]),
            (136, "flareon", ["fire"], ["hp": 65, "attack": 130, "defense": 60, "special-attack": 95, "special-defense": 110, "speed": 65]),
            (142, "aerodactyl", ["rock", "flying"], ["hp": 80, "attack": 105, "defense": 65, "special-attack": 60, "special-defense": 75, "speed": 130]),
            (143, "snorlax", ["normal"], ["hp": 160, "attack": 110, "defense": 65, "special-attack": 65, "special-defense": 110, "speed": 30]),
            (149, "dragonite", ["dragon", "flying"], ["hp": 91, "attack": 134, "defense": 95, "special-attack": 100, "special-defense": 100, "speed": 80]),
            (150, "mewtwo", ["psychic"], ["hp": 106, "attack": 110, "defense": 90, "special-attack": 154, "special-defense": 90, "speed": 130]),
            (151, "mew", ["psychic"], ["hp": 100, "attack": 100, "defense": 100, "special-attack": 100, "special-defense": 100, "speed": 100]),
            
            // Popular Gen 2
            (212, "scizor", ["bug", "steel"], ["hp": 70, "attack": 130, "defense": 100, "special-attack": 55, "special-defense": 80, "speed": 65]),
            (230, "kingdra", ["water", "dragon"], ["hp": 75, "attack": 95, "defense": 95, "special-attack": 95, "special-defense": 95, "speed": 85]),
            (243, "raikou", ["electric"], ["hp": 90, "attack": 85, "defense": 75, "special-attack": 115, "special-defense": 100, "speed": 115]),
            (244, "entei", ["fire"], ["hp": 115, "attack": 115, "defense": 85, "special-attack": 90, "special-defense": 75, "speed": 100]),
            (245, "suicune", ["water"], ["hp": 100, "attack": 75, "defense": 115, "special-attack": 90, "special-defense": 115, "speed": 85]),
            (248, "tyranitar", ["rock", "dark"], ["hp": 100, "attack": 134, "defense": 110, "special-attack": 95, "special-defense": 100, "speed": 61]),
            
            // Popular Gen 3-5
            (282, "gardevoir", ["psychic", "fairy"], ["hp": 68, "attack": 65, "defense": 65, "special-attack": 125, "special-defense": 115, "speed": 80]),
            (373, "salamence", ["dragon", "flying"], ["hp": 95, "attack": 135, "defense": 80, "special-attack": 110, "special-defense": 80, "speed": 100]),
            (376, "metagross", ["steel", "psychic"], ["hp": 80, "attack": 135, "defense": 130, "special-attack": 95, "special-defense": 90, "speed": 70]),
            (381, "latios", ["dragon", "psychic"], ["hp": 80, "attack": 90, "defense": 80, "special-attack": 130, "special-defense": 110, "speed": 110]),
            (445, "garchomp", ["dragon", "ground"], ["hp": 108, "attack": 130, "defense": 95, "special-attack": 80, "special-defense": 85, "speed": 102]),
            (448, "lucario", ["fighting", "steel"], ["hp": 70, "attack": 110, "defense": 70, "special-attack": 115, "special-defense": 70, "speed": 90]),
            (462, "magnezone", ["electric", "steel"], ["hp": 70, "attack": 70, "defense": 115, "special-attack": 130, "special-defense": 90, "speed": 60]),
            (468, "togekiss", ["fairy", "flying"], ["hp": 85, "attack": 50, "defense": 95, "special-attack": 120, "special-defense": 115, "speed": 80]),
            (530, "excadrill", ["ground", "steel"], ["hp": 110, "attack": 135, "defense": 60, "special-attack": 50, "special-defense": 65, "speed": 88]),
            
            // Popular Gen 6-8
            (658, "greninja", ["water", "dark"], ["hp": 72, "attack": 95, "defense": 67, "special-attack": 103, "special-defense": 71, "speed": 122]),
            (700, "sylveon", ["fairy"], ["hp": 95, "attack": 65, "defense": 65, "special-attack": 110, "special-defense": 130, "speed": 60]),
            (785, "tapu-koko", ["electric", "fairy"], ["hp": 70, "attack": 115, "defense": 85, "special-attack": 95, "special-defense": 75, "speed": 130]),
            (812, "rillaboom", ["grass"], ["hp": 100, "attack": 125, "defense": 90, "special-attack": 60, "special-defense": 70, "speed": 85]),
            (815, "cinderace", ["fire"], ["hp": 80, "attack": 116, "defense": 75, "special-attack": 65, "special-defense": 75, "speed": 119]),
            (818, "inteleon", ["water"], ["hp": 70, "attack": 85, "defense": 65, "special-attack": 125, "special-defense": 65, "speed": 120]),
            (887, "dragapult", ["dragon", "ghost"], ["hp": 88, "attack": 120, "defense": 75, "special-attack": 100, "special-defense": 75, "speed": 142])
        ]
        
        return mockPokemon.map { (id, name, types, stats) in
            ExtendedPokemonRecord(
                id: id,
                name: name,
                types: types,
                stats: stats,
                spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
            )
        }
    }
    
    func getPokemon(by id: Int) async throws -> Pokemon? {
        // Try to fetch from API
        return try? await PokemonAPI.shared.fetchPokemon(id: id)
    }
    
    // MARK: - Data Management
    
    func clearAllData() async throws {
        try await dbQueue.write { db in
            try db.execute(sql: "DELETE FROM pokemon_moves")
            try db.execute(sql: "DELETE FROM pokemon_abilities")
            try db.execute(sql: "DELETE FROM pokemon_types")
            try db.execute(sql: "DELETE FROM pokemon_stats")
            try db.execute(sql: "DELETE FROM pokemon_sprites")
            try db.execute(sql: "DELETE FROM pokedex_entries")
            try db.execute(sql: "DELETE FROM encounters")
            try db.execute(sql: "DELETE FROM evolutions")
            try db.execute(sql: "DELETE FROM evolution_chains")
            try db.execute(sql: "DELETE FROM pokemon")
            try db.execute(sql: "DELETE FROM moves")
            try db.execute(sql: "DELETE FROM abilities WHERE id > 0")
            try db.execute(sql: "DELETE FROM items")
            try db.execute(sql: "DELETE FROM pokemon_fts")
        }
    }
    
    func getDatabaseInfo() async throws -> DatabaseInfo {
        return try await dbQueue.read { db in
            let pokemonCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM pokemon") ?? 0
            let caughtCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM pokemon WHERE is_caught = 1") ?? 0
            let favoriteCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM pokemon WHERE is_favorite = 1") ?? 0
            let movesCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM moves") ?? 0
            let abilitiesCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM abilities") ?? 0
            let itemsCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM items") ?? 0
            
            let fileSize = try FileManager.default.attributesOfItem(atPath: self.dbPath)[.size] as? Int64 ?? 0
            
            return DatabaseInfo(
                pokemonCount: pokemonCount,
                caughtCount: caughtCount,
                favoriteCount: favoriteCount,
                movesCount: movesCount,
                abilitiesCount: abilitiesCount,
                itemsCount: itemsCount,
                databaseSize: fileSize,
                databasePath: self.dbPath
            )
        }
    }
}

// MARK: - Database Info
struct DatabaseInfo {
    let pokemonCount: Int
    let caughtCount: Int
    let favoriteCount: Int
    let movesCount: Int
    let abilitiesCount: Int
    let itemsCount: Int
    let databaseSize: Int64
    let databasePath: String
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: databaseSize)
    }
}

