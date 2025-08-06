//
//  QuantumSearchEngine.swift
//  LuminaDex
//
//  Real-time search engine with PokeAPI integration
//

import SwiftUI
import Combine

// MARK: - Search Result Model
struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: ResultType
    let imageURL: String?
    let tags: [String]
    let color: Color
    let icon: String
    let data: Any?
    
    enum ResultType {
        case pokemon
        case move
        case ability
        case item
        case type
    }
}

// MARK: - Quantum Search Engine
@MainActor
class QuantumSearchEngine: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var recentSearches: [String] = []
    @Published var trendingSearches: [String] = []
    @Published var uniqueTypes: Set<String> = []
    @Published var generationRange = ""
    
    private var searchTask: Task<Void, Never>?
    private let api = PokemonAPI.shared
    private let cache = SearchCache()
    
    init() {
        loadRecentSearches()
        loadTrendingSearches()
    }
    
    // MARK: - Main Search
    func search(query: String, category: QuantumSearchView.SearchCategory) {
        guard !query.isEmpty else {
            clearResults()
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        // Check cache first
        if let cached = cache.get(for: query, category: category) {
            self.searchResults = cached
            updateStats(from: cached)
            return
        }
        
        // Start new search
        searchTask = Task {
            await performSearch(query: query, category: category)
        }
    }
    
    private func performSearch(query: String, category: QuantumSearchView.SearchCategory) async {
        isSearching = true
        var results: [SearchResult] = []
        
        do {
            switch category {
            case .all:
                // Search all categories in parallel
                async let pokemonResults = searchPokemon(query: query)
                async let moveResults = searchMoves(query: query)
                async let abilityResults = searchAbilities(query: query)
                
                let allResults = await (pokemonResults, moveResults, abilityResults)
                results = allResults.0 + allResults.1 + allResults.2
                
            case .pokemon:
                results = await searchPokemon(query: query)
                
            case .moves:
                results = await searchMoves(query: query)
                
            case .abilities:
                results = await searchAbilities(query: query)
                
            case .items:
                results = await searchItems(query: query)
                
            case .types:
                results = await searchTypes(query: query)
            }
            
            // Sort by relevance
            results.sort { result1, result2 in
                let relevance1 = calculateRelevance(for: result1.title, query: query)
                let relevance2 = calculateRelevance(for: result2.title, query: query)
                return relevance1 > relevance2
            }
            
            // Update UI
            await MainActor.run {
                withAnimation(.spring()) {
                    self.searchResults = results
                    self.cache.set(results, for: query, category: category)
                    self.updateStats(from: results)
                    self.addToRecentSearches(query)
                    self.isSearching = false
                }
            }
            
        } catch {
            await MainActor.run {
                self.isSearching = false
                print("Search error: \(error)")
            }
        }
    }
    
    // MARK: - Pokemon Search
    private func searchPokemon(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        do {
            // Try exact match first
            if let pokemon = try? await api.fetchPokemon(name: query.lowercased()) {
                results.append(createPokemonResult(from: pokemon))
            }
            
            // Search by ID if query is numeric
            if let id = Int(query), id > 0 && id <= 1025 {
                if let pokemon = try? await api.fetchPokemon(id: id) {
                    results.append(createPokemonResult(from: pokemon))
                }
            }
            
            // Search by type
            let allTypes = PokemonType.allCases.filter { $0 != .unknown }
            for type in allTypes {
                if type.rawValue.contains(query.lowercased()) {
                    let typeResults = await searchPokemonByType(type)
                    results.append(contentsOf: typeResults.prefix(5))
                }
            }
            
            // Fuzzy search through cached/known Pokemon
            let fuzzyResults = await fuzzySearchPokemon(query: query)
            results.append(contentsOf: fuzzyResults)
            
        } catch {
            print("Pokemon search error: \(error)")
        }
        
        return Array(results.prefix(20))
    }
    
    private func searchPokemonByType(_ type: PokemonType) async -> [SearchResult] {
        // In a real implementation, this would query the API
        // For now, return mock results
        return []
    }
    
    private func fuzzySearchPokemon(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        // Common Pokemon that might match
        let commonPokemon = [
            "pikachu", "charizard", "bulbasaur", "squirtle", "charmander",
            "mewtwo", "mew", "eevee", "snorlax", "dragonite", "gengar",
            "alakazam", "machamp", "gyarados", "lapras", "ditto"
        ]
        
        for name in commonPokemon {
            if name.contains(query.lowercased()) {
                if let pokemon = try? await api.fetchPokemon(name: name) {
                    results.append(createPokemonResult(from: pokemon))
                }
            }
        }
        
        return results
    }
    
    private func createPokemonResult(from pokemon: Pokemon) -> SearchResult {
        let types = pokemon.types.map { $0.pokemonType.rawValue.capitalized }
        let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
        
        return SearchResult(
            title: pokemon.displayName,
            subtitle: "#\(String(format: "%03d", pokemon.id)) • \(types.joined(separator: ", "))",
            type: .pokemon,
            imageURL: pokemon.sprites.officialArtwork,
            tags: types + ["Stats: \(totalStats)"],
            color: pokemon.primaryType.color,
            icon: "flame",
            data: pokemon
        )
    }
    
    // MARK: - Move Search
    private func searchMoves(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        // Mock implementation - would connect to real API
        let mockMoves = [
            ("Thunder Bolt", "Electric", 90, 100),
            ("Flamethrower", "Fire", 90, 100),
            ("Ice Beam", "Ice", 90, 100),
            ("Psychic", "Psychic", 90, 100),
            ("Earthquake", "Ground", 100, 100)
        ]
        
        for (name, type, power, accuracy) in mockMoves {
            if name.lowercased().contains(query.lowercased()) {
                results.append(SearchResult(
                    title: name,
                    subtitle: "\(type) • Power: \(power) • Accuracy: \(accuracy)%",
                    type: .move,
                    imageURL: nil,
                    tags: [type, "Physical"],
                    color: .yellow,
                    icon: "bolt",
                    data: nil
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Ability Search
    private func searchAbilities(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        // Mock implementation
        let mockAbilities = [
            ("Levitate", "Immune to Ground-type moves"),
            ("Intimidate", "Lowers opponent's Attack"),
            ("Pressure", "Increases PP usage"),
            ("Adaptability", "Increases STAB bonus"),
            ("Blaze", "Powers up Fire-type moves when HP is low")
        ]
        
        for (name, description) in mockAbilities {
            if name.lowercased().contains(query.lowercased()) {
                results.append(SearchResult(
                    title: name,
                    subtitle: description,
                    type: .ability,
                    imageURL: nil,
                    tags: ["Ability"],
                    color: .purple,
                    icon: "sparkles",
                    data: nil
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Item Search
    private func searchItems(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        // Mock implementation
        let mockItems = [
            ("Poké Ball", "Standard ball for catching Pokémon"),
            ("Great Ball", "Better catch rate than Poké Ball"),
            ("Ultra Ball", "High performance ball"),
            ("Master Ball", "Catches any Pokémon without fail"),
            ("Potion", "Restores 20 HP")
        ]
        
        for (name, description) in mockItems {
            if name.lowercased().contains(query.lowercased()) {
                results.append(SearchResult(
                    title: name,
                    subtitle: description,
                    type: .item,
                    imageURL: nil,
                    tags: ["Item"],
                    color: .green,
                    icon: "bag",
                    data: nil
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Type Search
    private func searchTypes(query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        
        for type in PokemonType.allCases where type != .unknown {
            if type.rawValue.contains(query.lowercased()) {
                results.append(SearchResult(
                    title: type.rawValue.capitalized,
                    subtitle: "Pokémon Type",
                    type: .type,
                    imageURL: nil,
                    tags: ["Type"],
                    color: type.color,
                    icon: "tag",
                    data: type
                ))
            }
        }
        
        return results
    }
    
    // MARK: - Special Searches
    func searchLegendary() {
        Task {
            isSearching = true
            var results: [SearchResult] = []
            
            let legendaryIds = [144, 145, 146, 150, 151, 243, 244, 245, 249, 250, 251]
            
            for id in legendaryIds {
                if let pokemon = try? await api.fetchPokemon(id: id) {
                    results.append(createPokemonResult(from: pokemon))
                }
            }
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.searchResults = results
                    self.isSearching = false
                }
            }
        }
    }
    
    func searchStarters() {
        Task {
            isSearching = true
            var results: [SearchResult] = []
            
            let starterIds = [1, 4, 7, 152, 155, 158, 252, 255, 258]
            
            for id in starterIds {
                if let pokemon = try? await api.fetchPokemon(id: id) {
                    results.append(createPokemonResult(from: pokemon))
                }
            }
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.searchResults = results
                    self.isSearching = false
                }
            }
        }
    }
    
    func searchRandom() {
        Task {
            isSearching = true
            let randomId = Int.random(in: 1...1025)
            
            if let pokemon = try? await api.fetchPokemon(id: randomId) {
                await MainActor.run {
                    withAnimation(.spring()) {
                        self.searchResults = [createPokemonResult(from: pokemon)]
                        self.isSearching = false
                    }
                }
            }
        }
    }
    
    func searchShiny() {
        // This would show Pokemon with their shiny variants
        Task {
            isSearching = true
            var results: [SearchResult] = []
            
            // Get some random Pokemon and mark them as shiny
            for _ in 0..<10 {
                let randomId = Int.random(in: 1...151)
                if let pokemon = try? await api.fetchPokemon(id: randomId) {
                    var result = createPokemonResult(from: pokemon)
                    // Modify to show shiny sprite
                    result = SearchResult(
                        title: "✨ \(result.title)",
                        subtitle: result.subtitle + " (Shiny)",
                        type: result.type,
                        imageURL: pokemon.sprites.frontShiny ?? result.imageURL,
                        tags: result.tags + ["Shiny"],
                        color: .yellow,
                        icon: "sparkles",
                        data: result.data
                    )
                    results.append(result)
                }
            }
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.searchResults = results
                    self.isSearching = false
                }
            }
        }
    }
    
    // MARK: - Filters
    func applyFilters(type: PokemonType?, generation: Int?, minStats: Int, ability: String, move: String) {
        // Filter current results based on criteria
        var filtered = searchResults
        
        if let type = type {
            filtered = filtered.filter { result in
                result.tags.contains(type.rawValue.capitalized)
            }
        }
        
        if minStats > 0 {
            filtered = filtered.filter { result in
                if let statsTag = result.tags.first(where: { $0.starts(with: "Stats:") }),
                   let stats = Int(statsTag.replacingOccurrences(of: "Stats: ", with: "")) {
                    return stats >= minStats
                }
                return false
            }
        }
        
        withAnimation(.spring()) {
            searchResults = filtered
        }
    }
    
    // MARK: - Helper Methods
    private func calculateRelevance(for title: String, query: String) -> Double {
        let lowercasedTitle = title.lowercased()
        let lowercasedQuery = query.lowercased()
        
        if lowercasedTitle == lowercasedQuery {
            return 1.0
        } else if lowercasedTitle.hasPrefix(lowercasedQuery) {
            return 0.8
        } else if lowercasedTitle.contains(lowercasedQuery) {
            return 0.6
        } else {
            return 0.0
        }
    }
    
    private func updateStats(from results: [SearchResult]) {
        // Update unique types
        uniqueTypes.removeAll()
        for result in results {
            for tag in result.tags {
                if PokemonType.allCases.map({ $0.rawValue.capitalized }).contains(tag) {
                    uniqueTypes.insert(tag)
                }
            }
        }
        
        // Update generation range
        if !results.isEmpty {
            generationRange = "I-IX"
        } else {
            generationRange = ""
        }
    }
    
    func clearResults() {
        withAnimation(.spring()) {
            searchResults = []
            uniqueTypes.removeAll()
            generationRange = ""
        }
    }
    
    // MARK: - Recent Searches
    private func addToRecentSearches(_ query: String) {
        if !recentSearches.contains(query) {
            recentSearches.insert(query, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
            saveRecentSearches()
        }
    }
    
    private func loadRecentSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: "recentSearches") {
            recentSearches = saved
        }
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
    
    func clearHistory() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    // MARK: - Trending
    private func loadTrendingSearches() {
        // These would come from analytics or a backend
        trendingSearches = [
            "Pikachu",
            "Legendary",
            "Shiny",
            "Dragon Type",
            "Mega Evolution",
            "Starters"
        ]
    }
}

// MARK: - Search Cache
class SearchCache {
    private var cache: [String: [SearchResult]] = [:]
    private let maxCacheSize = 50
    
    func get(for query: String, category: QuantumSearchView.SearchCategory) -> [SearchResult]? {
        let key = "\(category.rawValue)_\(query)"
        return cache[key]
    }
    
    func set(_ results: [SearchResult], for query: String, category: QuantumSearchView.SearchCategory) {
        let key = "\(category.rawValue)_\(query)"
        cache[key] = results
        
        // Limit cache size
        if cache.count > maxCacheSize {
            // Remove the oldest entry
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
    }
    
    func clear() {
        cache.removeAll()
    }
}