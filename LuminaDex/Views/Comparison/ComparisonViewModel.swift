//
//  ComparisonViewModel.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import Foundation
import SwiftUI

@MainActor
class ComparisonViewModel: ObservableObject {
    @Published var selectedPokemon: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let maxPokemon = 6
    private let minPokemon = 2
    
    var canCompare: Bool {
        selectedPokemon.count >= minPokemon
    }
    
    var hasMaxPokemon: Bool {
        selectedPokemon.count >= maxPokemon
    }
    
    func addPokemon(_ pokemon: Pokemon) {
        guard selectedPokemon.count < maxPokemon else { return }
        guard !selectedPokemon.contains(where: { $0.id == pokemon.id }) else { return }
        
        selectedPokemon.append(pokemon)
    }
    
    func addPokemon(_ pokemon: Pokemon, at index: Int) {
        guard index <= selectedPokemon.count else { return }
        guard !selectedPokemon.contains(where: { $0.id == pokemon.id }) else { return }
        
        if index < selectedPokemon.count {
            selectedPokemon[index] = pokemon
        } else {
            selectedPokemon.append(pokemon)
        }
    }
    
    func removePokemon(at index: Int) {
        guard index < selectedPokemon.count else { return }
        selectedPokemon.remove(at: index)
    }
    
    func removePokemon(_ pokemon: Pokemon) {
        selectedPokemon.removeAll { $0.id == pokemon.id }
    }
    
    func clearAll() {
        selectedPokemon.removeAll()
    }
    
    func movePokemon(from source: IndexSet, to destination: Int) {
        selectedPokemon.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Comparison Analytics
    
    var statComparisons: [StatComparison] {
        guard selectedPokemon.count >= 2 else { return [] }
        
        var comparisons: [StatComparison] = []
        
        for i in 0..<selectedPokemon.count {
            for j in (i+1)..<selectedPokemon.count {
                let pokemon1 = selectedPokemon[i]
                let pokemon2 = selectedPokemon[j]
                
                let stats1 = extractStats(from: pokemon1)
                let stats2 = extractStats(from: pokemon2)
                
                comparisons.append(StatComparison(pokemon1: stats1, pokemon2: stats2))
            }
        }
        
        return comparisons
    }
    
    var overallWinner: Pokemon? {
        guard selectedPokemon.count >= 2 else { return nil }
        
        return selectedPokemon.max { pokemon1, pokemon2 in
            let total1 = pokemon1.stats.reduce(0) { $0 + $1.baseStat }
            let total2 = pokemon2.stats.reduce(0) { $0 + $1.baseStat }
            return total1 < total2
        }
    }
    
    func getStatWinner(for statName: String) -> Pokemon? {
        guard selectedPokemon.count >= 2 else { return nil }
        
        return selectedPokemon.max { pokemon1, pokemon2 in
            let stat1 = pokemon1.stats.first { $0.stat.name == statName }?.baseStat ?? 0
            let stat2 = pokemon2.stats.first { $0.stat.name == statName }?.baseStat ?? 0
            return stat1 < stat2
        }
    }
    
    func getStatValue(for pokemon: Pokemon, statName: String) -> Int {
        pokemon.stats.first { $0.stat.name == statName }?.baseStat ?? 0
    }
    
    // MARK: - Type Analysis
    
    var typeDistribution: [PokemonType: Int] {
        var distribution: [PokemonType: Int] = [:]
        
        for pokemon in selectedPokemon {
            for typeSlot in pokemon.types {
                let type = typeSlot.pokemonType
                distribution[type, default: 0] += 1
            }
        }
        
        return distribution
    }
    
    var mostCommonType: PokemonType? {
        typeDistribution.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Helper Methods
    
    private func extractStats(from pokemon: Pokemon) -> PokemonStats {
        let hp = pokemon.stats.first { $0.stat.name == "hp" }?.baseStat ?? 0
        let attack = pokemon.stats.first { $0.stat.name == "attack" }?.baseStat ?? 0
        let defense = pokemon.stats.first { $0.stat.name == "defense" }?.baseStat ?? 0
        let specialAttack = pokemon.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0
        let specialDefense = pokemon.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0
        let speed = pokemon.stats.first { $0.stat.name == "speed" }?.baseStat ?? 0
        
        return PokemonStats(
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: specialAttack,
            specialDefense: specialDefense,
            speed: speed
        )
    }
    
    // MARK: - Size Comparison
    
    func getRelativeScale(for pokemon: Pokemon) -> Double {
        guard let maxHeight = selectedPokemon.map(\.height).max(),
              maxHeight > 0 else { return 1.0 }
        
        let minScale = 0.3
        let maxScale = 1.0
        
        let heightRatio = Double(pokemon.height) / Double(maxHeight)
        return minScale + (maxScale - minScale) * heightRatio
    }
    
    func getTallest() -> Pokemon? {
        selectedPokemon.max { $0.height < $1.height }
    }
    
    func getHeaviest() -> Pokemon? {
        selectedPokemon.max { $0.weight < $1.weight }
    }
    
    func getLightest() -> Pokemon? {
        selectedPokemon.min { $0.weight < $1.weight }
    }
    
    func getShortest() -> Pokemon? {
        selectedPokemon.min { $0.height < $1.height }
    }
}