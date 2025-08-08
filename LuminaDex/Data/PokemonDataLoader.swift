//
//  PokemonDataLoader.swift
//  LuminaDex
//
//  Efficient Pokemon data loader for Team Builder
//

import Foundation
import SwiftUI

@MainActor
class PokemonDataLoader: ObservableObject {
    static let shared = PokemonDataLoader()
    
    @Published var allPokemon: [ExtendedPokemonRecord] = []
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0
    @Published var errorMessage: String?
    
    private let api = PokemonAPI.shared
    private let cacheKey = "pokemon_data_cache_v2"
    
    private init() {
        Task {
            await loadPokemonData()
        }
    }
    
    func loadPokemonData() async {
        isLoading = true
        loadingProgress = 0
        errorMessage = nil
        
        // Try to load from cache first
        if let cachedData = loadFromCache() {
            allPokemon = cachedData
            isLoading = false
            return
        }
        
        // Otherwise fetch from API
        await fetchAllPokemonFromAPI()
    }
    
    private func fetchAllPokemonFromAPI() async {
        var pokemonData: [ExtendedPokemonRecord] = []
        
        do {
            // First, get the list of all Pokemon
            let response = try await api.fetchPokemonList(limit: 1025, offset: 0)
            let totalCount = response.results.count
            
            // Process in smaller batches for better performance
            let batchSize = 20
            var processedCount = 0
            
            for batch in response.results.chunked(into: batchSize) {
                await withTaskGroup(of: ExtendedPokemonRecord?.self) { group in
                    for item in batch {
                        group.addTask { [weak self] in
                            await self?.fetchPokemonDetails(from: item)
                        }
                    }
                    
                    for await pokemon in group {
                        if let pokemon = pokemon {
                            pokemonData.append(pokemon)
                        }
                    }
                }
                
                processedCount += batch.count
                await MainActor.run {
                    self.loadingProgress = Double(processedCount) / Double(totalCount)
                }
                
                // Small delay to avoid rate limiting
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            }
            
            // Sort by ID
            pokemonData.sort { $0.id < $1.id }
            
            // Save to cache
            saveToCache(pokemonData)
            
            await MainActor.run {
                self.allPokemon = pokemonData
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load Pokemon: \(error.localizedDescription)"
                self.isLoading = false
                // Load mock data as fallback
                self.allPokemon = createFallbackData()
            }
        }
    }
    
    private func fetchPokemonDetails(from item: PokemonListItem) async -> ExtendedPokemonRecord? {
        // Extract ID from URL
        let components = item.url.split(separator: "/")
        guard let idString = components.dropLast().last,
              let id = Int(idString) else { return nil }
        
        do {
            // Fetch full Pokemon data
            let pokemon = try await api.fetchPokemon(id: id)
            
            // Extract types
            let types = pokemon.types.sorted { $0.slot < $1.slot }
                .compactMap { $0.pokemonType.rawValue }
            
            // Extract stats
            var stats: [String: Int] = [:]
            for stat in pokemon.stats {
                stats[stat.stat.name] = stat.baseStat
            }
            
            return ExtendedPokemonRecord(
                id: pokemon.id,
                name: pokemon.name,
                types: types,
                stats: stats,
                spriteUrl: pokemon.sprites.frontDefault ?? 
                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png"
            )
        } catch {
            // If individual fetch fails, return basic data
            return ExtendedPokemonRecord(
                id: id,
                name: item.name,
                types: [],
                stats: [:],
                spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
            )
        }
    }
    
    private func loadFromCache() -> [ExtendedPokemonRecord]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedPokemonData.self, from: data) else {
            return nil
        }
        
        // Check if cache is recent (within 7 days)
        let age = Date().timeIntervalSince(cached.timestamp)
        if age > 604800 { // 7 days
            return nil
        }
        
        return cached.pokemon
    }
    
    private func saveToCache(_ pokemon: [ExtendedPokemonRecord]) {
        let cached = CachedPokemonData(pokemon: pokemon, timestamp: Date())
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
    
    private func createFallbackData() -> [ExtendedPokemonRecord] {
        // Return the most popular Pokemon as fallback
        return [
            ExtendedPokemonRecord(id: 1, name: "bulbasaur", types: ["grass", "poison"], stats: ["hp": 45, "attack": 49, "defense": 49, "special-attack": 65, "special-defense": 65, "speed": 45], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"),
            ExtendedPokemonRecord(id: 4, name: "charmander", types: ["fire"], stats: ["hp": 39, "attack": 52, "defense": 43, "special-attack": 60, "special-defense": 50, "speed": 65], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png"),
            ExtendedPokemonRecord(id: 7, name: "squirtle", types: ["water"], stats: ["hp": 44, "attack": 48, "defense": 65, "special-attack": 50, "special-defense": 64, "speed": 43], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png"),
            ExtendedPokemonRecord(id: 25, name: "pikachu", types: ["electric"], stats: ["hp": 35, "attack": 55, "defense": 40, "special-attack": 50, "special-defense": 50, "speed": 90], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png"),
            ExtendedPokemonRecord(id: 94, name: "gengar", types: ["ghost", "poison"], stats: ["hp": 60, "attack": 65, "defense": 60, "special-attack": 130, "special-defense": 75, "speed": 110], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/94.png"),
            ExtendedPokemonRecord(id: 150, name: "mewtwo", types: ["psychic"], stats: ["hp": 106, "attack": 110, "defense": 90, "special-attack": 154, "special-defense": 90, "speed": 130], spriteUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/150.png")
        ]
    }
}

// MARK: - Helper Models
private struct CachedPokemonData: Codable {
    let pokemon: [ExtendedPokemonRecord]
    let timestamp: Date
}

