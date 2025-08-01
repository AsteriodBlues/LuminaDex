import Foundation
import Combine

// MARK: - Repository Protocol
protocol PokemonRepositoryProtocol: Sendable {
    func fetchPokemon(id: Int) async throws -> Pokemon
    func fetchPokemon(name: String) async throws -> Pokemon
    func fetchPokemonList(limit: Int, offset: Int) async throws -> [PokemonListItem]
    func fetchRandomPokemon() async throws -> Pokemon
    func searchPokemon(query: String) async throws -> [PokemonListItem]
    func fetchPokemonByType(_ type: PokemonType) async throws -> [PokemonListItem]
    func fetchAllRegions() async throws -> [RegionListItem]
    func fetchRegion(name: String) async throws -> Region
    
    // Cache management - now async to work with MainActor
    func clearCache() async
    func getCacheInfo() async -> CacheInfo
}

// MARK: - Pokemon Repository Implementation
@MainActor
class PokemonRepository: ObservableObject, PokemonRepositoryProtocol {
    static let shared = PokemonRepository()
    
    private let api = PokemonAPI.shared
    private var pokemonCache: [Int: Pokemon] = [:]
    private var regionCache: [String: Region] = [:]
    private var searchCache: [String: [PokemonListItem]] = [:]
    
    // Publishers for real-time updates
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var recentPokemon: [Pokemon] = []
    @Published var favoriteRegions: [Region] = []
    
    private init() {}
    
    // MARK: - Pokemon Methods
    
    func fetchPokemon(id: Int) async throws -> Pokemon {
        isLoading = true
        defer { isLoading = false }
        
        // Check cache first
        if let cached = pokemonCache[id] {
            return cached
        }
        
        do {
            let pokemon = try await api.fetchPokemon(id: id)
            
            // Cache the result
            pokemonCache[id] = pokemon
            
            // Add to recent
            await MainActor.run {
                addToRecent(pokemon)
            }
            
            return pokemon
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    func fetchPokemon(name: String) async throws -> Pokemon {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let pokemon = try await api.fetchPokemon(name: name)
            
            // Cache by ID
            pokemonCache[pokemon.id] = pokemon
            
            // Add to recent
            await MainActor.run {
                addToRecent(pokemon)
            }
            
            return pokemon
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> [PokemonListItem] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchPokemonList(limit: limit, offset: offset)
            return response.results
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    func fetchRandomPokemon() async throws -> Pokemon {
        // Random Pokemon ID between 1-1010 (current total)
        let randomId = Int.random(in: 1...1010)
        return try await fetchPokemon(id: randomId)
    }
    
    // MARK: - Search Methods
    
    func searchPokemon(query: String) async throws -> [PokemonListItem] {
        let searchKey = query.lowercased()
        
        // Check cache
        if let cached = searchCache[searchKey] {
            return cached
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch a large list and filter locally for better performance
            let response = try await api.fetchPokemonList(limit: 1000, offset: 0)
            let filtered = response.results.filter { pokemon in
                pokemon.name.localizedCaseInsensitiveContains(query)
            }
            
            // Cache the search result
            searchCache[searchKey] = filtered
            
            return filtered
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    func fetchPokemonByType(_ type: PokemonType) async throws -> [PokemonListItem] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchPokemonByType(type)
            let pokemonList = response.pokemon.map { typePokemon in
                PokemonListItem(
                    name: typePokemon.pokemon.name,
                    url: typePokemon.pokemon.url
                )
            }
            return pokemonList
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    // MARK: - Region Methods
    
    func fetchAllRegions() async throws -> [RegionListItem] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchAllRegions()
            return response.results
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    func fetchRegion(name: String) async throws -> Region {
        // Check cache
        if let cached = regionCache[name] {
            return cached
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let region = try await api.fetchRegion(name: name)
            
            // Cache the result
            regionCache[name] = region
            
            return region
        } catch let apiError as APIError {
            error = apiError
            throw apiError
        }
    }
    
    // MARK: - Advanced Features
    
    func fetchPokemonBatch(ids: [Int]) async throws -> [Pokemon] {
        var results: [Pokemon] = []
        
        for id in ids {
            do {
                let pokemon = try await fetchPokemon(id: id)
                results.append(pokemon)
                
                // Small delay to avoid overwhelming the API
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            } catch {
                print("⚠️ Failed to fetch Pokemon \(id): \(error)")
                continue
            }
        }
        
        return results
    }
    
    func getPopularPokemon() async throws -> [Pokemon] {
        // Fetch some popular/iconic Pokemon
        let popularIds = [25, 1, 4, 7, 150, 151, 249, 250, 384, 483, 644, 649]
        return try await fetchPokemonBatch(ids: popularIds)
    }
    
    func getStarterPokemon() async throws -> [Pokemon] {
        // All starter Pokemon IDs
        let starterIds = [1, 4, 7, 152, 155, 158, 252, 255, 258, 387, 390, 393, 495, 498, 501, 650, 653, 656, 722, 725, 728, 810, 813, 816, 906, 909, 912]
        return try await fetchPokemonBatch(ids: starterIds)
    }
    
    // MARK: - Cache Management
    
    func clearCache() async {
        pokemonCache.removeAll()
        regionCache.removeAll()
        searchCache.removeAll()
        api.clearCache()
        recentPokemon.removeAll()
    }
    
    func getCacheInfo() async -> CacheInfo {
        CacheInfo(
            pokemonCount: pokemonCache.count,
            regionCount: regionCache.count,
            searchCount: searchCache.count,
            diskUsage: api.getCacheSize()
        )
    }
    
    // MARK: - Helper Methods
    
    private func addToRecent(_ pokemon: Pokemon) {
        // Remove if already exists
        recentPokemon.removeAll { $0.id == pokemon.id }
        
        // Add to beginning
        recentPokemon.insert(pokemon, at: 0)
        
        // Keep only last 10
        if recentPokemon.count > 10 {
            recentPokemon = Array(recentPokemon.prefix(10))
        }
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Statistics
    
    func getRepositoryStats() -> RepositoryStats {
        RepositoryStats(
            totalPokemonCached: pokemonCache.count,
            totalRegionsCached: regionCache.count,
            recentPokemonCount: recentPokemon.count,
            searchesCached: searchCache.count,
            cacheHitRate: calculateCacheHitRate()
        )
    }
    
    private func calculateCacheHitRate() -> Double {
        // Simple cache hit rate calculation
        // In a real app, you'd track hits vs misses
        let totalCached = pokemonCache.count + regionCache.count
        return totalCached > 0 ? Double(totalCached) / Double(totalCached + 10) : 0.0
    }
}

// MARK: - Supporting Models

struct CacheInfo {
    let pokemonCount: Int
    let regionCount: Int
    let searchCount: Int
    let diskUsage: Int
    
    var formattedDiskUsage: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(diskUsage))
    }
}

struct RepositoryStats {
    let totalPokemonCached: Int
    let totalRegionsCached: Int
    let recentPokemonCount: Int
    let searchesCached: Int
    let cacheHitRate: Double
    
    var formattedCacheHitRate: String {
        return String(format: "%.1f%%", cacheHitRate * 100)
    }
}

// MARK: - Repository Extensions

extension PokemonRepository {
    
    // Convenience methods for UI
    func isLoading(_ show: Bool) {
        isLoading = show
    }
    
    func hasError() -> Bool {
        return error != nil
    }
    
    func getErrorMessage() -> String {
        return error?.localizedDescription ?? "Unknown error"
    }
    
    func getRecoverySuggestion() -> String {
        return error?.recoverySuggestion ?? "Please try again"
    }
}
