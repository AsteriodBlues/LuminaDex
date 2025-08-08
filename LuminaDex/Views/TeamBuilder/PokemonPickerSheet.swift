//
//  PokemonPickerSheet.swift
//  LuminaDex
//
//  Pokemon selection sheet for team builder
//

import SwiftUI

struct PokemonPickerSheet: View {
    let selectedSlot: Int?
    let onSelect: (Pokemon) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var database: DatabaseManager
    @State private var searchText = ""
    @State private var selectedType: PokemonType?
    @State private var selectedGeneration: Int?
    @State private var sortOption = SortOption.number
    @State private var pokemon: [ExtendedPokemonRecord] = []
    @State private var filteredPokemon: [ExtendedPokemonRecord] = []
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    
    enum SortOption: String, CaseIterable {
        case number = "Number"
        case name = "Name"
        case stats = "Total Stats"
        case speed = "Speed"
        case attack = "Attack"
        case defense = "Defense"
        
        var icon: String {
            switch self {
            case .number: return "number"
            case .name: return "textformat"
            case .stats: return "chart.bar.fill"
            case .speed: return "hare.fill"
            case .attack: return "bolt.fill"
            case .defense: return "shield.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.02, green: 0.02, blue: 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filters
                    searchAndFilters
                    
                    // Pokemon Grid
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView("Loading Pokemon...")
                            if loadingProgress > 0 {
                                ProgressView(value: loadingProgress)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        pokemonGrid
                    }
                }
            }
            .navigationTitle("Select Pokemon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                sortOption = option
                                sortPokemon()
                            }) {
                                Label(option.rawValue, systemImage: option.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            loadPokemon()
        }
    }
    
    private var searchAndFilters: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search Pokemon...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All Types Button
                    TeamFilterChip(
                        title: "All",
                        isSelected: selectedType == nil,
                        color: .gray
                    ) {
                        selectedType = nil
                        filterPokemon()
                    }
                    
                    ForEach(PokemonType.allCases, id: \.self) { type in
                        TeamFilterChip(
                            title: type.rawValue,
                            isSelected: selectedType == type,
                            color: type.color
                        ) {
                            selectedType = type
                            filterPokemon()
                        }
                    }
                }
            }
            
            // Generation Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TeamFilterChip(
                        title: "All Gens",
                        isSelected: selectedGeneration == nil,
                        color: .gray
                    ) {
                        selectedGeneration = nil
                        filterPokemon()
                    }
                    
                    ForEach(1...9, id: \.self) { gen in
                        TeamFilterChip(
                            title: "Gen \(gen)",
                            isSelected: selectedGeneration == gen,
                            color: .blue
                        ) {
                            selectedGeneration = gen
                            filterPokemon()
                        }
                    }
                }
            }
        }
        .padding()
        .onChange(of: searchText) { _ in
            filterPokemon()
        }
    }
    
    private var pokemonGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(filteredPokemon) { record in
                    PokemonGridItem(record: record) {
                        // Convert PokemonRecord to Pokemon before selection
                        Task {
                            if let fullPokemon = await loadFullPokemon(from: record) {
                                HapticManager.notification(type: .success)
                                onSelect(fullPokemon)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Data Management
    private func loadPokemon() {
        Task {
            do {
                let allPokemon = try await database.getAllExtendedPokemon()
                await MainActor.run {
                    self.pokemon = allPokemon
                    self.filteredPokemon = allPokemon
                    self.isLoading = false
                    sortPokemon()
                }
            } catch {
                print("Error loading Pokemon: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func filterPokemon() {
        var filtered = pokemon
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { record in
                record.name.localizedCaseInsensitiveContains(searchText) ||
                "\(record.id)".contains(searchText)
            }
        }
        
        // Type filter
        if let type = selectedType {
            filtered = filtered.filter { record in
                record.types.contains(type.rawValue)
            }
        }
        
        // Generation filter
        if let gen = selectedGeneration {
            filtered = filtered.filter { record in
                getGeneration(for: record.id) == gen
            }
        }
        
        filteredPokemon = filtered
        sortPokemon()
    }
    
    private func sortPokemon() {
        switch sortOption {
        case .number:
            filteredPokemon.sort { $0.id < $1.id }
        case .name:
            filteredPokemon.sort { $0.name < $1.name }
        case .stats:
            filteredPokemon.sort { $0.totalStats > $1.totalStats }
        case .speed:
            filteredPokemon.sort { $0.stats["speed"] ?? 0 > $1.stats["speed"] ?? 0 }
        case .attack:
            filteredPokemon.sort { $0.stats["attack"] ?? 0 > $1.stats["attack"] ?? 0 }
        case .defense:
            filteredPokemon.sort { $0.stats["defense"] ?? 0 > $1.stats["defense"] ?? 0 }
        }
    }
    
    private func getGeneration(for id: Int) -> Int {
        switch id {
        case 1...151: return 1
        case 152...251: return 2
        case 252...386: return 3
        case 387...493: return 4
        case 494...649: return 5
        case 650...721: return 6
        case 722...809: return 7
        case 810...905: return 8
        case 906...1025: return 9
        default: return 1
        }
    }
    
    private func loadFullPokemon(from record: ExtendedPokemonRecord) async -> Pokemon? {
        do {
            return try await PokemonAPI.shared.fetchPokemon(id: record.id)
        } catch {
            print("Error loading full Pokemon data: \(error)")
            return nil
        }
    }
}

struct PokemonGridItem: View {
    let record: ExtendedPokemonRecord
    let onSelect: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false
    
    var types: [PokemonType] {
        record.types.compactMap { PokemonType(rawValue: $0) }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Pokemon Sprite
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    types.first?.color.opacity(0.3) ?? .gray.opacity(0.3),
                                    types.last?.color.opacity(0.3) ?? .gray.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    AsyncImage(url: URL(string: record.spriteUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                    .frame(width: 60, height: 60)
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
                
                // Pokemon Info
                VStack(spacing: 4) {
                    Text("#\(record.id)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Text(record.name.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Types
                    HStack(spacing: 2) {
                        ForEach(types, id: \.self) { type in
                            Circle()
                                .fill(type.color)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isHovered ?
                            Color.white.opacity(0.15) :
                            Color.white.opacity(0.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isHovered ?
                                    types.first?.color.opacity(0.5) ?? .gray.opacity(0.5) :
                                    Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct TeamFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                )
        }
    }
}