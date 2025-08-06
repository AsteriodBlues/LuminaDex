//
//  CollectionView.swift
//  LuminaDex
//
//  Created by Ritwik on 8/3/25.
//
import SwiftUI
import Combine

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @Namespace private var animationNamespace
    @State private var showingFilters = false
    @State private var filterCriteria = FilterCriteria()
    @AppStorage("shinyMode") private var globalShinyMode = false
    
    private var hasActiveFilters: Bool {
        !filterCriteria.types.isEmpty ||
        !filterCriteria.generations.isEmpty ||
        !filterCriteria.minStats.isEmpty ||
        !filterCriteria.maxStats.isEmpty ||
        filterCriteria.minHeight != nil ||
        filterCriteria.maxHeight != nil ||
        filterCriteria.minWeight != nil ||
        filterCriteria.maxWeight != nil ||
        filterCriteria.isLegendary != nil ||
        filterCriteria.isMythical != nil ||
        filterCriteria.isBaby != nil ||
        !filterCriteria.abilities.isEmpty
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if !filterCriteria.types.isEmpty { count += 1 }
        if !filterCriteria.generations.isEmpty { count += 1 }
        if !filterCriteria.minStats.isEmpty || !filterCriteria.maxStats.isEmpty { count += 1 }
        if filterCriteria.minHeight != nil || filterCriteria.maxHeight != nil ||
           filterCriteria.minWeight != nil || filterCriteria.maxWeight != nil { count += 1 }
        if filterCriteria.isLegendary != nil || filterCriteria.isMythical != nil || 
           filterCriteria.isBaby != nil { count += 1 }
        if !filterCriteria.abilities.isEmpty { count += 1 }
        return count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Neural Network Background
                NeuralNetworkBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Shiny Collection Tracker
                    if globalShinyMode {
                        ShinyCollectionTracker(totalPokemon: viewModel.totalCount)
                            .padding(.horizontal)
                            .padding(.top)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Header Stats
                    headerStatsView
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Controls
                    controlsView
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Pokemon Collection
                    pokemonCollectionView
                }
            }
            .navigationTitle("Neural Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showAchievements = true }) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.linearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search Pokemon...")
        .onChange(of: viewModel.searchText) { _ in
            viewModel.filterPokemon()
        }
        .onChange(of: viewModel.selectedType) { _ in
            viewModel.filterPokemon()
        }
        .onChange(of: viewModel.showFavoritesOnly) { _ in
            viewModel.filterPokemon()
        }
        .onChange(of: viewModel.sortOption) { _ in
            viewModel.filterPokemon()
        }
        .sheet(isPresented: $viewModel.showAchievements) {
            AchievementsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(
                isPresented: $showingFilters,
                initialCriteria: filterCriteria
            ) { newCriteria in
                filterCriteria = newCriteria
                viewModel.applyFilterCriteria(newCriteria)
            }
        }
        .onChange(of: filterCriteria) { _ in
            viewModel.applyFilterCriteria(filterCriteria)
        }
    }
    
    // MARK: - Header Stats View
    private var headerStatsView: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Discovered",
                value: "\(viewModel.caughtCount)",
                icon: "brain.head.profile",
                gradient: [.blue, .purple]
            )
            
            StatCard(
                title: "Complete",
                value: String(format: "%.1f%%", viewModel.completionPercentage),
                icon: "chart.pie.fill",
                gradient: [.green, .teal]
            )
            
            StatCard(
                title: "Favorites",
                value: "\(viewModel.favoriteCount)",
                icon: "heart.fill",
                gradient: [.pink, .red]
            )
        }
        .padding(.bottom)
    }
    
    // MARK: - Controls View
    private var controlsView: some View {
        VStack(spacing: 12) {
            // View Mode Toggle & Sort
            HStack {
                // View Mode
                Picker("View Mode", selection: $viewModel.viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                
                Spacer()
                
                // Sort Menu
                // Shiny Mode Toggle
                ShinyToggleButton(showShiny: $globalShinyMode)
                
                // Sort Menu
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { viewModel.sortOption = option }) {
                            Label(option.rawValue, systemImage: option.icon)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Advanced Filter Button
                    Button(action: { showingFilters = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(hasActiveFilters ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                hasActiveFilters ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .cornerRadius(20)
                            .overlay(
                                hasActiveFilters ? 
                                    Text("\(activeFilterCount)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Circle().fill(Color.red))
                                        .offset(x: 10, y: -10)
                                : nil
                            )
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Favorites Toggle
                    FilterChip(
                        title: "Favorites",
                        icon: "heart.fill",
                        isSelected: viewModel.showFavoritesOnly
                    ) {
                        withAnimation(.spring()) {
                            viewModel.showFavoritesOnly.toggle()
                        }
                    }
                    
                    // All Types
                    FilterChip(
                        title: "All",
                        icon: "circle.grid.2x2.fill",
                        isSelected: viewModel.selectedType == nil
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectedType = nil
                        }
                    }
                    
                    // Type Filters
                    ForEach(PokemonType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            icon: type.emoji,
                            isSelected: viewModel.selectedType == type,
                            color: type.color
                        ) {
                            withAnimation(.spring()) {
                                viewModel.selectedType = viewModel.selectedType == type ? nil : type
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Pokemon Collection View
    private var pokemonCollectionView: some View {
        Group {
            if viewModel.viewMode == .grid {
                gridView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                listView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewMode)
    }
    
    // MARK: - Grid View
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.filteredPokemon) { pokemon in
                    PokemonGridCard(pokemon: pokemon, viewModel: viewModel)
                        .matchedGeometryEffect(id: pokemon.id, in: animationNamespace)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - List View
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredPokemon) { pokemon in
                    PokemonListCard(pokemon: pokemon, viewModel: viewModel)
                        .matchedGeometryEffect(id: pokemon.id, in: animationNamespace)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Preview
struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
    }
}
