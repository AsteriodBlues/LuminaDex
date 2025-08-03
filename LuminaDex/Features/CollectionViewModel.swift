//
//  CollectionViewModel.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//
import SwiftUI
import Combine
import Foundation

// MARK: - Collection View Model
@MainActor
class CollectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var pokemon: [Pokemon] = []
    @Published var filteredPokemon: [Pokemon] = []
    @Published var selectedType: PokemonType? = nil
    @Published var viewMode: ViewMode = .grid
    @Published var searchText: String = ""
    @Published var showFavoritesOnly: Bool = false
    @Published var showCaughtOnly: Bool = false
    @Published var showAchievements: Bool = false
    @Published var sortOption: SortOption = .number
    @Published var achievements: [Achievement] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var caughtCount: Int {
        pokemon.filter(\.isCaught).count
    }
    
    var favoriteCount: Int {
        pokemon.filter(\.isFavorite).count
    }
    
    var totalCount: Int {
        pokemon.count
    }
    
    var completionPercentage: Double {
        guard !pokemon.isEmpty else { return 0.0 }
        return Double(caughtCount) / Double(pokemon.count) * 100
    }
    
    // MARK: - Initialization
    init() {
        setupObservers()
        loadData()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        // Auto-filter when search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterPokemon()
            }
            .store(in: &cancellables)
        
        // Auto-filter when other properties change
        Publishers.CombineLatest4($selectedType, $showFavoritesOnly, $showCaughtOnly, $sortOption)
            .sink { [weak self] _, _, _, _ in
                self?.filterPokemon()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        
        // Simulate async data loading
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await loadSampleData()
            await loadAchievements()
            filterPokemon()
            isLoading = false
        }
    }
    
    private func loadSampleData() async {
        // Using mock data that matches your Pokemon structure
        pokemon = [
            Pokemon(
                id: 1, name: "charizard", height: 17, weight: 905, baseExperience: 267, order: 5, isDefault: true,
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil,
                                      backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil, other: nil),
                types: [PokemonTypeSlot(slot: 1, type: .fire), PokemonTypeSlot(slot: 2, type: .flying)],
                abilities: [], stats: [
                    PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "hp", url: "")),
                    PokemonStat(baseStat: 84, effort: 0, stat: StatType(name: "attack", url: "")),
                    PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "defense", url: ""))
                ],
                species: PokemonSpecies(name: "charizard", url: ""), moves: [], gameIndices: []
            ),
            Pokemon(
                id: 2, name: "blastoise", height: 16, weight: 855, baseExperience: 239, order: 9, isDefault: true,
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil,
                                      backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil, other: nil),
                types: [PokemonTypeSlot(slot: 1, type: .water)],
                abilities: [], stats: [
                    PokemonStat(baseStat: 79, effort: 0, stat: StatType(name: "hp", url: "")),
                    PokemonStat(baseStat: 83, effort: 0, stat: StatType(name: "attack", url: ""))
                ],
                species: PokemonSpecies(name: "blastoise", url: ""), moves: [], gameIndices: []
            )
        ]
    }
    
    private func loadAchievements() async {
        achievements = [
            Achievement(id: 1, title: "Fire Master", description: "Catch all Fire-type Pokemon", icon: "🔥", requirement: 5, category: .types),
            Achievement(id: 2, title: "Ocean Explorer", description: "Catch 10 Water-type Pokemon", icon: "🌊", requirement: 10, category: .types),
            Achievement(id: 3, title: "Neural Network", description: "Connect with 50 Pokemon", icon: "🧠", requirement: 50, category: .collection),
            Achievement(id: 4, title: "Legendary Hunter", description: "Catch 5 Legendary Pokemon", icon: "⭐", requirement: 5, category: .special)
        ]
    }
    
    // MARK: - Filtering & Sorting
    func filterPokemon() {
        var filtered = pokemon
        
        // Apply type filter
        if let selectedType = selectedType {
            filtered = filtered.filter { $0.types.contains { $0.type == selectedType } }
        }
        
        // Apply favorites filter
        if showFavoritesOnly {
            filtered = filtered.filter(\.isFavorite)
        }
        
        // Apply caught filter
        if showCaughtOnly {
            filtered = filtered.filter(\.isCaught)
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { pokemon in
                pokemon.displayName.localizedCaseInsensitiveContains(searchText) ||
                pokemon.types.contains { $0.type.rawValue.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply sorting
        filtered = applySorting(to: filtered)
        
        // Animate the change
        withAnimation(.easeInOut(duration: 0.3)) {
            filteredPokemon = filtered
        }
    }
    
    private func applySorting(to pokemon: [Pokemon]) -> [Pokemon] {
        switch sortOption {
        case .number:
            return pokemon.sorted { $0.id < $1.id }
        case .name:
            return pokemon.sorted { $0.name < $1.name }
        case .type:
            return pokemon.sorted { $0.primaryType.rawValue < $1.primaryType.rawValue }
        case .stats:
            return pokemon.sorted { (pokemon1, pokemon2) in
                return pokemon1.collectionStats.total > pokemon2.collectionStats.total
            }
        case .favorites:
            return pokemon.sorted { (pokemon1, pokemon2) in
                return pokemon1.isFavorite && !pokemon2.isFavorite
            }
        case .caught:
            return pokemon.sorted { (pokemon1, pokemon2) in
                return pokemon1.isCaught && !pokemon2.isCaught
            }
        }
    }
    
    // MARK: - Actions
    func toggleFavorite(for pokemon: Pokemon) {
        guard let index = self.pokemon.firstIndex(where: { $0.id == pokemon.id }) else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            self.pokemon[index].isFavorite.toggle()
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func toggleCaught(for pokemon: Pokemon) {
        guard let index = self.pokemon.firstIndex(where: { $0.id == pokemon.id }) else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            self.pokemon[index].isCaught.toggle()
            
            if self.pokemon[index].isCaught {
                self.pokemon[index].catchDate = Date()
                self.pokemon[index].progress = 100.0
            } else {
                self.pokemon[index].catchDate = nil
                self.pokemon[index].progress = Double.random(in: 10...90)
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
}

// MARK: - Supporting Models
enum ViewMode: String, CaseIterable {
    case grid = "Grid"
    case list = "List"
    
    var icon: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        }
    }
}

enum SortOption: String, CaseIterable {
    case number = "Number"
    case name = "Name"
    case type = "Type"
    case stats = "Stats"
    case favorites = "Favorites"
    case caught = "Caught"
    
    var icon: String {
        switch self {
        case .number: return "number"
        case .name: return "textformat.abc"
        case .type: return "tag"
        case .stats: return "chart.bar"
        case .favorites: return "heart"
        case .caught: return "checkmark.circle"
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    let category: AchievementCategory
    var isUnlocked: Bool = false
    var progress: Int = 0
}

enum AchievementCategory: String, CaseIterable, Codable {
    case collection = "Collection"
    case types = "Types"
    case stats = "Stats"
    case special = "Special"
    
    var color: Color {
        switch self {
        case .collection: return .blue
        case .types: return .green
        case .stats: return .orange
        case .special: return .purple
        }
    }
}
