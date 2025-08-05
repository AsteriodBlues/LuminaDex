//
//  ComparisonView.swift
//  LuminaDex
//
//

import SwiftUI
import DGCharts

struct ComparisonView: View {
    @StateObject private var viewModel = ComparisonViewModel()
    @State private var showingPokemonPicker = false
    @State private var selectedSlot: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Pokemon Selection Grid
                    pokemonSelectionGrid
                    
                    // Stats Comparison
                    if viewModel.selectedPokemon.count >= 2 {
                        statsComparisonSection
                    }
                    
                    // Size Comparison
                    if viewModel.selectedPokemon.count >= 2 {
                        sizeComparisonSection
                    }
                }
                .padding()
            }
            .navigationTitle("Pokemon Comparison")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        viewModel.clearAll()
                    }
                    .disabled(viewModel.selectedPokemon.isEmpty)
                }
            }
            .sheet(isPresented: $showingPokemonPicker) {
                PokemonPickerView(viewModel: viewModel, selectedSlot: selectedSlot)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Compare Pokemon")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select 2-6 Pokemon to compare their stats and attributes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Label("\(viewModel.selectedPokemon.count)/6", systemImage: "checkmark.circle.fill")
                    .foregroundColor(viewModel.selectedPokemon.count >= 2 ? .green : .orange)
                
                Spacer()
                
                if viewModel.selectedPokemon.count >= 2 {
                    Label("Ready to Compare", systemImage: "chart.bar.fill")
                        .foregroundColor(.blue)
                        .animation(.easeInOut, value: viewModel.selectedPokemon.count)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var pokemonSelectionGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(0..<6, id: \.self) { index in
                pokemonSlotCard(index: index)
            }
        }
    }
    
    private func pokemonSlotCard(index: Int) -> some View {
        Group {
            if index < viewModel.selectedPokemon.count {
                // Filled slot
                ComparisonCard(pokemon: viewModel.selectedPokemon[index])
                    .contextMenu {
                        Button("Remove", role: .destructive) {
                            viewModel.removePokemon(at: index)
                        }
                        Button("Replace") {
                            selectedSlot = index
                            showingPokemonPicker = true
                        }
                    }
            } else {
                // Empty slot
                Button(action: {
                    selectedSlot = index
                    showingPokemonPicker = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.dashed")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("Add Pokemon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var statsComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stats Comparison")
                .font(.title2)
                .fontWeight(.bold)
            
            // Radar Chart
            ComparisonChart(pokemon: viewModel.selectedPokemon)
                .frame(height: 300)
            
            // Detailed Stats Table
            statsTable
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statsTable: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Stat")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 60, alignment: .leading)
                
                ForEach(viewModel.selectedPokemon, id: \.id) { pokemon in
                    Text(pokemon.name.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(pokemon.primaryType.color)
                }
            }
            .padding(.horizontal, 8)
            
            Divider()
            
            // Stats rows
            ForEach(StatType.allStatTypes, id: \.name) { statType in
                HStack {
                    Text(statType.shortName)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                    
                    ForEach(viewModel.selectedPokemon, id: \.id) { pokemon in
                        if let stat = pokemon.stats.first(where: { $0.stat.name == statType.name }) {
                            Text("\(stat.baseStat)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(
                                    Rectangle()
                                        .fill(pokemon.primaryType.color.opacity(0.1))
                                        .cornerRadius(4)
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private var sizeComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Size Comparison")
                .font(.title2)
                .fontWeight(.bold)
            
            SizeComparisonView(pokemon: viewModel.selectedPokemon)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Extension for StatType to provide all stat types
extension StatType {
    static let allStatTypes = [
        StatType(name: "hp", url: ""),
        StatType(name: "attack", url: ""),
        StatType(name: "defense", url: ""),
        StatType(name: "special-attack", url: ""),
        StatType(name: "special-defense", url: ""),
        StatType(name: "speed", url: "")
    ]
}

struct PokemonPickerView: View {
    @ObservedObject var viewModel: ComparisonViewModel
    let selectedSlot: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var pokemonRepository = PokemonRepository.shared
    @State private var searchText = ""
    
    @State private var allPokemon: [Pokemon] = []
    
    var filteredPokemon: [Pokemon] {
        let available = allPokemon.filter { pokemon in
            !viewModel.selectedPokemon.contains { $0.id == pokemon.id }
        }
        
        if searchText.isEmpty {
            return available
        }
        
        return available.filter { pokemon in
            pokemon.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredPokemon, id: \.id) { pokemon in
                Button(action: {
                    viewModel.addPokemon(pokemon, at: selectedSlot)
                    dismiss()
                }) {
                    HStack {
                        AsyncImage(url: URL(string: pokemon.sprites.officialArtwork)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pokemon.displayName)
                                .font(.headline)
                            
                            HStack {
                                ForEach(pokemon.types.prefix(2), id: \.slot) { typeSlot in
                                    Text(typeSlot.pokemonType.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(typeSlot.pokemonType.color)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .searchable(text: $searchText, prompt: "Search Pokemon")
            .navigationTitle("Select Pokemon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    // Load first 150 Pokemon (original generation)
                    let pokemonList = try await pokemonRepository.fetchPokemonList(limit: 150, offset: 0)
                    var loadedPokemon: [Pokemon] = []
                    
                    for item in pokemonList {
                        do {
                            let pokemon = try await pokemonRepository.fetchPokemon(name: item.name)
                            loadedPokemon.append(pokemon)
                        } catch {
                            // Skip if error loading individual Pokemon
                            continue
                        }
                    }
                    
                    await MainActor.run {
                        allPokemon = loadedPokemon
                    }
                } catch {
                    print("Error loading Pokemon: \(error)")
                }
            }
        }
    }
}

#Preview {
    ComparisonView()
}
