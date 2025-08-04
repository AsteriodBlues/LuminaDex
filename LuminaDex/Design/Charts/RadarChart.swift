//
//  RadarChart.swift
//  LuminaDex
//
//  Day 21: Clean Neural Network Radar Chart
//

import SwiftUI

struct RadarChartData {
    let name: String
    let value: CGFloat
    let color: Color
    let icon: String
}

struct PokemonRadarChart: View {
    let pokemon: Pokemon
    let comparisonPokemon: Pokemon?
    
    @State private var progress: CGFloat = 0
    @State private var selectedIndex: Int? = nil
    @State private var rotationAngle: Double = 0
    @State private var showComparison: Bool = false
    @State private var comparisonProgress: CGFloat = 0
    
    private let size: CGFloat = 300
    private let radius: CGFloat = 100
    
    private var center: CGPoint {
        CGPoint(x: size/2, y: size/2)
    }
    
    private var data: [RadarChartData] {
        guard pokemon.stats.count >= 6 else { return [] }
        return [
            RadarChartData(name: "HP", value: CGFloat(pokemon.stats[0].baseStat) / 255, color: .red, icon: "heart.fill"),
            RadarChartData(name: "ATK", value: CGFloat(pokemon.stats[1].baseStat) / 255, color: .orange, icon: "flame.fill"),
            RadarChartData(name: "DEF", value: CGFloat(pokemon.stats[2].baseStat) / 255, color: .blue, icon: "shield.fill"),
            RadarChartData(name: "SP.ATK", value: CGFloat(pokemon.stats[3].baseStat) / 255, color: .purple, icon: "sparkles"),
            RadarChartData(name: "SP.DEF", value: CGFloat(pokemon.stats[4].baseStat) / 255, color: .indigo, icon: "eye.fill"),
            RadarChartData(name: "SPEED", value: CGFloat(pokemon.stats[5].baseStat) / 255, color: .green, icon: "bolt.fill")
        ]
    }
    
    private var comparisonData: [RadarChartData]? {
        guard let rival = comparisonPokemon, rival.stats.count >= 6 else { return nil }
        return [
            RadarChartData(name: "HP", value: CGFloat(rival.stats[0].baseStat) / 255, color: .red, icon: "heart.fill"),
            RadarChartData(name: "ATK", value: CGFloat(rival.stats[1].baseStat) / 255, color: .orange, icon: "flame.fill"),
            RadarChartData(name: "DEF", value: CGFloat(rival.stats[2].baseStat) / 255, color: .blue, icon: "shield.fill"),
            RadarChartData(name: "SP.ATK", value: CGFloat(rival.stats[3].baseStat) / 255, color: .purple, icon: "sparkles"),
            RadarChartData(name: "SP.DEF", value: CGFloat(rival.stats[4].baseStat) / 255, color: .indigo, icon: "eye.fill"),
            RadarChartData(name: "SPEED", value: CGFloat(rival.stats[5].baseStat) / 255, color: .green, icon: "bolt.fill")
        ]
    }
    
    var body: some View {
        ZStack {
            // Background with neural network theme
            backgroundView
            
            // Grid lines
            gridLines
            
            // Main data polygon
            dataPolygon
            
            // Comparison polygon (if available)
            if let _ = comparisonData, showComparison {
                comparisonPolygon
            }
            
            // Data points
            dataPoints
            
            // Labels
            axisLabels
            
            // Center Pokemon sprite
            centerSprite
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
    }
    
    private var backgroundView: some View {
        Circle()
            .fill(.regularMaterial)
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [pokemon.primaryColor, .cyan, pokemon.primaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            }
            .shadow(color: pokemon.primaryColor.opacity(0.5), radius: 20)
    }
    
    private var gridLines: some View {
        ZStack {
            // Concentric circles
            ForEach(1..<6, id: \.self) { ring in
                let ringRadius = radius * CGFloat(ring) / 5
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
            }
            
            // Axis lines
            ForEach(0..<6, id: \.self) { index in
                axisLine(index: index)
            }
        }
    }
    
    private func axisLine(index: Int) -> some View {
        let angle = Double(index) * 60 - 90
        let endX = center.x + radius * cos(angle * .pi / 180)
        let endY = center.y + radius * sin(angle * .pi / 180)
        
        return Path { path in
            path.move(to: center)
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
    }
    
    private var dataPolygon: some View {
        ZStack {
            // Fill
            polygonPath
                .fill(
                    RadialGradient(
                        colors: [
                            getTypeColor(for: pokemon).opacity(0.3),
                            getTypeColor(for: pokemon).opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            
            // Stroke
            polygonPath
                .stroke(getTypeColor(for: pokemon), lineWidth: 2)
                .shadow(color: getTypeColor(for: pokemon), radius: 5)
        }
    }
    
    private var comparisonPolygon: some View {
        ZStack {
            // Fill
            comparisonPolygonPath
                .fill(
                    RadialGradient(
                        colors: [
                            (comparisonPokemon != nil ? getTypeColor(for: comparisonPokemon!) : .purple).opacity(0.2),
                            (comparisonPokemon != nil ? getTypeColor(for: comparisonPokemon!) : .purple).opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            
            // Stroke
            comparisonPolygonPath
                .stroke(
                    comparisonPokemon != nil ? getTypeColor(for: comparisonPokemon!) : .purple,
                    style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                )
                .shadow(color: comparisonPokemon != nil ? getTypeColor(for: comparisonPokemon!) : .purple, radius: 5)
        }
    }
    
    private var dataPoints: some View {
        ForEach(0..<data.count, id: \.self) { index in
            dataPoint(index: index)
        }
    }
    
    private func dataPoint(index: Int) -> some View {
        let point = pointPosition(index: index)
        let datum = data[index]
        let isSelected = selectedIndex == index
        
        return ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            datum.color.opacity(0.6),
                            datum.color.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 30, height: 30)
                .opacity(isSelected ? 1.0 : 0.7)
            
            // Core point
            Circle()
                .fill(datum.color)
                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                .overlay {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                }
                .shadow(color: datum.color, radius: 8)
            
            // Data display (when selected)
            if isSelected {
                VStack(spacing: 4) {
                    Image(systemName: datum.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(datum.color)
                    
                    Text(datum.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(Int(datum.value * 255))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(datum.color, lineWidth: 2)
                        }
                        .shadow(color: datum.color.opacity(0.5), radius: 10)
                }
                .offset(y: -40)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
        .position(point)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedIndex = selectedIndex == index ? nil : index
            }
        }
    }
    
    private var axisLabels: some View {
        ForEach(0..<data.count, id: \.self) { index in
            axisLabel(index: index)
        }
    }
    
    private func axisLabel(index: Int) -> some View {
        let datum = data[index]
        let angle = Double(index) * 60 - 90
        let labelRadius = radius + 30
        let x = center.x + labelRadius * cos(angle * .pi / 180)
        let y = center.y + labelRadius * sin(angle * .pi / 180)
        
        return VStack(spacing: 2) {
            Image(systemName: datum.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(datum.color)
                .shadow(color: .black.opacity(0.3), radius: 1)
            
            Text(datum.name)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.primary)
                .shadow(color: .black.opacity(0.3), radius: 1)
        }
        .position(x: x, y: y)
    }
    
    private var centerSprite: some View {
        AsyncImage(url: URL(string: pokemon.sprites.officialArtwork)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(getTypeColor(for: pokemon), lineWidth: 2)
                }
                .shadow(color: getTypeColor(for: pokemon), radius: 10)
        } placeholder: {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            getTypeColor(for: pokemon).opacity(0.8),
                            getTypeColor(for: pokemon).opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .overlay {
                    Text(pokemon.name.prefix(2).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
        }
        .position(center)
    }
    
    private var polygonPath: Path {
        Path { path in
            guard !data.isEmpty else { return }
            
            let firstPoint = pointPosition(index: 0)
            path.move(to: firstPoint)
            
            for index in 1..<data.count {
                let point = pointPosition(index: index)
                path.addLine(to: point)
            }
            
            path.closeSubpath()
        }
    }
    
    private var comparisonPolygonPath: Path {
        Path { path in
            guard let rivalData = comparisonData, !rivalData.isEmpty else { return }
            
            let firstPoint = comparisonPointPosition(index: 0, rivalData: rivalData)
            path.move(to: firstPoint)
            
            for index in 1..<rivalData.count {
                let point = comparisonPointPosition(index: index, rivalData: rivalData)
                path.addLine(to: point)
            }
            
            path.closeSubpath()
        }
    }
    
    private func pointPosition(index: Int) -> CGPoint {
        let angle = Double(index) * 60 - 90
        let value = data[index].value * progress
        let pointRadius = radius * value
        let x = center.x + pointRadius * cos(angle * .pi / 180)
        let y = center.y + pointRadius * sin(angle * .pi / 180)
        return CGPoint(x: x, y: y)
    }
    
    private func comparisonPointPosition(index: Int, rivalData: [RadarChartData]) -> CGPoint {
        let angle = Double(index) * 60 - 90
        let value = rivalData[index].value * comparisonProgress
        let pointRadius = radius * value
        let x = center.x + pointRadius * cos(angle * .pi / 180)
        let y = center.y + pointRadius * sin(angle * .pi / 180)
        return CGPoint(x: x, y: y)
    }
    
    private func startAnimations() {
        // Main draw-in animation
        withAnimation(.spring(response: 1.5, dampingFraction: 0.7).delay(0.3)) {
            progress = 1
        }
        
        // Show comparison if available
        if comparisonPokemon != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    showComparison = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                    comparisonProgress = 1
                }
            }
        }
        
        // Subtle rotation animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

// MARK: - Helper function for Pokemon Colors
private func getTypeColor(for pokemon: Pokemon) -> Color {
    // Simple type-based coloring
    guard let firstType = pokemon.types.first?.type else { return .blue }
    
    switch firstType {
    case .fire: return .red
    case .water: return .blue
    case .grass: return .green
    case .electric: return .yellow
    case .psychic: return .purple
    case .ice: return .cyan
    case .dragon: return .indigo
    case .dark: return Color(red: 0.2, green: 0.2, blue: 0.2)
    case .fairy: return .pink
    case .fighting: return .orange
    case .poison: return Color(red: 0.6, green: 0.2, blue: 0.8)
    case .ground: return Color(red: 0.8, green: 0.6, blue: 0.2)
    case .flying: return Color(red: 0.7, green: 0.7, blue: 1.0)
    case .bug: return Color(red: 0.6, green: 0.8, blue: 0.2)
    case .rock: return Color(red: 0.7, green: 0.6, blue: 0.3)
    case .ghost: return Color(red: 0.4, green: 0.3, blue: 0.6)
    case .steel: return Color(red: 0.7, green: 0.7, blue: 0.8)
    case .normal: return Color(red: 0.7, green: 0.7, blue: 0.7)
    @unknown default: return .blue
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.black, .purple.opacity(0.3), .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        PokemonRadarChart(
            pokemon: createSamplePokemon(),
            comparisonPokemon: createRivalPokemon()
        )
    }
}

// MARK: - Sample Data
private func createSamplePokemon() -> Pokemon {
    Pokemon(
        id: 25,
        name: "pikachu",
        height: 4,
        weight: 60,
        baseExperience: 112,
        order: 35,
        isDefault: true,
        sprites: createSampleSprites(),
        types: [PokemonTypeSlot(slot: 1, type: .electric)],
        abilities: [],
        stats: createSampleStats(),
        species: PokemonSpecies(name: "pikachu", url: ""),
        moves: [],
        gameIndices: []
    )
}

private func createRivalPokemon() -> Pokemon {
    Pokemon(
        id: 6,
        name: "charizard",
        height: 17,
        weight: 905,
        baseExperience: 267,
        order: 7,
        isDefault: true,
        sprites: createRivalSprites(),
        types: [PokemonTypeSlot(slot: 1, type: .fire)],
        abilities: [],
        stats: createRivalStats(),
        species: PokemonSpecies(name: "charizard", url: ""),
        moves: [],
        gameIndices: []
    )
}

private func createSampleSprites() -> PokemonSprites {
    PokemonSprites(
        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
        frontShiny: nil,
        frontFemale: nil,
        frontShinyFemale: nil,
        backDefault: nil,
        backShiny: nil,
        backFemale: nil,
        backShinyFemale: nil,
        other: nil
    )
}

private func createRivalSprites() -> PokemonSprites {
    PokemonSprites(
        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png",
        frontShiny: nil,
        frontFemale: nil,
        frontShinyFemale: nil,
        backDefault: nil,
        backShiny: nil,
        backFemale: nil,
        backShinyFemale: nil,
        other: nil
    )
}

private func createSampleStats() -> [PokemonStat] {
    [
        PokemonStat(baseStat: 35, effort: 0, stat: StatType(name: "hp", url: "")),
        PokemonStat(baseStat: 55, effort: 0, stat: StatType(name: "attack", url: "")),
        PokemonStat(baseStat: 40, effort: 0, stat: StatType(name: "defense", url: "")),
        PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-attack", url: "")),
        PokemonStat(baseStat: 50, effort: 0, stat: StatType(name: "special-defense", url: "")),
        PokemonStat(baseStat: 90, effort: 0, stat: StatType(name: "speed", url: ""))
    ]
}

private func createRivalStats() -> [PokemonStat] {
    [
        PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "hp", url: "")),
        PokemonStat(baseStat: 84, effort: 0, stat: StatType(name: "attack", url: "")),
        PokemonStat(baseStat: 78, effort: 0, stat: StatType(name: "defense", url: "")),
        PokemonStat(baseStat: 109, effort: 0, stat: StatType(name: "special-attack", url: "")),
        PokemonStat(baseStat: 85, effort: 0, stat: StatType(name: "special-defense", url: "")),
        PokemonStat(baseStat: 100, effort: 0, stat: StatType(name: "speed", url: ""))
    ]
}
