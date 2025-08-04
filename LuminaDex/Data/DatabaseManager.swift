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

