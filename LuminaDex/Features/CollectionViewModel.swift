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
    @Published var currentFilterCriteria: FilterCriteria = FilterCriteria()
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let database = DatabaseManager.shared
    
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
        
        Task {
            // Load real Pokemon data from database
            await loadPokemonFromDatabase()
            await loadAchievements()
            filterPokemon()
            isLoading = false
        }
    }
    
    private func loadPokemonFromDatabase() async {
        do {
            // Get Pokemon from the database
            let pokemonRecords = try await database.databaseQueue.read { db in
                try PokemonRecord.fetchAll(db)
            }
            
            // Convert database records to Pokemon models (simplified)
            let loadedPokemon = pokemonRecords.map { record in
                Pokemon(
                    id: record.id,
                    name: record.name,
                    height: record.height,
                    weight: record.weight,
                    baseExperience: record.baseExperience,
                    order: record.orderIndex,
                    isDefault: record.isDefault,
                    sprites: PokemonSprites(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(record.id).png",
                        frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/\(record.id).png",
                        frontFemale: nil, frontShinyFemale: nil,
                        backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil,
                        other: PokemonSpritesOther(
                            dreamWorld: nil,
                            home: nil,
                            officialArtwork: PokemonOfficialArtwork(
                                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(record.id).png",
                                frontShiny: nil
                            )
                        )
                    ),
                    types: [], // Will be loaded separately
                    abilities: [], // Will be loaded separately  
                    stats: [], // Will be loaded separately
                    species: PokemonSpecies(name: record.name, url: ""),
                    moves: [],
                    gameIndices: []
                )
            }
            
            await MainActor.run {
                self.pokemon = loadedPokemon
            }
            
        } catch {
            print("Error loading Pokemon from database: \(error)")
            // Fallback to sample data if database fails
            await loadSampleData()
        }
    }
    
    private func loadSampleData() async {
        // Using mock data that matches your Pokemon structure
        pokemon = [
            Pokemon(
                id: 1, name: "charizard", height: 17, weight: 905, baseExperience: 267, order: 5, isDefault: true,
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil,
                                      backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil, other: nil),
                types: [PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "fire", url: "")), PokemonTypeSlot(slot: 2, type: PokemonTypeInfo(name: "flying", url: ""))],
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
                types: [PokemonTypeSlot(slot: 1, type: PokemonTypeInfo(name: "water", url: ""))],
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
    
    // MARK: - Filter Criteria
    func applyFilterCriteria(_ criteria: FilterCriteria) {
        currentFilterCriteria = criteria
        
        Task {
            isLoading = true
            do {
                // Use the database filter queries
                let filteredResults = try await database.fetchFilteredPokemon(criteria: criteria)
                
                await MainActor.run {
                    self.filteredPokemon = filteredResults.sorted(by: { applySortingComparison($0, $1) })
                    isLoading = false
                }
            } catch {
                print("Error applying filters: \(error)")
                // Fallback to basic filtering
                filterPokemon()
                isLoading = false
            }
        }
    }
    
    // MARK: - Filtering & Sorting
    func filterPokemon() {
        var filtered = pokemon
        
        // Apply type filter
        if let selectedType = selectedType {
            filtered = filtered.filter { $0.types.contains { $0.pokemonType == selectedType } }
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
                pokemon.types.contains { $0.pokemonType.rawValue.localizedCaseInsensitiveContains(searchText) }
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
        return pokemon.sorted { applySortingComparison($0, $1) }
    }
    
    private func applySortingComparison(_ pokemon1: Pokemon, _ pokemon2: Pokemon) -> Bool {
        switch sortOption {
        case .number:
            return pokemon1.id < pokemon2.id
        case .name:
            return pokemon1.name < pokemon2.name
        case .type:
            return pokemon1.primaryType.rawValue < pokemon2.primaryType.rawValue
        case .stats:
            return pokemon1.collectionStats.total > pokemon2.collectionStats.total
        case .favorites:
            return pokemon1.isFavorite && !pokemon2.isFavorite
        case .caught:
            return pokemon1.isCaught && !pokemon2.isCaught
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
