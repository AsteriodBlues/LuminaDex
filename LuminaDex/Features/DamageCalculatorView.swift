//
//  DamageCalculatorView.swift
//  LuminaDex
//
//  Advanced Damage Calculator with Visual Feedback
//

import SwiftUI
import Charts

struct DamageCalculatorView: View {
    @StateObject private var viewModel = DamageCalculatorViewModel()
    @State private var selectedAttacker: Pokemon?
    @State private var selectedDefender: Pokemon?
    @State private var selectedMove: Move?
    @State private var weather: Weather = .none
    @State private var terrain: Terrain = .none
    @State private var isCritical = false
    @State private var showingPokemonPicker = false
    @State private var pickingRole: PokemonRole = .attacker
    @State private var animateCalculation = false
    
    enum PokemonRole {
        case attacker, defender
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Pokemon Selection
                    pokemonSelectionSection
                    
                    // Move Selection
                    if selectedAttacker != nil {
                        moveSelectionSection
                    }
                    
                    // Battle Conditions
                    if selectedMove != nil {
                        battleConditionsSection
                    }
                    
                    // Calculate Button
                    if canCalculate {
                        calculateButton
                    }
                    
                    // Results
                    if viewModel.calculationResult != nil {
                        resultsSection
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.95))
            .navigationTitle("Damage Calculator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetCalculator()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingPokemonPicker) {
            PokemonPickerView { pokemon in
                if pickingRole == .attacker {
                    selectedAttacker = pokemon
                } else {
                    selectedDefender = pokemon
                }
                showingPokemonPicker = false
            }
        }
    }
    
    // MARK: - Pokemon Selection
    private var pokemonSelectionSection: some View {
        VStack(spacing: 16) {
            Text("Select Pokémon")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Attacker
                PokemonSelectionCard(
                    title: "Attacker",
                    pokemon: selectedAttacker,
                    color: .red
                ) {
                    pickingRole = .attacker
                    showingPokemonPicker = true
                }
                
                // VS Badge
                Text("VS")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.yellow)
                    .frame(width: 50)
                
                // Defender
                PokemonSelectionCard(
                    title: "Defender",
                    pokemon: selectedDefender,
                    color: .blue
                ) {
                    pickingRole = .defender
                    showingPokemonPicker = true
                }
            }
        }
    }
    
    // MARK: - Move Selection
    private var moveSelectionSection: some View {
        VStack(spacing: 16) {
            Text("Select Move")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableMoves) { move in
                        MoveSelectionCard(
                            move: move,
                            isSelected: selectedMove?.id == move.id
                        ) {
                            withAnimation(.spring()) {
                                selectedMove = move
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Battle Conditions
    private var battleConditionsSection: some View {
        VStack(spacing: 16) {
            Text("Battle Conditions")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weather
            VStack(alignment: .leading, spacing: 8) {
                Text("Weather")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Weather.allCases, id: \.self) { weatherOption in
                            ConditionChip(
                                title: weatherOption.rawValue,
                                isSelected: weather == weatherOption,
                                color: getWeatherColor(weatherOption)
                            ) {
                                weather = weatherOption
                            }
                        }
                    }
                }
            }
            
            // Terrain
            VStack(alignment: .leading, spacing: 8) {
                Text("Terrain")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Terrain.allCases, id: \.self) { terrainOption in
                            ConditionChip(
                                title: terrainOption.rawValue,
                                isSelected: terrain == terrainOption,
                                color: getTerrainColor(terrainOption)
                            ) {
                                terrain = terrainOption
                            }
                        }
                    }
                }
            }
            
            // Critical Hit Toggle
            Toggle(isOn: $isCritical) {
                Label("Critical Hit", systemImage: "bolt.fill")
                    .foregroundColor(.yellow)
            }
            .toggleStyle(SwitchToggleStyle(tint: .yellow))
        }
    }
    
    // MARK: - Calculate Button
    private var calculateButton: some View {
        Button(action: calculateDamage) {
            HStack {
                Image(systemName: "function")
                Text("Calculate Damage")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(animateCalculation ? 0.95 : 1.0)
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(spacing: 20) {
            Text("Damage Calculation Results")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Damage Range Chart
            damageRangeChart
            
            // Damage Details
            damageDetailsCard
            
            // Type Effectiveness
            typeEffectivenessCard
            
            // Share Button
            shareButton
        }
    }
    
    private var damageRangeChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Damage Range")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let result = viewModel.calculationResult {
                Chart {
                    BarMark(
                        x: .value("Type", "Min"),
                        y: .value("Damage", result.minDamage)
                    )
                    .foregroundStyle(Color.red.gradient)
                    
                    BarMark(
                        x: .value("Type", "Avg"),
                        y: .value("Damage", result.averageDamage)
                    )
                    .foregroundStyle(Color.yellow.gradient)
                    
                    BarMark(
                        x: .value("Type", "Max"),
                        y: .value("Damage", result.maxDamage)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white)
                    }
                }
                
                // Percentage of HP
                if let defender = selectedDefender {
                    let hp = defender.stats.first { $0.stat.name == "hp" }?.baseStat ?? 100
                    let percentages = [
                        result.minDamage * 100 / hp,
                        result.averageDamage * 100 / hp,
                        result.maxDamage * 100 / hp
                    ]
                    
                    HStack(spacing: 20) {
                        ForEach(Array(zip(["Min", "Avg", "Max"], percentages)), id: \.0) { label, percentage in
                            VStack(spacing: 4) {
                                Text("\(percentage)%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(getPercentageColor(percentage))
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var damageDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calculation Details")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let result = viewModel.calculationResult {
                VStack(spacing: 8) {
                    DetailRow(label: "Base Power", value: "\(result.move.power ?? 0)")
                    DetailRow(label: "STAB", value: result.isStab ? "1.5×" : "1.0×", highlight: result.isStab)
                    DetailRow(label: "Type Effectiveness", value: String(format: "%.1f×", result.typeEffectiveness), highlight: result.typeEffectiveness > 1)
                    DetailRow(label: "Critical", value: result.isCritical ? "1.5×" : "1.0×", highlight: result.isCritical)
                    if let weather = result.weather, weather != .none {
                        DetailRow(label: "Weather", value: weather.rawValue)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var typeEffectivenessCard: some View {
        HStack {
            if let result = viewModel.calculationResult {
                Image(systemName: getEffectivenessIcon(result.typeEffectiveness))
                    .font(.system(size: 32))
                    .foregroundColor(getEffectivenessColor(result.typeEffectiveness))
                
                VStack(alignment: .leading) {
                    Text(getEffectivenessText(result.typeEffectiveness))
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Type Effectiveness")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(String(format: "%.1f×", result.typeEffectiveness))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(getEffectivenessColor(result.typeEffectiveness))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var shareButton: some View {
        Button(action: shareCalculation) {
            Label("Share Calculation", systemImage: "square.and.arrow.up")
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    private var canCalculate: Bool {
        selectedAttacker != nil && selectedDefender != nil && selectedMove != nil
    }
    
    private func calculateDamage() {
        guard let attacker = selectedAttacker,
              let defender = selectedDefender,
              let move = selectedMove else { return }
        
        withAnimation(.spring()) {
            animateCalculation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring()) {
                animateCalculation = false
            }
        }
        
        viewModel.calculateDamage(
            attacker: attacker,
            defender: defender,
            move: move,
            weather: weather,
            terrain: terrain,
            isCritical: isCritical
        )
    }
    
    private func resetCalculator() {
        withAnimation {
            selectedAttacker = nil
            selectedDefender = nil
            selectedMove = nil
            weather = .none
            terrain = .none
            isCritical = false
            viewModel.calculationResult = nil
        }
    }
    
    private func shareCalculation() {
        // Implementation for sharing
    }
    
    private func getWeatherColor(_ weather: Weather) -> Color {
        switch weather {
        case .none: return .gray
        case .sun: return .orange
        case .rain: return .blue
        case .sandstorm: return .brown
        case .hail: return .cyan
        case .fog: return .gray
        }
    }
    
    private func getTerrainColor(_ terrain: Terrain) -> Color {
        switch terrain {
        case .none: return .gray
        case .electric: return .yellow
        case .grassy: return .green
        case .misty: return .pink
        case .psychic: return .purple
        }
    }
    
    private func getPercentageColor(_ percentage: Int) -> Color {
        switch percentage {
        case 0..<25: return .green
        case 25..<50: return .yellow
        case 50..<75: return .orange
        default: return .red
        }
    }
    
    private func getEffectivenessIcon(_ effectiveness: Double) -> String {
        switch effectiveness {
        case 0: return "xmark.circle.fill"
        case 0..<1: return "arrow.down.circle.fill"
        case 1: return "equal.circle.fill"
        case 1..<2: return "arrow.up.circle.fill"
        default: return "flame.fill"
        }
    }
    
    private func getEffectivenessColor(_ effectiveness: Double) -> Color {
        switch effectiveness {
        case 0: return .gray
        case 0..<1: return .red
        case 1: return .white
        case 1..<2: return .green
        default: return .yellow
        }
    }
    
    private func getEffectivenessText(_ effectiveness: Double) -> String {
        switch effectiveness {
        case 0: return "No Effect"
        case 0..<1: return "Not Very Effective"
        case 1: return "Normal Damage"
        case 1..<2: return "Super Effective"
        default: return "Ultra Effective"
        }
    }
}

// MARK: - Supporting Views
struct PokemonSelectionCard: View {
    let title: String
    let pokemon: Pokemon?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let pokemon = pokemon {
                    ImageManager.shared.loadThumbnail(url: pokemon.sprites.frontDefault)
                        .frame(width: 60, height: 60)
                    
                    Text(pokemon.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(color.opacity(0.5))
                        .frame(width: 60, height: 60)
                    
                    Text("Select")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(pokemon != nil ? color : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MoveSelectionCard: View {
    let move: Move
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(move.type.emoji)
                    .font(.system(size: 20))
                
                Text(move.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                if let power = move.power {
                    Text("Power: \(power)")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 100, height: 100)
            .background(isSelected ? move.type.color.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? move.type.color : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConditionChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: highlight ? .bold : .regular))
                .foregroundColor(highlight ? .yellow : .white)
        }
    }
}

// MARK: - View Model
@MainActor
class DamageCalculatorViewModel: ObservableObject {
    @Published var calculationResult: DamageCalculation?
    @Published var availableMoves: [Move] = []
    
    private let moveFetcher = MoveDataFetcher.shared
    
    init() {
        loadAvailableMoves()
    }
    
    func calculateDamage(attacker: Pokemon, defender: Pokemon, move: Move, weather: Weather, terrain: Terrain, isCritical: Bool) {
        // Check STAB
        let isStab = attacker.types.contains { $0.pokemonType == move.type }
        
        // Calculate type effectiveness
        let typeEffectiveness = calculateTypeEffectiveness(
            moveType: move.type,
            defenderTypes: defender.types.map { $0.pokemonType }
        )
        
        calculationResult = DamageCalculation(
            attacker: attacker,
            defender: defender,
            move: move,
            weather: weather,
            terrain: terrain,
            isStab: isStab,
            isCritical: isCritical,
            typeEffectiveness: typeEffectiveness
        )
    }
    
    private func calculateTypeEffectiveness(moveType: PokemonType, defenderTypes: [PokemonType]) -> Double {
        var effectiveness = 1.0
        
        for defenderType in defenderTypes {
            effectiveness *= moveType.effectiveness(against: defenderType)
        }
        
        return effectiveness
    }
    
    func loadAvailableMoves() {
        Task {
            // Load from fetcher if available
            if !moveFetcher.allMoves.isEmpty {
                // Filter for damage-dealing moves only
                availableMoves = moveFetcher.allMoves
                    .filter { $0.power != nil }
                    .prefix(20) // Limit to 20 moves for performance
                    .map { $0 }
            } else {
                // Load sample moves as fallback
                availableMoves = [
                    Move(id: 1, name: "thunderbolt", type: .electric, category: .special, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .special, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0),
                    Move(id: 2, name: "earthquake", type: .ground, category: .physical, power: 100, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .physical, effect: nil, effectChance: nil, target: .allOtherPokemon, critRate: 0),
                    Move(id: 3, name: "ice-beam", type: .ice, category: .special, power: 90, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0),
                    Move(id: 4, name: "flamethrower", type: .fire, category: .special, power: 90, accuracy: 100, pp: 15, priority: 0, generation: 1, damageClass: .special, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0),
                    Move(id: 5, name: "psychic", type: .psychic, category: .special, power: 90, accuracy: 100, pp: 10, priority: 0, generation: 1, damageClass: .special, effect: nil, effectChance: nil, target: .selectedPokemon, critRate: 0)
                ]
            }
        }
    }
}