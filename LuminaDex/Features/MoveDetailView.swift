//
//  MoveDetailView.swift
//  LuminaDex
//
//  Detailed Move Information with Learning Methods
//

import SwiftUI
import Charts

struct MoveDetailView: View {
    let move: Move
    @StateObject private var viewModel = MoveDetailViewModel()
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    moveHeaderSection
                    
                    // Stats Overview
                    statsOverviewSection
                    
                    // Tab Selection
                    tabSelector
                    
                    // Tab Content
                    tabContent
                }
                .padding()
            }
            .background(Color.black.opacity(0.95))
            .navigationTitle(move.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadMoveDetails(for: move)
        }
    }
    
    // MARK: - Header Section
    private var moveHeaderSection: some View {
        VStack(spacing: 16) {
            // Type and Category
            HStack(spacing: 20) {
                // Type Badge
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(move.type.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: move.type.icon)
                            .font(.system(size: 30))
                            .foregroundColor(move.type.color)
                    }
                    
                    Text(move.type.rawValue.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                // Category Badge
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(move.category.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: move.category.icon)
                            .font(.system(size: 30))
                            .foregroundColor(move.category.color)
                    }
                    
                    Text(move.category.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Effect Description
            if let effect = move.effect {
                Text(effect)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Stats Overview
    private var statsOverviewSection: some View {
        HStack(spacing: 16) {
            if let power = move.power {
                MoveStatCard(
                    title: "Power",
                    value: "\(power)",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            if let accuracy = move.accuracy {
                MoveStatCard(
                    title: "Accuracy",
                    value: "\(accuracy)%",
                    icon: "target",
                    color: .green
                )
            }
            
            MoveStatCard(
                title: "PP",
                value: "\(move.pp)",
                icon: "battery.100",
                color: .blue
            )
            
            MoveStatCard(
                title: "Priority",
                value: move.priority > 0 ? "+\(move.priority)" : "\(move.priority)",
                icon: "bolt.fill",
                color: move.priority > 0 ? .yellow : .gray
            )
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        Picker("View", selection: $selectedTab) {
            Text("Learn Methods").tag(0)
            Text("Compatible Pokémon").tag(1)
            Text("Statistics").tag(2)
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            learnMethodsContent
        case 1:
            compatiblePokemonContent
        case 2:
            statisticsContent
        default:
            EmptyView()
        }
    }
    
    // MARK: - Learn Methods Content
    private var learnMethodsContent: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.learnMethods, id: \.method) { learnMethod in
                LearnMethodCard(learnMethod: learnMethod)
            }
        }
    }
    
    // MARK: - Compatible Pokemon Content
    private var compatiblePokemonContent: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(viewModel.compatiblePokemon) { pokemon in
                VStack(spacing: 4) {
                    ImageManager.shared.loadThumbnail(url: pokemon.sprites.frontDefault)
                        .frame(width: 60, height: 60)
                    
                    Text(pokemon.displayName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(width: 80, height: 100)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Statistics Content
    private var statisticsContent: some View {
        VStack(spacing: 20) {
            // Type Effectiveness Chart
            typeEffectivenessChart
            
            // Generation Comparison
            generationComparisonChart
        }
    }
    
    private var typeEffectivenessChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type Effectiveness")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(PokemonType.allCases, id: \.self) { defenderType in
                BarMark(
                    x: .value("Effectiveness", move.type.effectiveness(against: defenderType)),
                    y: .value("Type", defenderType.rawValue)
                )
                .foregroundStyle(getEffectivenessGradient(move.type.effectiveness(against: defenderType)))
            }
            .frame(height: 400)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let effectiveness = value.as(Double.self) {
                            Text("\(effectiveness, specifier: "%.1f")×")
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var generationComparisonChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Similar Moves Comparison")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(viewModel.similarMoves) { similarMove in
                PointMark(
                    x: .value("Power", similarMove.power ?? 0),
                    y: .value("Accuracy", similarMove.accuracy ?? 100)
                )
                .foregroundStyle(by: .value("Move", similarMove.displayName))
                .symbolSize(200)
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white)
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white)
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    private func getEffectivenessGradient(_ effectiveness: Double) -> LinearGradient {
        let colors: [Color]
        switch effectiveness {
        case 0: colors = [.gray, .black]
        case 0..<1: colors = [.red, .orange]
        case 1: colors = [.blue, .blue]
        case 1..<2: colors = [.green, .mint]
        default: colors = [.yellow, .orange]
        }
        return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
    }
}

// MARK: - Supporting Views
struct MoveStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LearnMethodCard: View {
    let learnMethod: LearnMethodData
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: learnMethod.method.icon)
                .font(.system(size: 24))
                .foregroundColor(learnMethod.method.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(learnMethod.method.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(learnMethod.pokemonCount) Pokémon can learn this way")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if learnMethod.method == .levelUp {
                Text("Lvl \(learnMethod.averageLevel)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - View Model
@MainActor
class MoveDetailViewModel: ObservableObject {
    @Published var learnMethods: [LearnMethodData] = []
    @Published var compatiblePokemon: [Pokemon] = []
    @Published var similarMoves: [Move] = []
    
    func loadMoveDetails(for move: Move) {
        // Load learn methods
        learnMethods = [
            LearnMethodData(method: .levelUp, pokemonCount: 25, averageLevel: 35),
            LearnMethodData(method: .machine, pokemonCount: 50, averageLevel: 0),
            LearnMethodData(method: .egg, pokemonCount: 12, averageLevel: 0),
            LearnMethodData(method: .tutor, pokemonCount: 8, averageLevel: 0)
        ]
        
        // Load compatible Pokemon (sample)
        // This would be loaded from database
        compatiblePokemon = []
        
        // Load similar moves for comparison
        loadSimilarMoves(for: move)
    }
    
    private func loadSimilarMoves(for move: Move) {
        // Find moves with similar type and category
        similarMoves = [
            Move(id: 101, name: "thunder", type: .electric, category: .special, power: 110, accuracy: 70, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0),
            Move(id: 102, name: "discharge", type: .electric, category: .special, power: 80, accuracy: 100, pp: 15, priority: 0, generation: 4, damageClass: .special, effect: nil, effectChance: nil, target: .allOtherPokemon, critRate: 0),
            Move(id: 103, name: "wild-charge", type: .electric, category: .physical, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 5, damageClass: .physical, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0)
        ]
    }
}

struct LearnMethodData {
    let method: LearnMethodType
    let pokemonCount: Int
    let averageLevel: Int
}