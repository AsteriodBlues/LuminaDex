//
//  MoveEncyclopediaView.swift
//  LuminaDex
//
//  Complete Move Encyclopedia with Charts and Visualizations
//

import SwiftUI
import Charts

struct MoveEncyclopediaView: View {
    @StateObject private var viewModel = MoveEncyclopediaViewModel()
    @State private var searchText = ""
    @State private var selectedType: PokemonType?
    @State private var selectedCategory: MoveCategory?
    @State private var selectedGeneration: Int?
    @State private var showingDamageCalculator = false
    @State private var showingStatistics = false
    @State private var selectedMove: Move?
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with statistics
                    headerSection
                    
                    // Filter chips
                    filterSection
                    
                    // Statistics charts
                    if showingStatistics {
                        statisticsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    
                    // Move grid
                    moveGridSection
                }
                .padding()
            }
            .background(Color.black.opacity(0.95))
            .navigationTitle("Move Encyclopedia")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search moves...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDamageCalculator = true }) {
                        Image(systemName: "function")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        withAnimation(.spring()) {
                            showingStatistics.toggle()
                        }
                    }) {
                        Image(systemName: showingStatistics ? "chart.pie.fill" : "chart.pie")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .sheet(isPresented: $showingDamageCalculator) {
            DamageCalculatorView()
        }
        .sheet(item: $selectedMove) { move in
            MoveDetailView(move: move)
        }
        .onAppear {
            viewModel.loadMoves()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Total Moves",
                    value: "\(viewModel.statistics.totalMoves)",
                    icon: "bolt.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Avg Power",
                    value: String(format: "%.0f", viewModel.statistics.averagePower),
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatisticCard(
                    title: "Avg Accuracy",
                    value: String(format: "%.0f%%", viewModel.statistics.averageAccuracy),
                    icon: "target",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
                .foregroundColor(.white)
            
            // Type filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Types",
                        icon: "circle.grid.3x3",
                        isSelected: selectedType == nil,
                        color: .gray
                    ) {
                        selectedType = nil
                    }
                    
                    ForEach(PokemonType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue.capitalized,
                            icon: type.icon,
                            isSelected: selectedType == type,
                            color: type.color
                        ) {
                            selectedType = selectedType == type ? nil : type
                        }
                    }
                }
            }
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All Categories",
                        icon: "square.grid.2x2",
                        isSelected: selectedCategory == nil,
                        color: .gray
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(MoveCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 20) {
            // Power vs Accuracy Scatter Plot
            powerAccuracyChart
            
            // Type Distribution Chart
            typeDistributionChart
            
            // Category Distribution
            categoryDistributionChart
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
    }
    
    private var powerAccuracyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Power vs Accuracy")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(viewModel.filteredMoves.filter { $0.power != nil && $0.accuracy != nil }) { move in
                PointMark(
                    x: .value("Power", move.power ?? 0),
                    y: .value("Accuracy", move.accuracy ?? 0)
                )
                .foregroundStyle(by: .value("Type", move.type.rawValue))
                .symbolSize(100)
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
            .chartBackground { _ in
                Color.clear
            }
        }
    }
    
    private var typeDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type Distribution")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(Array(viewModel.statistics.byType), id: \.key) { type, count in
                BarMark(
                    x: .value("Count", count),
                    y: .value("Type", type.rawValue)
                )
                .foregroundStyle(type.color.gradient)
            }
            .frame(height: 400)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    private var categoryDistributionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                ForEach(MoveCategory.allCases, id: \.self) { category in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(category.color.opacity(0.3), lineWidth: 8)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: getCategoryPercentage(category))
                                .stroke(category.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 2) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(category.color)
                                Text("\(getCategoryCount(category))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Move Grid Section
    private var moveGridSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredMoves) { move in
                MoveCard(move: move) {
                    selectedMove = move
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getCategoryPercentage(_ category: MoveCategory) -> Double {
        let count = viewModel.statistics.byCategory[category] ?? 0
        return Double(count) / Double(viewModel.statistics.totalMoves)
    }
    
    private func getCategoryCount(_ category: MoveCategory) -> Int {
        viewModel.statistics.byCategory[category] ?? 0
    }
}

// MARK: - Move Card
struct MoveCard: View {
    let move: Move
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Move Name - Full width
                Text(move.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Type and Category
                HStack(spacing: 12) {
                    MoveTypeBadge(type: move.type, size: .medium, style: .filled)
                    MoveCategoryBadge(category: move.category, size: .small)
                    Spacer()
                }
                
                // Stats row
                HStack(spacing: 10) {
                    if let power = move.power {
                        MovePowerBadge(power: power)
                    }
                    
                    if let accuracy = move.accuracy {
                        MoveAccuracyBadge(accuracy: accuracy)
                    }
                    
                    MovePPBadge(pp: move.pp)
                    
                    if move.priority != 0 {
                        MovePriorityBadge(priority: move.priority)
                    }
                    
                    Spacer()
                }
                
                // Effect text if available
                if let effect = move.effect {
                    Text(effect)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(move.type.color.opacity(0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(move.type.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stat Badge
struct MoveStatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - View Model
@MainActor
class MoveEncyclopediaViewModel: ObservableObject {
    @Published var allMoves: [Move] = []
    @Published var filteredMoves: [Move] = []
    @Published var statistics = MoveStatistics(
        totalMoves: 0,
        byType: [:],
        byCategory: [:],
        byGeneration: [:],
        averagePower: 0,
        averageAccuracy: 0,
        averagePP: 0
    )
    @Published var isLoading = false
    @Published var loadingProgress: Double = 0
    @Published var loadingMessage = ""
    
    private let moveFetcher = MoveDataFetcher.shared
    
    init() {
        loadMoves()
    }
    
    func loadMoves() {
        Task {
            isLoading = true
            loadingMessage = "Loading moves..."
            
            // Check if moves are already loaded
            if !moveFetcher.allMoves.isEmpty {
                allMoves = moveFetcher.allMoves
                filteredMoves = allMoves
                statistics = MoveStatistics.calculate(from: allMoves)
                isLoading = false
                return
            }
            
            // Fetch moves from API
            await moveFetcher.fetchAllMoves()
            
            // Update our local state
            allMoves = moveFetcher.allMoves
            
            // If no moves from API, use sample data
            if allMoves.isEmpty {
                allMoves = generateSampleMoves()
            }
            
            filteredMoves = allMoves
            statistics = MoveStatistics.calculate(from: allMoves)
            isLoading = false
        }
    }
    
    private func generateSampleMoves() -> [Move] {
        // Sample moves data
        return [
            Move(id: 1, name: "thunderbolt", type: .electric, category: .special, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to paralyze", effectChance: 10, target: .selectedPokemon, critRate: 0),
            Move(id: 2, name: "flamethrower", type: .fire, category: .special, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to burn", effectChance: 10, target: .selectedPokemon, critRate: 0),
            Move(id: 3, name: "earthquake", type: .ground, category: .physical, power: 100, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .physical, effect: nil, effectChance: nil, target: .allOtherPokemon, critRate: 0),
            Move(id: 4, name: "psychic", type: .psychic, category: .special, power: 90, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to lower Sp. Def", effectChance: 10, target: .selectedPokemon, critRate: 0),
            Move(id: 5, name: "ice-beam", type: .ice, category: .special, power: 90, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: "10% chance to freeze", effectChance: 10, target: .selectedPokemon, critRate: 0),
            Move(id: 6, name: "dragon-claw", type: .dragon, category: .physical, power: 80, accuracy: 100, pp: 15, priority: 0, generation: 3, damageClass: .physical, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0),
            Move(id: 7, name: "shadow-ball", type: .ghost, category: .special, power: 80, accuracy: 100, pp: 15, priority: 0, generation: 2, damageClass: .special, effect: "20% chance to lower Sp. Def", effectChance: 20, target: .selectedPokemon, critRate: 0),
            Move(id: 8, name: "toxic", type: .poison, category: .status, power: nil, accuracy: 90, pp: 10, priority: 0, generation: 1, damageClass: .status, effect: "Badly poisons the target", effectChance: 100, target: .selectedPokemon, critRate: 0),
            Move(id: 9, name: "protect", type: .normal, category: .status, power: nil, accuracy: nil, pp: 10, priority: 4, generation: 2, damageClass: .status, effect: "Protects from attacks", effectChance: nil, target: .user, critRate: 0),
            Move(id: 10, name: "swords-dance", type: .normal, category: .status, power: nil, accuracy: nil, pp: 20, priority: 0, generation: 1, damageClass: .status, effect: "Sharply raises Attack", effectChance: nil, target: .user, critRate: 0)
        ]
    }
}