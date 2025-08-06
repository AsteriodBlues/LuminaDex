//
//  TrainingView.swift
//  LuminaDex
//
//  Complete training view with EVs, IVs, and Natures
//

import SwiftUI
import Charts

struct TrainingView: View {
    let pokemon: Pokemon
    @State private var selectedNature = NatureChart.allNatures[0]
    @State private var ivSpread = IVSpread.perfect
    @State private var evSpread = EVSpread()
    @State private var level = 50
    @State private var showingNaturePicker = false
    @State private var showingEVPresets = false
    @State private var calculatedStats: PokemonStats?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Pokemon Header
                pokemonHeader
                
                // Nature Selection
                natureSection
                
                // IV Section
                ivSection
                
                // EV Section  
                evSection
                
                // Calculated Stats
                if let stats = calculatedStats {
                    calculatedStatsSection(stats)
                }
                
                // Training Items
                trainingItemsSection
            }
            .padding()
        }
        .navigationTitle("Training Calculator")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.opacity(0.95))
        .onAppear {
            calculateStats()
        }
        .sheet(isPresented: $showingNaturePicker) {
            NaturePickerView(selectedNature: $selectedNature, pokemon: pokemon)
        }
        .sheet(isPresented: $showingEVPresets) {
            EVPresetView(evSpread: $evSpread)
        }
    }
    
    // MARK: - Pokemon Header
    private var pokemonHeader: some View {
        HStack {
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault ?? "")) { image in
                image
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading) {
                Text(pokemon.name.capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    ForEach(pokemon.types, id: \.slot) { typeSlot in
                        TypeBadge(type: typeSlot.pokemonType)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Picker("Level", selection: $level) {
                    ForEach([5, 50, 100], id: \.self) { lvl in
                        Text("\(lvl)").tag(lvl)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
                .onChange(of: level) { _ in
                    calculateStats()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Nature Section
    private var natureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Nature", systemImage: "leaf.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingNaturePicker = true }) {
                    HStack {
                        Text(selectedNature.displayName)
                            .fontWeight(.semibold)
                        
                        Text(selectedNature.statModifierDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(selectedNature.color)
                }
            }
            
            // Nature Effect Display
            if let increased = selectedNature.increasedStat, 
               let decreased = selectedNature.decreasedStat {
                HStack {
                    StatModifierBadge(stat: increased, modifier: .positive)
                    StatModifierBadge(stat: decreased, modifier: .negative)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - IV Section
    private var ivSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Individual Values (IVs)", systemImage: "dna")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(ivSpread.perfection))% Perfect")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(ivSpread.perfection > 90 ? .green : .orange)
            }
            
            VStack(spacing: 8) {
                IVSlider(label: "HP", value: $ivSpread.hp, color: .red)
                IVSlider(label: "Attack", value: $ivSpread.attack, color: .orange)
                IVSlider(label: "Defense", value: $ivSpread.defense, color: .blue)
                IVSlider(label: "Sp. Atk", value: $ivSpread.specialAttack, color: .purple)
                IVSlider(label: "Sp. Def", value: $ivSpread.specialDefense, color: .green)
                IVSlider(label: "Speed", value: $ivSpread.speed, color: .yellow)
            }
            
            // IV Presets
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    IVPresetButton(title: "Perfect", spread: .perfect) { ivSpread = $0 }
                    IVPresetButton(title: "Trick Room", spread: .trickRoom) { ivSpread = $0 }
                    IVPresetButton(title: "Special", spread: .special) { ivSpread = $0 }
                    IVPresetButton(title: "Zero", spread: .zero) { ivSpread = $0 }
                }
            }
            
            // Hidden Power
            HStack {
                Text("Hidden Power:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TypeBadge(type: ivSpread.hiddenPowerType)
                
                Text("Power: \(ivSpread.hiddenPowerDamage)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onChange(of: ivSpread) { _ in
            calculateStats()
        }
    }
    
    // MARK: - EV Section
    private var evSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Effort Values (EVs)", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(evSpread.total)/510")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(evSpread.total <= 510 ? .green : .red)
                
                Button(action: { showingEVPresets = true }) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 8) {
                EVSlider(label: "HP", value: $evSpread.hp, remaining: evSpread.remaining, color: .red)
                EVSlider(label: "Attack", value: $evSpread.attack, remaining: evSpread.remaining, color: .orange)
                EVSlider(label: "Defense", value: $evSpread.defense, remaining: evSpread.remaining, color: .blue)
                EVSlider(label: "Sp. Atk", value: $evSpread.specialAttack, remaining: evSpread.remaining, color: .purple)
                EVSlider(label: "Sp. Def", value: $evSpread.specialDefense, remaining: evSpread.remaining, color: .green)
                EVSlider(label: "Speed", value: $evSpread.speed, remaining: evSpread.remaining, color: .yellow)
            }
            
            if !evSpread.distribution.isEmpty {
                Text(evSpread.distribution)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onChange(of: evSpread) { _ in
            calculateStats()
        }
    }
    
    // MARK: - Calculated Stats
    private func calculatedStatsSection(_ stats: PokemonStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Calculated Stats", systemImage: "function")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                StatDisplay(label: "HP", base: pokemon.stats.first { $0.stat.name == "hp" }?.baseStat ?? 0, calculated: stats.hp, color: .red)
                StatDisplay(label: "Atk", base: pokemon.stats.first { $0.stat.name == "attack" }?.baseStat ?? 0, calculated: stats.attack, color: .orange)
                StatDisplay(label: "Def", base: pokemon.stats.first { $0.stat.name == "defense" }?.baseStat ?? 0, calculated: stats.defense, color: .blue)
            }
            
            HStack(spacing: 12) {
                StatDisplay(label: "SpA", base: pokemon.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0, calculated: stats.specialAttack, color: .purple)
                StatDisplay(label: "SpD", base: pokemon.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0, calculated: stats.specialDefense, color: .green)
                StatDisplay(label: "Spe", base: pokemon.stats.first { $0.stat.name == "speed" }?.baseStat ?? 0, calculated: stats.speed, color: .yellow)
            }
            
            // Total
            HStack {
                Text("Base Total: \(pokemon.stats.reduce(0) { $0 + $1.baseStat })")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Calculated Total: \(stats.total)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Training Items
    private var trainingItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Training Items", systemImage: "bag.fill")
                .font(.headline)
                .foregroundColor(.white)
            
            // Power Items
            Text("Power Items (+8 EVs)")
                .font(.caption)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(TrainingItem.powerItems, id: \.name) { item in
                    TrainingItemCard(item: item)
                }
            }
            
            // Vitamins
            Text("Vitamins (+10 EVs)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(TrainingItem.vitamins, id: \.name) { item in
                    TrainingItemCard(item: item)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    private func calculateStats() {
        calculatedStats = StatCalculator.calculateAllStats(
            pokemon: pokemon,
            ivs: ivSpread,
            evs: evSpread,
            level: level,
            nature: selectedNature
        )
    }
}

// MARK: - Supporting Views
struct IVSlider: View {
    let label: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50, alignment: .leading)
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 0...31, step: 1)
            .accentColor(color)
            
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(value == 31 ? .green : value == 0 ? .red : .white)
                .frame(width: 25)
        }
    }
}

struct EVSlider: View {
    let label: String
    @Binding var value: Int
    let remaining: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50, alignment: .leading)
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { 
                    let newValue = Int($0)
                    let maxAllowed = min(252, value + remaining)
                    value = min(newValue, maxAllowed)
                }
            ), in: 0...252, step: 4)
            .accentColor(color)
            
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(value == 252 ? .green : value == 0 ? .gray : .white)
                .frame(width: 30)
        }
    }
}

struct StatDisplay: View {
    let label: String
    let base: Int
    let calculated: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(calculated)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("(\(base))")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatModifierBadge: View {
    let stat: NatureStatType
    let modifier: Modifier
    
    enum Modifier {
        case positive, negative
        
        var symbol: String {
            switch self {
            case .positive: return "+"
            case .negative: return "-"
            }
        }
        
        var color: Color {
            switch self {
            case .positive: return .green
            case .negative: return .red
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(modifier.symbol)
                .fontWeight(.bold)
            
            Image(systemName: stat.icon)
                .font(.caption)
            
            Text(stat.abbreviation)
                .font(.caption)
        }
        .foregroundColor(modifier.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(modifier.color.opacity(0.2))
        .cornerRadius(6)
    }
}

struct IVPresetButton: View {
    let title: String
    let spread: IVSpread
    let action: (IVSpread) -> Void
    
    var body: some View {
        Button(action: { action(spread) }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.3))
                .cornerRadius(8)
        }
    }
}

struct TrainingItemCard: View {
    let item: TrainingItem
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: item.icon)
                .font(.system(size: 20))
                .foregroundColor(item.stat.color)
            
            Text(item.name)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text("+\(item.evBoost) EVs")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// Type Badge helper
struct TypeBadge: View {
    let type: PokemonType
    
    var body: some View {
        Text(type.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type.color)
            .cornerRadius(6)
    }
}

// MARK: - Nature Picker View
struct NaturePickerView: View {
    @Binding var selectedNature: Nature
    let pokemon: Pokemon
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Recommended Natures
                Section("Recommended") {
                    ForEach(NatureChart.getOptimalNatures(for: pokemon), id: \.id) { nature in
                        NatureRow(nature: nature, isSelected: selectedNature.id == nature.id) {
                            selectedNature = nature
                            dismiss()
                        }
                    }
                }
                
                // All Natures
                Section("All Natures") {
                    ForEach(NatureChart.allNatures, id: \.id) { nature in
                        NatureRow(nature: nature, isSelected: selectedNature.id == nature.id) {
                            selectedNature = nature
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Nature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct NatureRow: View {
    let nature: Nature
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(nature.displayName)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .blue : .primary)
                    
                    Text(nature.statModifierDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - EV Preset View
struct EVPresetView: View {
    @Binding var evSpread: EVSpread
    @Environment(\.dismiss) private var dismiss
    
    let presets = [
        ("Physical Sweeper", EVSpread.physical),
        ("Special Sweeper", EVSpread.special),
        ("Bulky Physical", EVSpread.bulkyPhysical),
        ("Bulky Special", EVSpread.bulkySpecial),
        ("Defensive Wall", EVSpread.defensive),
        ("Mixed Attacker", EVSpread.mixed)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(presets, id: \.0) { name, spread in
                    Button(action: {
                        evSpread = spread
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(name)
                                .fontWeight(.semibold)
                            
                            Text(spread.distribution)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("EV Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}