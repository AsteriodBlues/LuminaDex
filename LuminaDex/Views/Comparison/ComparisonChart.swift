//
//  ComparisonChart.swift
//  LuminaDex
//
//  Created on 8/5/25.
//

import SwiftUI
import DGCharts

struct ComparisonChart: View {
    let pokemon: [Pokemon]
    @State private var animationProgress: Double = 0
    
    private let statNames = ["HP", "ATK", "DEF", "SPA", "SPD", "SPE"]
    private let maxStatValue: Double = 255.0
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart Title
            Text("Stat Comparison Radar")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Radar Chart
            ZStack {
                // Background radar grid
                radarGrid
                
                // Pokemon stat overlays
                ForEach(Array(pokemon.enumerated()), id: \.element.id) { index, pokemon in
                    radarPath(for: pokemon, index: index)
                }
                
                // Stat labels
                statLabels
            }
            .frame(width: 250, height: 250)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animationProgress = 1.0
                }
            }
            
            // Legend
            legendView
        }
    }
    
    private var radarGrid: some View {
        ZStack {
            // Concentric circles
            ForEach(1...5, id: \.self) { level in
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: CGFloat(level) * 40, height: CGFloat(level) * 40)
            }
            
            // Axis lines
            ForEach(0..<6) { index in
                let angle = Double(index) * 60 - 90
                let radians = angle * .pi / 180
                let endX = cos(radians) * 125
                let endY = sin(radians) * 125
                
                Path { path in
                    path.move(to: CGPoint(x: 125, y: 125))
                    path.addLine(to: CGPoint(x: 125 + endX, y: 125 + endY))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
        }
    }
    
    private func radarPath(for pokemon: Pokemon, index: Int) -> some View {
        let color = getPokemonColor(for: pokemon, index: index)
        let stats = getStatValues(for: pokemon)
        
        return Path { path in
            guard stats.count == 6 else { return }
            
            let centerX: CGFloat = 125
            let centerY: CGFloat = 125
            let maxRadius: CGFloat = 100
            
            for (statIndex, stat) in stats.enumerated() {
                let angle = Double(statIndex) * 60 - 90
                let radians = angle * .pi / 180
                let normalizedValue = stat / maxStatValue
                let radius = maxRadius * normalizedValue * animationProgress
                
                let x = centerX + cos(radians) * radius
                let y = centerY + sin(radians) * radius
                
                if statIndex == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.closeSubpath()
        }
        .fill(color.opacity(0.2))
        .overlay(
            Path { path in
                guard stats.count == 6 else { return }
                
                let centerX: CGFloat = 125
                let centerY: CGFloat = 125
                let maxRadius: CGFloat = 100
                
                for (statIndex, stat) in stats.enumerated() {
                    let angle = Double(statIndex) * 60 - 90
                    let radians = angle * .pi / 180
                    let normalizedValue = stat / maxStatValue
                    let radius = maxRadius * normalizedValue * animationProgress
                    
                    let x = centerX + cos(radians) * radius
                    let y = centerY + sin(radians) * radius
                    
                    if statIndex == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                path.closeSubpath()
            }
            .stroke(color, lineWidth: 2)
        )
    }
    
    private var statLabels: some View {
        ZStack {
            ForEach(0..<statNames.count, id: \.self) { index in
                let angle = Double(index) * 60 - 90
                let radians = angle * .pi / 180
                let radius: CGFloat = 140
                let x = 125 + cos(radians) * radius
                let y = 125 + sin(radians) * radius
                
                Text(statNames[index])
                    .font(.caption)
                    .fontWeight(.semibold)
                    .position(x: x, y: y)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pokemon")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            ForEach(Array(pokemon.enumerated()), id: \.element.id) { index, pokemon in
                HStack(spacing: 8) {
                    Circle()
                        .fill(getPokemonColor(for: pokemon, index: index))
                        .frame(width: 12, height: 12)
                    
                    Text(pokemon.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
                    Text("BST: \(totalStats)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getStatValues(for pokemon: Pokemon) -> [Double] {
        let statOrder = ["hp", "attack", "defense", "special-attack", "special-defense", "speed"]
        return statOrder.map { statName in
            Double(pokemon.stats.first { $0.stat.name == statName }?.baseStat ?? 0)
        }
    }
    
    private func getPokemonColor(for pokemon: Pokemon, index: Int) -> Color {
        if pokemon.types.count >= 2 {
            return pokemon.types[index % pokemon.types.count].pokemonType.color
        } else {
            return pokemon.primaryType.color
        }
    }
}

// MARK: - Alternative Chart View using native SwiftUI
struct NativeComparisonChart: View {
    let pokemon: [Pokemon]
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Base Stats Comparison")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Bar chart for each stat
            VStack(spacing: 12) {
                ForEach(StatType.allStatTypes, id: \.name) { statType in
                    statBarRow(for: statType)
                }
            }
            
            // Summary
            summaryView
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func statBarRow(for statType: StatType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(statType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                // Show highest value for this stat
                if let maxStat = pokemon.map({ getStatValue(for: $0, statName: statType.name) }).max() {
                    Text("\(maxStat)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Stat bars
            HStack(spacing: 2) {
                ForEach(Array(pokemon.enumerated()), id: \.element.id) { index, pokemon in
                    let statValue = getStatValue(for: pokemon, statName: statType.name)
                    let maxValue = self.pokemon.map({ getStatValue(for: $0, statName: statType.name) }).max() ?? 1
                    let percentage = Double(statValue) / Double(maxValue)
                    
                    VStack {
                        Rectangle()
                            .fill(pokemon.primaryType.color)
                            .frame(height: CGFloat(percentage * 30) * CGFloat(animationProgress))
                            .cornerRadius(2)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(height: 30)
                    .overlay(
                        Text("\(statValue)")
                            .font(.system(size: 8))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(percentage > 0.3 ? 1 : 0),
                        alignment: .bottom
                    )
                }
            }
        }
    }
    
    private var summaryView: some View {
        HStack {
            ForEach(Array(pokemon.enumerated()), id: \.element.id) { index, pokemon in
                VStack(spacing: 4) {
                    Circle()
                        .fill(pokemon.primaryType.color)
                        .frame(width: 20, height: 20)
                    
                    Text(pokemon.name.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    let totalStats = pokemon.stats.reduce(0) { $0 + $1.baseStat }
                    Text("\(totalStats)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getStatValue(for pokemon: Pokemon, statName: String) -> Int {
        pokemon.stats.first { $0.stat.name == statName }?.baseStat ?? 0
    }
}

#Preview {
    VStack {
        ComparisonChart(pokemon: [Pokemon.mockPokemon])
        NativeComparisonChart(pokemon: [Pokemon.mockPokemon])
    }
    .padding()
}