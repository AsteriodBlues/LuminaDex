import Foundation
import GRDB

// MARK: - Database Migrations
struct DatabaseMigrations {
    
    static func setupMigrations() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration v1.0: Initial database setup
        migrator.registerMigration("v1.0") { db in
            try createInitialTables(db)
            try populateDefaultData(db)
        }
        
        // Migration v1.1: Add FTS (Full-Text Search) support
        migrator.registerMigration("v1.1") { db in
            try setupFullTextSearch(db)
        }
        
        return migrator
    }
    
    // MARK: - Initial Tables Creation
    
    private static func createInitialTables(_ db: Database) throws {
        // Types table (must be first due to foreign keys)
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
        
        // Evolution chains table
        try db.execute(sql: """
            CREATE TABLE IF NOT EXISTS evolution_chains (
                id INTEGER PRIMARY KEY NOT NULL,
                baby_trigger_item_id INTEGER,
                created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        // Pokemon table
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
        
        // Abilities table
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
        
        // Moves table
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
        
        // Items table
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
        
        // Evolutions table
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
        
        // Pokemon sprites table
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
        
        // Pokemon stats table
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
        
        // Pokemon types relationship table
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
        
        // Pokemon abilities relationship table
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
        
        // Pokemon moves relationship table
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
        
        // Encounters table
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
        
        // Pokedex entries table
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
        
        // Full-text search table
        try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS pokemon_fts USING fts5(
                name, 
                content='pokemon',
                content_rowid='id'
            )
        """)
        
        // FTS triggers
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
        
        // Create all indexes
        try createIndexes(db)
    }
    
    // MARK: - Indexes Creation
    
    private static func createIndexes(_ db: Database) throws {
        // Pokemon indexes
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_name ON pokemon(name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_generation ON pokemon(generation)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_caught ON pokemon(is_caught)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_favorite ON pokemon(is_favorite)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_evolution_chain ON pokemon(evolution_chain_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_legendary ON pokemon(is_legendary)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_is_mythical ON pokemon(is_mythical)")
        
        // Type relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_types_pokemon ON pokemon_types(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_types_type ON pokemon_types(type_id)")
        
        // Ability relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_pokemon ON pokemon_abilities(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_ability ON pokemon_abilities(ability_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_abilities_hidden ON pokemon_abilities(is_hidden)")
        
        // Move relationships
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_pokemon ON pokemon_moves(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_move ON pokemon_moves(move_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_method ON pokemon_moves(learn_method)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_moves_version ON pokemon_moves(version_group)")
        
        // Stats
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_stats_pokemon ON pokemon_stats(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokemon_stats_stat ON pokemon_stats(stat_name)")
        
        // Encounters
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_pokemon ON encounters(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_location ON encounters(location_area)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_method ON encounters(method)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_encounters_version ON encounters(version)")
        
        // Pokedex entries
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_pokemon ON pokedex_entries(pokemon_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_pokedex ON pokedex_entries(pokedex_name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_language ON pokedex_entries(language)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_pokedex_entries_version ON pokedex_entries(version)")
        
        // Evolutions
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_chain ON evolutions(evolution_chain_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_from ON evolutions(evolves_from_species_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_to ON evolutions(evolves_to_species_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_evolutions_trigger ON evolutions(evolution_trigger)")
        
        // Moves
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_moves_name ON moves(name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_moves_type ON moves(type_id)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_moves_generation ON moves(generation)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_moves_damage_class ON moves(damage_class)")
        
        // Abilities
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_abilities_name ON abilities(name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_abilities_generation ON abilities(generation)")
        
        // Items
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_items_name ON items(name)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_items_category ON items(category)")
        try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_items_generation ON items(generation)")
    }
    
    // MARK: - Default Data Population
    
    private static func populateDefaultData(_ db: Database) throws {
        // Insert Pokemon types with proper colors
        let types: [(Int, String, String, Int)] = [
            (1, "normal", "#A8A878", 1),
            (2, "fighting", "#C03028", 1),
            (3, "flying", "#A890F0", 1),
            (4, "poison", "#A040A0", 1),
            (5, "ground", "#E0C068", 1),
            (6, "rock", "#B8A038", 1),
            (7, "bug", "#A8B820", 1),
            (8, "ghost", "#705898", 1),
            (9, "steel", "#B8B8D0", 2),
            (10, "fire", "#F08030", 1),
            (11, "water", "#6890F0", 1),
            (12, "grass", "#78C850", 1),
            (13, "electric", "#F8D030", 1),
            (14, "psychic", "#F85888", 1),
            (15, "ice", "#98D8D8", 1),
            (16, "dragon", "#7038F8", 1),
            (17, "dark", "#705848", 2),
            (18, "fairy", "#EE99AC", 6),
            (10001, "unknown", "#68A090", 3),
            (10002, "shadow", "#604E82", 3)
        ]
        
        for (id, name, color, generation) in types {
            try db.execute(sql: """
                INSERT OR IGNORE INTO types (id, name, color, generation, created_at) 
                VALUES (?, ?, ?, ?, ?)
            """, arguments: [id, name, color, generation, ISO8601DateFormatter().string(from: Date())])
        }
        
        print("✅ Populated \(types.count) Pokemon types")
    }
    
    // MARK: - Full-Text Search Setup
    
    private static func setupFullTextSearch(_ db: Database) throws {
        // Add FTS for moves
        try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS moves_fts USING fts5(
                name,
                effect,
                short_effect,
                content='moves',
                content_rowid='id'
            )
        """)
        
        // Add FTS for abilities
        try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS abilities_fts USING fts5(
                name,
                effect,
                short_effect,
                content='abilities', 
                content_rowid='id'
            )
        """)
        
        // Add FTS for items
        try db.execute(sql: """
            CREATE VIRTUAL TABLE IF NOT EXISTS items_fts USING fts5(
                name,
                effect,
                short_effect,
                content='items',
                content_rowid='id'
            )
        """)
        
        // Moves FTS triggers
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS moves_fts_insert AFTER INSERT ON moves BEGIN
                INSERT INTO moves_fts(rowid, name, effect, short_effect) 
                VALUES (new.id, new.name, new.effect, new.short_effect);
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS moves_fts_update AFTER UPDATE ON moves BEGIN
                UPDATE moves_fts SET name = new.name, effect = new.effect, short_effect = new.short_effect
                WHERE rowid = new.id;
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS moves_fts_delete AFTER DELETE ON moves BEGIN
                DELETE FROM moves_fts WHERE rowid = old.id;
            END
        """)
        
        // Abilities FTS triggers
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS abilities_fts_insert AFTER INSERT ON abilities BEGIN
                INSERT INTO abilities_fts(rowid, name, effect, short_effect) 
                VALUES (new.id, new.name, new.effect, new.short_effect);
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS abilities_fts_update AFTER UPDATE ON abilities BEGIN
                UPDATE abilities_fts SET name = new.name, effect = new.effect, short_effect = new.short_effect
                WHERE rowid = new.id;
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS abilities_fts_delete AFTER DELETE ON abilities BEGIN
                DELETE FROM abilities_fts WHERE rowid = old.id;
            END
        """)
        
        // Items FTS triggers  
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS items_fts_insert AFTER INSERT ON items BEGIN
                INSERT INTO items_fts(rowid, name, effect, short_effect) 
                VALUES (new.id, new.name, new.effect, new.short_effect);
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS items_fts_update AFTER UPDATE ON items BEGIN
                UPDATE items_fts SET name = new.name, effect = new.effect, short_effect = new.short_effect
                WHERE rowid = new.id;
            END
        """)
        
        try db.execute(sql: """
            CREATE TRIGGER IF NOT EXISTS items_fts_delete AFTER DELETE ON items BEGIN
                DELETE FROM items_fts WHERE rowid = old.id;
            END
        """)
        
        // Populate existing data into FTS tables
        try db.execute(sql: """
            INSERT INTO moves_fts(rowid, name, effect, short_effect)
            SELECT id, name, effect, short_effect FROM moves
        """)
        
        try db.execute(sql: """
            INSERT INTO abilities_fts(rowid, name, effect, short_effect) 
            SELECT id, name, effect, short_effect FROM abilities
        """)
        
        try db.execute(sql: """
            INSERT INTO items_fts(rowid, name, effect, short_effect)
            SELECT id, name, effect, short_effect FROM items  
        """)
        
        print("✅ Enhanced FTS setup completed for Pokemon, moves, abilities, and items")
    }
}

// MARK: - DatabaseManager Migration Extension
extension DatabaseManager {
    
    func runMigrations() throws {
        let migrator = DatabaseMigrations.setupMigrations()
        try migrator.migrate(dbQueue)
        print("✅ Database migrations completed successfully")
    }
    
    func getCurrentDatabaseVersion() throws -> Int {
        return try dbQueue.read { db in
            try Int.fetchOne(db, sql: "PRAGMA user_version") ?? 0
        }
    }
    
    func checkMigrationStatus() throws -> MigrationStatus {
        let currentVersion = try getCurrentDatabaseVersion()
        let targetVersion = Self.currentDatabaseVersion
        
        return MigrationStatus(
            currentVersion: currentVersion,
            targetVersion: targetVersion,
            needsMigration: currentVersion < targetVersion
        )
    }
}

// MARK: - Migration Status
struct MigrationStatus {
    let currentVersion: Int
    let targetVersion: Int
    let needsMigration: Bool
    
    var statusDescription: String {
        if needsMigration {
            return "Migration needed: v\(currentVersion) → v\(targetVersion)"
        } else {
            return "Database up to date: v\(currentVersion)"
        }
    }
}