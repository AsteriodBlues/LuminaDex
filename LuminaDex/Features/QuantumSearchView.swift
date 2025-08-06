//
//  QuantumSearchView.swift
//  LuminaDex
//
//  Advanced Pokemon Search with Real-Time API Integration
//

import SwiftUI
import Combine

struct QuantumSearchView: View {
    @StateObject private var searchEngine = QuantumSearchEngine()
    @State private var searchText = ""
    @State private var selectedCategory: SearchCategory = .all
    @State private var showFilters = false
    @State private var animateResults = false
    @State private var searchFieldFocused = false
    @FocusState private var isSearchFocused: Bool
    
    // Advanced filters
    @State private var typeFilter: PokemonType?
    @State private var generationFilter: Int?
    @State private var minStats: Int = 0
    @State private var abilitySearch = ""
    @State private var moveSearch = ""
    
    enum SearchCategory: String, CaseIterable {
        case all = "All"
        case pokemon = "Pokémon"
        case moves = "Moves"
        case abilities = "Abilities"
        case items = "Items"
        case types = "Types"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.3x3"
            case .pokemon: return "flame"
            case .moves: return "bolt"
            case .abilities: return "sparkles"
            case .items: return "bag"
            case .types: return "tag"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .pokemon: return .red
            case .moves: return .yellow
            case .abilities: return .purple
            case .items: return .green
            case .types: return .orange
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Animated Background
            QuantumBackground()
            
            VStack(spacing: 0) {
                // Header with Search Field
                searchHeader
                
                // Category Pills
                categorySelector
                
                // Results Area
                if searchEngine.isSearching {
                    loadingView
                } else if !searchText.isEmpty {
                    searchResults
                } else {
                    suggestionsView
                }
            }
        }
        .navigationTitle("Quantum Search")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: searchText) { newValue in
            searchEngine.search(query: newValue, category: selectedCategory)
        }
        .onChange(of: selectedCategory) { _ in
            if !searchText.isEmpty {
                searchEngine.search(query: searchText, category: selectedCategory)
            }
        }
        .sheet(isPresented: $showFilters) {
            FiltersSheet(
                typeFilter: $typeFilter,
                generationFilter: $generationFilter,
                minStats: $minStats,
                abilitySearch: $abilitySearch,
                moveSearch: $moveSearch
            ) {
                applyFilters()
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 16) {
            // Search Field
            HStack(spacing: 12) {
                // Search Icon with Animation
                Image(systemName: isSearchFocused ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(isSearchFocused ? .blue : .gray)
                    .animation(.spring(), value: isSearchFocused)
                
                // Text Field
                TextField("Search Pokémon, moves, abilities...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .focused($isSearchFocused)
                
                // Clear Button
                if !searchText.isEmpty {
                    Button(action: { 
                        withAnimation(.spring()) {
                            searchText = ""
                            searchEngine.clearResults()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Filter Button
                Button(action: { showFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(hasActiveFilters ? .blue : .gray)
                        .overlay(
                            hasActiveFilters ? 
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8) : nil
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSearchFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            
            // Quick Stats Bar
            if !searchEngine.searchResults.isEmpty {
                HStack(spacing: 20) {
                    ResultStat(label: "Results", value: "\(searchEngine.searchResults.count)")
                    ResultStat(label: "Types", value: "\(searchEngine.uniqueTypes.count)")
                    ResultStat(label: "Gen", value: searchEngine.generationRange)
                }
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { 
                            withAnimation(.spring()) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchEngine.searchResults) { result in
                    SearchResultCard(result: result)
                        .transition(.asymmetric(
                            insertion: .push(from: .bottom).combined(with: .opacity),
                            removal: .push(from: .top).combined(with: .opacity)
                        ))
                }
            }
            .padding()
        }
    }
    
    // MARK: - Suggestions View
    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Trending Searches
                if !searchEngine.trendingSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Trending", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(searchEngine.trendingSearches, id: \.self) { term in
                                TrendingChip(term: term) {
                                    searchText = term
                                }
                            }
                        }
                    }
                }
                
                // Recent Searches
                if !searchEngine.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Recent", systemImage: "clock")
                                .font(.headline)
                            Spacer()
                            Button("Clear") {
                                searchEngine.clearHistory()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(searchEngine.recentSearches, id: \.self) { search in
                            RecentSearchRow(search: search) {
                                searchText = search
                            }
                        }
                    }
                }
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Label("Quick Search", systemImage: "bolt")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionCard(
                            title: "Legendary",
                            icon: "crown",
                            color: .purple
                        ) {
                            searchEngine.searchLegendary()
                        }
                        
                        QuickActionCard(
                            title: "Starters",
                            icon: "leaf",
                            color: .green
                        ) {
                            searchEngine.searchStarters()
                        }
                        
                        QuickActionCard(
                            title: "Random",
                            icon: "dice",
                            color: .blue
                        ) {
                            searchEngine.searchRandom()
                        }
                        
                        QuickActionCard(
                            title: "Shiny",
                            icon: "sparkles",
                            color: .yellow
                        ) {
                            searchEngine.searchShiny()
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            QuantumLoadingIndicator()
            Text("Searching across dimensions...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Properties
    private var hasActiveFilters: Bool {
        typeFilter != nil || generationFilter != nil || 
        minStats > 0 || !abilitySearch.isEmpty || !moveSearch.isEmpty
    }
    
    private func applyFilters() {
        searchEngine.applyFilters(
            type: typeFilter,
            generation: generationFilter,
            minStats: minStats,
            ability: abilitySearch,
            move: moveSearch
        )
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let result: SearchResult
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon/Image
            ZStack {
                Circle()
                    .fill(result.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                if let imageURL = result.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        Image(systemName: result.icon)
                            .font(.system(size: 24))
                            .foregroundColor(result.color)
                    }
                } else {
                    Image(systemName: result.icon)
                        .font(.system(size: 24))
                        .foregroundColor(result.color)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(result.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Tags
                if !result.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(result.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(result.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(result.color.opacity(0.15))
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                // Navigate to detail
            }
        }
    }
}

// MARK: - Supporting Views
struct CategoryPill: View {
    let category: QuantumSearchView.SearchCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : category.color.opacity(0.15))
            )
        }
    }
}

struct TrendingChip: View {
    let term: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                Text(term)
                    .font(.system(size: 14))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RecentSearchRow: View {
    let search: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(search)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct ResultStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

struct QuantumLoadingIndicator: View {
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 30 + CGFloat(index) * 20, 
                           height: 30 + CGFloat(index) * 20)
                    .rotationEffect(.degrees(rotation + Double(index) * 120))
                    .scaleEffect(scale)
                    .opacity(1.0 - Double(index) * 0.3)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

struct QuantumBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh
            GeometryReader { geometry in
                ForEach(0..<5) { row in
                    ForEach(0..<5) { col in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.blue.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .position(
                                x: CGFloat(col) * geometry.size.width / 4 + sin(phase + CGFloat(col)) * 20,
                                y: CGFloat(row) * geometry.size.height / 4 + cos(phase + CGFloat(row)) * 20
                            )
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    phase = .pi * 2
                }
            }
        }
        .ignoresSafeArea()
    }
}

// Flow Layout for tags
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangement(proposal: proposal, subviews: subviews)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangement(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
    
    private func arrangement(proposal: ProposedViewSize, subviews: Subviews) -> (frames: [CGRect], height: CGFloat) {
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return (frames, currentY + lineHeight)
    }
}

struct FiltersSheet: View {
    @Binding var typeFilter: PokemonType?
    @Binding var generationFilter: Int?
    @Binding var minStats: Int
    @Binding var abilitySearch: String
    @Binding var moveSearch: String
    @Environment(\.dismiss) private var dismiss
    let onApply: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Type") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(PokemonType.allCases.filter { $0 != .unknown }, id: \.self) { type in
                                TypeChip(type: type, isSelected: typeFilter == type) {
                                    typeFilter = typeFilter == type ? nil : type
                                }
                            }
                        }
                    }
                }
                
                Section("Generation") {
                    Picker("Generation", selection: $generationFilter) {
                        Text("All").tag(nil as Int?)
                        ForEach(1...9, id: \.self) { gen in
                            Text("Gen \(gen)").tag(gen as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Stats") {
                    VStack(alignment: .leading) {
                        Text("Minimum Total: \(minStats)")
                            .font(.caption)
                        Slider(value: Binding(
                            get: { Double(minStats) },
                            set: { minStats = Int($0) }
                        ), in: 0...700, step: 50)
                    }
                }
                
                Section("Ability") {
                    TextField("Search abilities...", text: $abilitySearch)
                }
                
                Section("Move") {
                    TextField("Search moves...", text: $moveSearch)
                }
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        typeFilter = nil
                        generationFilter = nil
                        minStats = 0
                        abilitySearch = ""
                        moveSearch = ""
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct TypeChip: View {
    let type: PokemonType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue.capitalized)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : type.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? type.color : type.color.opacity(0.2))
                )
        }
    }
}