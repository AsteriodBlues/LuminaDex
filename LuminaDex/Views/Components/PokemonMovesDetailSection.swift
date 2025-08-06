//
//  PokemonMovesDetailSection.swift
//  LuminaDex
//
//  Enhanced moves section for Pokemon detail view
//

import SwiftUI
import Charts

struct PokemonMovesDetailSection: View {
    let pokemonId: Int
    @StateObject private var moveFetcher = MoveDataFetcher.shared
    @State private var pokemonMoves: [PokemonMoveInfo] = []
    @State private var selectedLearnMethod: LearnMethodType? = nil
    @State private var selectedType: PokemonType? = nil
    @State private var selectedCategory: MoveCategory? = nil
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showingMoveDetail = false
    @State private var selectedMove: Move? = nil
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            headerSection
            
            if isLoading {
                loadingView
            } else if pokemonMoves.isEmpty {
                emptyStateView
            } else {
                // Stats Overview
                moveStatsOverview
                
                // Filters
                filterSection
                
                // Moves by Learn Method
                movesListSection
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .sheet(item: $selectedMove) { move in
            MoveDetailView(move: move)
        }
        .onAppear {
            loadPokemonMoves()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Label("Move Pool", systemImage: "bolt.circle.fill")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            Text("\(filteredMoves.count) moves")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.1)))
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading moves...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bolt.slash.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No moves available")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    // MARK: - Move Stats Overview
    private var moveStatsOverview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Total Moves
                StatOverviewCard(
                    title: "Total",
                    value: "\(pokemonMoves.count)",
                    icon: "number.circle",
                    gradient: [.blue, .cyan]
                )
                
                // By Learn Method
                ForEach(LearnMethodType.allCases, id: \.self) { method in
                    let count = pokemonMoves.filter { $0.learnMethod == method }.count
                    if count > 0 {
                        StatOverviewCard(
                            title: method.displayName,
                            value: "\(count)",
                            icon: method.icon,
                            gradient: [method.color, method.color.opacity(0.7)]
                        )
                    }
                }
                
                // Most Common Type
                if let mostCommonType = getMostCommonType() {
                    StatOverviewCard(
                        title: "Top Type",
                        value: mostCommonType.rawValue.capitalized,
                        icon: mostCommonType.icon,
                        gradient: [mostCommonType.color, mostCommonType.color.opacity(0.7)]
                    )
                }
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search moves...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Learn Method Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Methods",
                        icon: "circle.grid.3x3",
                        isSelected: selectedLearnMethod == nil,
                        color: .gray
                    ) {
                        selectedLearnMethod = nil
                    }
                    
                    ForEach(LearnMethodType.allCases, id: \.self) { method in
                        let count = pokemonMoves.filter { $0.learnMethod == method }.count
                        if count > 0 {
                            FilterChip(
                                title: "\(method.displayName) (\(count))",
                                icon: method.icon,
                                isSelected: selectedLearnMethod == method,
                                color: method.color
                            ) {
                                selectedLearnMethod = method
                            }
                        }
                    }
                }
            }
            
            // Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Types",
                        icon: "circle.grid.2x2",
                        isSelected: selectedType == nil,
                        color: .gray
                    ) {
                        selectedType = nil
                    }
                    
                    ForEach(getAvailableTypes(), id: \.self) { type in
                        FilterChip(
                            title: type.rawValue.capitalized,
                            icon: type.icon,
                            isSelected: selectedType == type,
                            color: type.color
                        ) {
                            selectedType = type
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Moves List Section
    private var movesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(groupedMoves.keys.sorted(), id: \.self) { method in
                if let moves = groupedMoves[method], !moves.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        // Section Header
                        Button(action: {
                            withAnimation(.spring()) {
                                if expandedSections.contains(method) {
                                    expandedSections.remove(method)
                                } else {
                                    expandedSections.insert(method)
                                }
                            }
                        }) {
                            HStack {
                                Label(method, systemImage: getMethodIcon(method))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(moves.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.white.opacity(0.1)))
                                
                                Image(systemName: expandedSections.contains(method) ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Moves Grid
                        if expandedSections.contains(method) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                                ForEach(moves) { moveDetail in
                                    MoveCardCompact(
                                        moveDetail: moveDetail,
                                        onTap: {
                                            selectedMove = moveDetail.move
                                        }
                                    )
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .push(from: .top).combined(with: .opacity),
                                removal: .push(from: .bottom).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private var filteredMoves: [PokemonMoveInfo] {
        pokemonMoves.filter { moveDetail in
            let matchesSearch = searchText.isEmpty || 
                moveDetail.move.displayName.localizedCaseInsensitiveContains(searchText)
            let matchesMethod = selectedLearnMethod == nil || 
                moveDetail.learnMethod == selectedLearnMethod
            let matchesType = selectedType == nil || 
                moveDetail.move.type == selectedType
            let matchesCategory = selectedCategory == nil || 
                moveDetail.move.category == selectedCategory
            
            return matchesSearch && matchesMethod && matchesType && matchesCategory
        }
    }
    
    private var groupedMoves: [String: [PokemonMoveInfo]] {
        Dictionary(grouping: filteredMoves) { moveDetail in
            if moveDetail.learnMethod == .levelUp, let level = moveDetail.levelLearnedAt {
                return "Level Up (Lv. 1-\(getMaxLevel()))"
            } else {
                return moveDetail.learnMethod.displayName
            }
        }
    }
    
    private func getMaxLevel() -> Int {
        pokemonMoves
            .compactMap { $0.levelLearnedAt }
            .max() ?? 100
    }
    
    private func getMostCommonType() -> PokemonType? {
        let typeCounts = Dictionary(grouping: pokemonMoves) { $0.move.type }
            .mapValues { $0.count }
        return typeCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getAvailableTypes() -> [PokemonType] {
        Array(Set(pokemonMoves.map { $0.move.type })).sorted { $0.rawValue < $1.rawValue }
    }
    
    private func getMethodIcon(_ method: String) -> String {
        if method.contains("Level") {
            return "arrow.up.circle"
        }
        return LearnMethodType.allCases
            .first { $0.displayName == method }?.icon ?? "circle"
    }
    
    private func loadPokemonMoves() {
        Task {
            isLoading = true
            
            // First check if we have moves in cache
            if moveFetcher.allMoves.isEmpty {
                // Load sample moves as fallback
                moveFetcher.loadSampleMoves()
            }
            
            // Fetch Pokemon-specific moves
            let moves = await moveFetcher.fetchPokemonMoves(for: pokemonId)
            
            await MainActor.run {
                pokemonMoves = moves
                
                // Auto-expand first section
                if let firstMethod = groupedMoves.keys.sorted().first {
                    expandedSections.insert(firstMethod)
                }
                
                isLoading = false
            }
        }
    }
}

// MARK: - Supporting Views
struct StatOverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .background(
            LinearGradient(
                colors: gradient.map { $0.opacity(0.2) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct MoveCardCompact: View {
    let moveDetail: PokemonMoveInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                // Move Type & Category
                HStack {
                    MoveTypeBadge(type: moveDetail.move.type, size: .small, style: .filled)
                    
                    Spacer()
                    
                    MoveCategoryBadge(category: moveDetail.move.category, size: .small)
                }
                
                // Move Name
                Text(moveDetail.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Level (if applicable)
                if moveDetail.learnMethod == .levelUp, let level = moveDetail.levelLearnedAt {
                    Text("Lv. \(level)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Power & Accuracy
                HStack(spacing: 8) {
                    if let power = moveDetail.move.power {
                        MovePowerBadge(power: power)
                    }
                    
                    if let accuracy = moveDetail.move.accuracy {
                        MoveAccuracyBadge(accuracy: accuracy)
                    }
                    
                    Spacer()
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(moveDetail.move.type.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(moveDetail.move.type.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}